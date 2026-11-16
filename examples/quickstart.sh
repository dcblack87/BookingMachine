#!/usr/bin/env bash
# Price a job and ask for a booking with the BookingMachine Agent API, in six calls.
#
#   bash examples/quickstart.sh
#
# It runs against the sandbox, a practice business: real prices, real free times and real
# holds, but nobody is emailed, nothing about the customer is kept and no booking is made.
# No API key. Needs curl and jq.
set -euo pipefail

API="https://api.bookingmachine.io/v1/businesses/${BUSINESS:-fresh-start-cleaning}"
AGENT="Quickstart script"
say() { printf '\n\033[1m%s\033[0m\n' "$*"; }

say "1. Read the business"
curl -fsS "$API" | jq '.data | {name, timezone, currency, sandbox, capabilities}'

say "2. List its services"
SERVICES=$(curl -fsS "$API/services")
echo "$SERVICES" | jq -r '.data.services[] | "\(.id)  \(.name)  (\(.durationMinutes) min, from \(.basePrice))"'
SERVICE=$(echo "$SERVICES" | jq -r '.data.services[0].id')

say "3. Ask what sets the price"
curl -fsS "$API/services/$SERVICE/requirements" |
  jq -r '.data.dimensions[] | "\(.key): \([.options[].value] | join(", "))"'

say "4. Get the price for three bedrooms and two bathrooms"
ANSWERS='{"bedrooms":"three","bathrooms":"two"}'
curl -fsS -X POST "$API/quotes" \
  -H 'Content-Type: application/json' -H "X-Agent: $AGENT" \
  -d "{\"serviceIds\":[\"$SERVICE\"],\"answers\":$ANSWERS}" |
  jq '.data | {total, currency, lineItems}'

say "5. Find a free time in the next week and hold it"
FROM=$(date -u -v+2d +%F 2>/dev/null || date -u -d '+2 days' +%F)
TO=$(date -u -v+8d +%F 2>/dev/null || date -u -d '+8 days' +%F)
SLOT=$(curl -fsS "$API/availability?serviceId=$SERVICE&from=$FROM&to=$TO" |
  jq -r '[.data.days[].slots[]][0].id')
[ "$SLOT" != "null" ] || { echo "No free time between $FROM and $TO."; exit 1; }
HOLD=$(curl -fsS -X POST "$API/holds" \
  -H 'Content-Type: application/json' -H "X-Agent: $AGENT" \
  -d "{\"slotId\":\"$SLOT\"}")
echo "$HOLD" | jq '.data | {start, end, expiresAt}'
HOLD_TOKEN=$(echo "$HOLD" | jq -r '.data.holdToken')

say "6. Ask for the booking"
BOOKING=$(curl -fsS -X POST "$API/bookings" \
  -H 'Content-Type: application/json' -H "X-Agent: $AGENT" \
  -H "Idempotency-Key: quickstart-$(date +%s)-$RANDOM" \
  -d "{\"serviceIds\":[\"$SERVICE\"],\"answers\":$ANSWERS,\"holdToken\":\"$HOLD_TOKEN\",
       \"customer\":{\"name\":\"Sam Carter\",\"email\":\"sam@example.com\"}}")
echo "$BOOKING" | jq '.data | {id, status, start, total, sandbox}'
BOOKING_ID=$(echo "$BOOKING" | jq -r '.data.id')

say "The customer confirms (in the sandbox, you play their part)"
curl -fsS -X POST "$API/bookings/$BOOKING_ID/simulate" \
  -H 'Content-Type: application/json' -d '{"outcome":"confirmed"}' |
  jq '.data | {id, status}'

say "Done. Nothing was booked and nobody was emailed."
