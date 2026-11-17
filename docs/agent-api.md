# Agent API

An API for software that books on a customer's behalf: AI assistants, phone receptionists, chat agents. It reads a business, works out the real price for a job with the business's own pricing rules, finds a free time and asks for the booking.

No API key is needed for anything on this page. The examples run as written against a practice business, so you can copy them into a terminal now.

The full documentation lives at [bookingmachine.io/developers](https://bookingmachine.io/developers). The machine-readable description is at [api.bookingmachine.io/v1/openapi.json](https://api.bookingmachine.io/v1/openapi.json). To give the same operations to an AI assistant as tools, see the [MCP server](mcp.md).

---

## Base URL

```
https://api.bookingmachine.io/v1
```

Every answer is JSON. A success is `{ "data": … }`. A refusal is `{ "error", "code", "requestId" }`: `error` is a sentence you can act on or repeat to your user, and `code` is what your software should branch on.

Send `X-Agent` with your agent's name on every request. It is kept on any booking you make, so the business can see where it came from.

---

## The sandbox

`fresh-start-cleaning` is a practice business. Its services, prices, free times and holds are real, and every check on a booking runs as it would for a real business. Three things never happen there: nobody is emailed, nothing about the customer you send is kept, and no booking is made.

Its profile says `"sandbox": true`. Build against it first.

---

## Book a job in six calls

Each step saves what the next one needs in a shell variable, so there is nothing to copy by hand. You need `curl` and `jq`. To run all six at once, use [`examples/quickstart.sh`](../examples/quickstart.sh).

```bash
API=https://api.bookingmachine.io/v1/businesses/fresh-start-cleaning
```

### 1. Read the business

```bash
curl -s $API | jq '.data | {name, timezone, currency, sandbox, capabilities}'
```

```json
{
  "name": "Fresh Start Cleaning",
  "timezone": "Europe/London",
  "currency": "GBP",
  "sandbox": true,
  "capabilities": { "quotes": true, "availability": true, "holds": true, "bookings": true, "changes": false }
}
```

The full answer also carries contact details, the address, opening hours, booking rules, the review rating and `bookingUrl`, the page to send a customer to when you cannot finish the booking yourself.

`capabilities` says what you can do for this business right now. Check it before you promise a customer anything.

### 2. List its services

```bash
curl -s $API/services | jq -r '.data.services[] | "\(.id)  \(.name)"'
SERVICE=$(curl -s $API/services | jq -r '.data.services[0].id')
```

Each service has an `id`, a `name`, a `durationMinutes` and a `basePrice`. The base price is where the price starts, before the customer's answers change it. Never quote it as the price. `SERVICE` is now the Standard Clean.

### 3. Ask what sets the price

```bash
curl -s $API/services/$SERVICE/requirements | jq '.data.dimensions[] | {key, options: [.options[].value]}'
```

`dimensions` are the questions that change the price. For a Standard Clean they are `bedrooms` (`one` to `four`) and `bathrooms` (`one` to `three`). The full answer also lists any other questions, add-ons, whether an address is needed and whether the business takes payment when booking.

### 4. Get the price

```bash
ANSWERS='{"bedrooms":"three","bathrooms":"two"}'

curl -s -X POST $API/quotes \
  -H 'Content-Type: application/json' \
  -H 'X-Agent: Acme Receptionist' \
  -d '{"serviceIds":["'$SERVICE'"],"answers":'$ANSWERS'}' | jq .data
```

```json
{
  "currency": "GBP",
  "total": 187.2,
  "subtotal": 187.2,
  "discount": 0,
  "lineItems": [
    { "label": "Standard Clean", "amount": 120, "type": "service" },
    { "label": "Bedrooms: 3 Bedrooms", "amount": 36, "type": "multiplier" },
    { "label": "Bathrooms: 2 Baths", "amount": 31.2, "type": "multiplier" }
  ],
  "deposit": 46.8,
  "balance": 140.4,
  "durationMinutes": 120
}
```

This is the figure the business's own booking form shows for the same answers. Amounts are in the business's currency, in whole units (pounds, not pence). A quote saves nothing and tells nobody.

### 5. Find a free time and hold it

Pick a date within the next 30 days. This takes the day after tomorrow:

```bash
DAY=$(date -u -v+2d +%F 2>/dev/null || date -u -d '+2 days' +%F)

curl -s "$API/availability?serviceId=$SERVICE&date=$DAY" | jq -c '.data.days[0].slots[:3][] | {start, end}'
SLOT=$(curl -s "$API/availability?serviceId=$SERVICE&date=$DAY" | jq -r '.data.days[0].slots[0].id')
```

Each free time has an `id`, a `start` and an `end`. Times are UTC; show them to the customer in the business's `timezone`. An `id` is good for 24 hours.

Hold the time the customer picks, so nobody else takes it while they decide:

```bash
HOLD=$(curl -s -X POST $API/holds \
  -H 'Content-Type: application/json' \
  -H 'X-Agent: Acme Receptionist' \
  -d '{"slotId":"'$SLOT'"}' | jq -r .data.holdToken)
```

A hold lasts 10 minutes unless you ask for another length, up to 15.

### 6. Ask for the booking

```bash
curl -s -X POST $API/bookings \
  -H 'Content-Type: application/json' \
  -H 'X-Agent: Acme Receptionist' \
  -H "Idempotency-Key: $(uuidgen)" \
  -d '{
    "serviceIds": ["'$SERVICE'"],
    "answers": '$ANSWERS',
    "holdToken": "'$HOLD'",
    "customer": { "name": "Sam Carter", "email": "sam@example.com", "phone": "+447700900123" }
  }' | tee /tmp/booking.json | jq .data

BOOKING=$(jq -r .data.id /tmp/booking.json)
```

```json
{
  "id": "397c740d-5878-4391-8bef-3736ebfb101e",
  "status": "awaiting_customer_confirmation",
  "serviceName": "Standard Clean",
  "start": "2026-12-01T10:00:00.000Z",
  "end": "2026-12-01T12:00:00.000Z",
  "timezone": "Europe/London",
  "currency": "GBP",
  "total": 187.2,
  "sandbox": true
}
```

The answer is `202`, and nothing is booked yet. The next section says why.

A `slot_invalid` answer means the `slotId` or `holdToken` you sent is not one the API gave you. Run step 5 again and use its value.

---

## The customer confirms, not the agent

A booking asked for without an API key is a request. The customer named in it gets an email with a **Confirm your booking** button, and the booking is made when they press it. Until then the time is held, the business hears nothing, and no customer record exists.

This is the rule that lets any agent ask for a booking without an account: an agent can never commit a person to a booking they did not agree to.

Ask how it went with the `id` from step 6:

```bash
curl -s $API/bookings/$BOOKING | jq '.data | {id, status}'
```

`status` is `awaiting_customer_confirmation`, `confirmed`, `expired` or `failed`.

In the sandbox no email is sent, so play the customer's part yourself:

```bash
curl -s -X POST $API/bookings/$BOOKING/simulate \
  -H 'Content-Type: application/json' \
  -d '{ "outcome": "confirmed" }' | jq '.data | {id, status}'
```

`outcome` is `confirmed` or `expired`. Either way nothing is booked and the held time goes back on offer. On any other business this call is refused with `sandbox_only`.

---

## How it connects to a business

The slug in the address names the business. It is the last part of the business's booking page address: `bookingmachine.io/book/fresh-start-cleaning`.

Who you are decides what a booking request does:

| You send | You are | A booking request |
| --- | --- | --- |
| No key | A third party: an assistant, a marketplace, a receptionist service | Answers `202`. The customer is emailed a Confirm button, and the booking is made when they press it |
| The business's own key | The business | Answers `201`. The booking is made at once |

A business makes its key in its dashboard, under Settings → API & webhooks, and chooses what the key may do. It is sent as `Authorization: Bearer <key>`. Keys are being opened to businesses in stages; the [API keys guide](https://bookingmachine.io/developers/api-keys) has the details.

So an agent needs no account to quote and to ask for a booking, and a business that wants its own software to book straight in gives that software a key.

---

## Real businesses

Change the slug. Nothing else in your code changes.

| What | Today |
| --- | --- |
| Profile, services, requirements, quotes, free times, reviews | Open for every business that has not switched AI assistants off |
| Holds and booking requests without a key | Open in the sandbox, and for every business that has switched on bookings from AI assistants. Each business chooses; `capabilities.bookings` on its profile says which |

So read `capabilities` on the business's profile. When `bookings` is `false`, give the customer the price and the free times, then send them to `bookingUrl` to finish.

A business that has not switched bookings on answers `403 agent_bookings_off_for_business`, and one whose plan does not include them answers `403 agent_bookings_not_in_plan`. Both carry `details.bookingUrl`.

A business can switch AI assistants off altogether. Its answer is then `403 agents_off_for_business`, with `details.bookingUrl` to send the customer to.

---

## Refusals worth handling

| Code | Status | What to do |
| --- | --- | --- |
| `business_not_found` | 404 | Check the slug. |
| `service_not_found` | 404 | List the services again. |
| `answers_invalid` | 422 | An answer is missing or not one of the options. `details` names each one. |
| `slot_unavailable` | 409 | The time has just been taken. Ask for the free times again. |
| `agent_writes_off` | 403 | Booking without a key is not open for this business. Send the customer to its booking page. |
| `agent_bookings_not_in_plan` | 403 | The business can be read but is booked on its own page. Give the price and the times, then use `details.bookingUrl`. |
| `agent_bookings_off_for_business` | 403 | The business has not switched on bookings from assistants. Give the price and the times, then use `details.bookingUrl`. |
| `agents_off_for_business` | 403 | The business does not take requests from AI assistants. Use `details.bookingUrl`. |
| `rate_limited` | 429 | Wait for the number of seconds in `Retry-After`. |
| `agent_platform_off` | 503 | The API is switched off for now. Try again later. |

Every answer has an `X-Request-Id` header. Quote it when you report a problem.

---

## Limits

Counted per minute, apart from the business's own booking form, so an agent can never use up the allowance its customers book with.

| Caller | Reads | Writes |
| --- | --- | --- |
| One caller to one business | 120 | 10 |
| Every caller to one business together | 600 | 60 |

A quote counts as a read. A hold and a booking request are writes. Send an `Idempotency-Key` header on a hold or a booking: a retry with the same key and the same body gets the first answer back, and the work is not done twice.

---

## Rules for callers

Ask for a booking only when a person has asked you to make it, with that person's own email address. Hold a time only when you mean to book it. Send your agent's real name in `X-Agent`. Practice in the sandbox, never on a real business.

The full rules are at [bookingmachine.io/developers/acceptable-use](https://bookingmachine.io/developers/acceptable-use).

---

## More

| Page | What it covers |
| --- | --- |
| [Quickstart](https://bookingmachine.io/developers/quickstart) | The six calls above, kept up to date |
| [Sandbox](https://bookingmachine.io/developers/sandbox) | What is real there and what never happens |
| [Concepts](https://bookingmachine.io/developers/concepts) | Businesses, services, requirements, quotes, slots, holds, bookings |
| [How a booking is made](https://bookingmachine.io/developers/booking-flow) | The request, the customer's confirmation and what can go wrong |
| [API reference](https://bookingmachine.io/developers/api-reference) | Every operation, drawn from the live OpenAPI document |
| [Errors and limits](https://bookingmachine.io/developers/errors-and-limits) | Every refusal code and the rate limits |
