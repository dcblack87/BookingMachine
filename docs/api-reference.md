# API Reference

BookingMachine's public REST API. Use it to build custom booking flows, check availability, or pull review data.

The widget uses this API internally: everything the widget does, you can do directly.

---

## Software that books for a customer

If you are building software that books on a customer's behalf (an AI assistant, a receptionist service), use the Agent API instead. It is documented in [agent-api.md](agent-api.md) and its base URL is `https://api.bookingmachine.io/v1`.

---

## Base URL

```
https://bookingmachine.io/api/v1
```

All public endpoints are under `/public/`. No authentication required.

All ids (services, quotes, bookings, reviews, documents) are UUIDs.

---

## CORS

Successful responses return `Access-Control-Allow-Origin: *`, so you can call the API directly from the browser. Two exceptions:

- `GET /public/tiers` does not send the header. Call it from a server.
- Some error responses (for example a `429`, `404` or `400` from `/config`, `/availability`, `/leads`, `GET /reviews` and `GET /bookings/:id`) do not send the header. In a browser these show up as a network error, so treat a failed fetch on those endpoints as a possible error response.

---

## Error Format

All errors return JSON with an `error` string and an HTTP status code. Refusals also carry a machine-readable `code`, and some carry extra fields that are listed with each endpoint.

```json
{
  "error": "This time slot is no longer available. Please select a different time.",
  "code": "slot_unavailable"
}
```

Validation errors use the error `Invalid request` and a `details` object:

```json
{
  "error": "Invalid request",
  "details": {
    "formErrors": [],
    "fieldErrors": {
      "serviceId": ["Invalid uuid"],
      "customerInfo": ["Required"]
    }
  }
}
```

Optional fields must be left out when you have no value. Sending `null` for an optional string fails validation.

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created (bookings, holds, reviews) |
| `202` | Accepted: a reschedule was sent to the business as a request |
| `204` | No content (a released hold) |
| `304` | Not modified (`/config` with a matching `If-None-Match`) |
| `400` | Bad request: validation error or a refusal |
| `402` | Payment could not be verified (`confirm-payment`) |
| `403` | Form token refused, CAPTCHA failed, bookings paused, or an example site |
| `404` | Business or resource not found |
| `409` | Conflict: see the refusal codes of each endpoint |
| `422` | An `Idempotency-Key` was reused with a different request |
| `429` | Rate limit exceeded |
| `500` | Server error |
| `503` | `/tiers` could not be loaded |

Two `403` refusals can come from the endpoints that write for a business:

| Code | Meaning |
|------|---------|
| `bookings_paused` | The business is not taking online bookings right now (bookings and holds) |
| `example_site` | The business is a demonstration site and takes no real bookings, holds, quotes, leads or reviews |

---

## Rate Limits

Limits are per IP address. Unless noted, each limit is counted separately for each business.

| Endpoint | Limit |
|----------|-------|
| `GET /availability` | 60 req/min |
| `GET /availability/overview` | 30 req/min |
| `GET /form-token` | 60 req/min (all businesses together) |
| `POST /quotes` | 30 req/min |
| `POST /bookings` | 5 req/min |
| `POST /leads` | 10 req/min |
| `POST /holds`, `DELETE /holds/:token` | 20 req/min (shared) |
| `GET` and `POST /documents` | 60 req/min (shared) |
| `POST /vouchers/validate` | 15 req/min |
| `GET /reviews` | 30 req/min |
| `POST /reviews` | 3 req/hour |
| `GET /bookings/:id` | 30 req/min per booking |
| `POST /bookings/:id/confirm-payment` | 5 req/min per booking |
| `POST /bookings/:id/cancel`, `POST /bookings/:id/reschedule` | 10 req/min (shared, all bookings together) |

When exceeded, the API returns HTTP `429` with `{ "error": "Too many requests" }`. Quotes, bookings, leads, holds, cancel and reschedule also send a `Retry-After` header in seconds. Elsewhere, retry after 60 seconds.

---

## Form token

`POST /quotes`, `POST /bookings`, `POST /leads` and `POST /reviews` expect a form token. Fetch one when your form loads and send it in the request body as `formToken`.

A request without a valid form token may be refused with `403`:

```json
{
  "error": "Please reload the page and try again.",
  "code": "form_token_required",
  "retryAfterMs": 3000
}
```

| Code | Meaning | What to do |
|------|---------|------------|
| `form_token_required` | The token is missing, unreadable, or was issued for another business | Fetch a token for this business and retry |
| `form_token_expired` | The token is older than 24 hours or has been used too many times | Fetch a new token and retry |
| `form_too_fast` | The token is less than 3 seconds old | Wait `retryAfterMs` and retry |

Rules for a form token:

- It is issued for one `scope`. For the endpoints in this document the scope is the business slug.
- It cannot be used until it is 3 seconds old (`minAgeMs` in the response).
- It is valid for 24 hours and for 20 requests per hour. One token covers a normal quote, lead and booking session.

Send only the fields this document lists.

### GET `/public/form-token`

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `scope` | query | **Required.** The business slug |

**Response**

```json
{
  "data": {
    "token": "eyJzY29wZSI6ImFjbWUtZGV0YWlsaW5nIn0.c2lnbmF0dXJl",
    "minAgeMs": 3000
  }
}
```

Returns `400` with `Invalid scope` when `scope` is missing or malformed.

---

## CAPTCHA

`POST /quotes`, `POST /bookings`, `POST /leads` and `POST /reviews` support optional Cloudflare Turnstile verification.

The Turnstile site key is returned in the `/config` response as `turnstileSiteKey` (`null` when Turnstile is not in use). Include the verified token as `turnstileToken` in the request body.

A token that fails verification gets `403` with `Captcha verification failed`. The form token is expected either way.

---

## Idempotency

`POST /bookings`, `POST /holds`, `POST /bookings/:id/cancel` and `POST /bookings/:id/reschedule` accept an `Idempotency-Key` header (1 to 255 visible ASCII characters, no spaces). A retry with the same key and the same body returns the first response again, with the header `Idempotent-Replayed: true`, instead of acting twice.

| Status | Code | Meaning |
|--------|------|---------|
| `400` | `idempotency_key_invalid` | The key is empty, too long, or has spaces or non-ASCII characters |
| `409` | `idempotency_in_progress` | The first request with this key is still running |
| `422` | `idempotency_mismatch` | The key was already used with a different body |

---

## Endpoints

---

### GET `/public/businesses/:slug/config`

Returns the full configuration for a business: services, pricing rules, branding, add-ons, packages, and vertical settings.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `slug` | path | Business slug |
| `widget` | query | (optional) Widget slug: returns that widget's settings and only its services. Without it, the business's primary widget is used |

**Response** (shortened)

```json
{
  "data": {
    "business": {
      "slug": "acme-detailing",
      "name": "Acme Detailing",
      "branding": {
        "primaryColor": "#1a6b3c",
        "accentColor": "#f59e0b"
      },
      "timezone": "America/Los_Angeles",
      "locale": "en-US",
      "currency": "usd",
      "country": "US",
      "stripeEnabled": true,
      "stripePublishableKey": "pk_live_...",
      "stripeAccountId": "acct_...",
      "slotIntervalMinutes": 30,
      "vouchersEnabled": false
    },
    "services": [
      {
        "id": "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10",
        "name": "Full Detail",
        "description": "Interior + exterior full detail",
        "emoji": null,
        "category": "detailing",
        "durationMinutes": 180,
        "bufferMinutes": 30,
        "isActive": true,
        "sortOrder": 1,
        "recurringMode": "off",
        "bookingUnit": "minutes",
        "slotWindows": null
      }
    ],
    "pricingRules": [
      {
        "id": "8d4f0a2b-7c36-4e51-a9d8-0b5e3c6f1a27",
        "serviceId": "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10",
        "ruleType": "multiplier",
        "dimensionKey": "vehicle_size",
        "dimensionValue": "large",
        "amount": 1.25,
        "amountType": "multiplier",
        "label": "Large vehicle",
        "conditions": null,
        "isActive": true,
        "sortOrder": 1
      }
    ],
    "addons": [
      {
        "key": "ceramic-coating",
        "name": "Ceramic coating",
        "description": null,
        "default_price": 150,
        "default_duration_minutes": 60,
        "serviceId": null
      }
    ],
    "packages": [],
    "widget": null,
    "widgets": [],
    "turnstileSiteKey": null,
    "showPoweredBy": true,
    "vertical": {
      "slug": "generic",
      "name": "Generic",
      "terminology": {},
      "pricingDimensions": [],
      "customBookingFields": [],
      "bookingDefaults": {
        "min_notice_hours": 2,
        "advance_booking_days": 60
      }
    }
  }
}
```

Only services that are on sale are returned.

`business` also carries: `widgetDefaults`, `recurringLabel`, `teamMemberLabel`, `showTeamBio`, `closedDayWording`, `changesMessage`, `orderChangesMessage`, `subscriptionFirstPaymentDefault`, and, only when true, `bookingsPaused` and `exampleSite`. When `bookingsPaused` is true, `POST /bookings` and `POST /holds` are refused; send a lead instead.

Services also carry recurring settings (`defaultRecurring`, `defaultRecurringFreq`, `defaultRecurringDiscount`, `recurringDiscounts`) and the limits for services sold by the night or by the hour (`minNights`, `maxNights`, `minHours`, `maxHours`, `maxPrice`, `checkOutWindowStart`, `checkOutWindowEnd`). `bookingUnit` is `minutes`, `night` or `hour`.

Other top-level keys:

| Key | Description |
|-----|-------------|
| `widget` | Settings of the widget in use (form mode, payment and deposit terms, which customer fields to ask, team member selection, service address mode, attached documents). `null` when the business has no widget |
| `widgets` | Every widget of the business: `id`, `name`, `slug`, `formMode` |
| `teamMembers` | Active team members: `id`, `name`, `avatarUrl`, `color`, `bio`, `specialtyIds` |
| `locations` | Active locations: `id`, `name`, `slug`, `addressJson`, `phone`, `photosJson`, `googleMapsUrl`, `isPrimary` |
| `customQuestions` | The business's own active booking questions |
| `widgetTheme` | Widget colours and style, or `null` |
| `trackingConfig` | Analytics tracking settings, or `null` |
| `seasonalPricing` | Date ranges of seasonal prices. Present only when the business uses seasonal pricing |

**Cache:** `public, no-cache` with an `ETag`. Send the ETag back as `If-None-Match` to get `304` with no body when nothing has changed.

---

### GET `/public/businesses/:slug/availability`

Returns available time slots for a service.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `slug` | path | Business slug |
| `serviceId` | query | **Required.** Service ID to check |
| `date` | query | Single date, `YYYY-MM-DD` |
| `startDate` | query | Start of date range, `YYYY-MM-DD` |
| `endDate` | query | End of date range, `YYYY-MM-DD` |
| `serviceIds` | query | (optional) Comma-separated ids of every service in the booking (max 20), so slots are long enough for all of them |
| `addons` | query | (optional) Comma-separated add-on keys already chosen. Add-ons add time |
| `hours` | query | (optional) Hours wanted, 1 to 24, for a service sold by the hour |
| `teamMemberId` | query | (optional) Filter by team member |
| `locationId` | query | (optional) Filter by location |
| `mode` | query | (optional) `slots` (default) or `range`. `range` adds a `nights` array. Services sold by the night always answer in range mode |
| `ids` | query | (optional) `1` adds a signed `id` to each available slot. Use it to hold the slot or to book it |

Use either `date` alone, or `startDate` + `endDate` for a range. Dates are calendar days in the business's timezone.

**Response**

```json
{
  "data": {
    "days": [
      {
        "date": "2026-04-10",
        "isBlocked": false,
        "slots": [
          {
            "start": "2026-04-10T16:00:00.000Z",
            "end": "2026-04-10T19:00:00.000Z",
            "available": true
          },
          {
            "start": "2026-04-10T20:00:00.000Z",
            "end": "2026-04-10T23:00:00.000Z",
            "available": false
          }
        ]
      }
    ],
    "timezone": "America/Los_Angeles"
  }
}
```

`start` and `end` are UTC instants. `timezone` is the business's timezone: convert to it before showing a time to a customer.

A day with no available slot may carry `reason`: `closed`, `not_open`, `member_off`, `full` or `no_times`.

In range mode the response also has `nights`: `[{ "date": "2026-04-10", "available": true }]`, one entry per night starting on that date.

Returns `404` with `Service not found` or `Location not found` for an unknown or inactive service or location. The response is never cached.

---

### GET `/public/businesses/:slug/availability/overview`

Returns which days have anything free, across all services of a widget. Use it to draw a calendar before the customer has picked a service.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `slug` | path | Business slug |
| `startDate` | query | **Required.** `YYYY-MM-DD` |
| `endDate` | query | **Required.** `YYYY-MM-DD`. The range may cover at most 42 days |
| `widget` | query | (optional) Widget slug. Without it, the primary widget's services are used |
| `locationId` | query | (optional) Filter by location |

**Response**

```json
{
  "data": {
    "startDate": "2026-04-01",
    "endDate": "2026-04-30",
    "services": [
      { "id": "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10", "bookingUnit": "minutes" }
    ],
    "days": [
      {
        "date": "2026-04-10",
        "status": "open",
        "services": { "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10": "open" }
      },
      {
        "date": "2026-04-11",
        "status": "closed",
        "services": { "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10": "closed" },
        "reason": "closed"
      }
    ]
  }
}
```

`status` is `open`, `full` or `closed`. `reason` uses the same values as `/availability` and is absent when the day is open. The overview covers at most 12 services.

---

### POST `/public/businesses/:slug/quotes`

Calculate a price quote and save it. Runs the same pricing engine as the widget.

**Request body**

```json
{
  "serviceIds": ["3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10"],
  "selections": {
    "vehicle_size": "large",
    "vehicle_type": "suv"
  },
  "addons": ["ceramic-coating"],
  "customerInfo": {
    "name": "Jane Example",
    "email": "jane@example.com",
    "phone": "555-0100"
  },
  "formToken": "eyJzY29wZSI6ImFjbWUtZGV0YWlsaW5nIn0.c2lnbmF0dXJl"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `serviceIds` | string[] | **Required.** One or more service IDs |
| `selections` | object | **Required.** Pricing dimension key/value pairs. A value is a string or an array of strings. Send `{}` when there are none |
| `addons` | string[] | Add-on keys to include (max 50) |
| `packageKey` | string | Package key to apply |
| `isRecurring` | boolean | Price as a recurring booking at the service's own frequency |
| `recurringFrequency` | string | `weekly`, `biweekly` or `monthly` |
| `voucherCode` | string | Discount code. An invalid code is ignored |
| `checkInDate`, `checkOutDate` | string | `YYYY-MM-DD`, for a service sold by the night. The number of nights is worked out from these |
| `hours` | number | 1 to 24, for a service sold by the hour |
| `date` | string | `YYYY-MM-DD`, the day asked about. Used for seasonal prices |
| `customerInfo` | object | Optional `name`, `email`, `phone`. With an email, the customer is saved and the business is told about the quote |
| `source` | string | Where the request came from (max 50 characters). Defaults to `widget` |
| `formToken` | string | See [Form token](#form-token) |
| `turnstileToken` | string | CAPTCHA token |

**Response**

```json
{
  "data": {
    "quoteId": "b71c4e9a-2d58-4f03-8a6b-9e0d1c2f3a45",
    "lineItems": [
      { "label": "Full Detail", "amount": 160, "type": "service" },
      { "label": "Large vehicle", "amount": 40, "type": "multiplier" },
      { "label": "Ceramic coating", "amount": 150, "type": "addon" }
    ],
    "subtotal": 350,
    "discount": 0,
    "total": 350,
    "estimatedDuration": 240,
    "depositAmount": 87.5,
    "balanceDue": 262.5
  }
}
```

Amounts are numbers. Line item `type` is one of `service`, `multiplier`, `addon`, `surcharge`, `discount`, `package_discount`, `recurring_discount`, `voucher_discount`. A line item may also carry `quantity` and `unitAmount`.

**Refusals** (all `400`)

| Code | Meaning |
|------|---------|
| `no_valid_services` | None of the `serviceIds` is a service on sale |
| `units_invalid` | The stay dates or hours are not ones the service sells |
| `addon_not_offered` | An add-on is not sold with these services |
| `answers_invalid` | A selection is not valid. `issues` lists each problem |

---

### POST `/public/businesses/:slug/holds`

Hold a time slot for a few minutes while the customer fills in their details. Get the slot id from `/availability` with `ids=1`.

**Request body**

```json
{
  "slotId": "eyJiIjoiLi4uIn0.c2lnbmF0dXJl",
  "ttlMinutes": 10
}
```

| Field | Type | Description |
|-------|------|-------------|
| `slotId` | string | **Required.** A slot `id` from `/availability` |
| `ttlMinutes` | number | How long to hold, 1 to 15. Defaults to 10 |

**Response (201)**

```json
{
  "data": {
    "holdToken": "hold_Zk3vQ8mN1xT7bR2cY9pL4wA6sD0fGhJe",
    "slotId": "eyJiIjoiLi4uIn0.c2lnbmF0dXJl",
    "startsAt": "2026-04-10T16:00:00.000Z",
    "endsAt": "2026-04-10T19:00:00.000Z",
    "expiresAt": "2026-03-28T18:10:00.000Z",
    "timezone": "America/Los_Angeles"
  }
}
```

Send `holdToken` with the booking. Slot ids are not issued for services sold by the night.

**Refusals**

| Status | Code | Meaning |
|--------|------|---------|
| `400` | `slot_invalid` | The slot id could not be used. `reason` says why |
| `409` | `slot_unavailable` | The time has been taken |
| `429` | `too_many_holds` | Too many holds are open. You can still book without a hold |
| `403` | `bookings_paused`, `example_site` | See [Error Format](#error-format) |

---

### DELETE `/public/businesses/:slug/holds/:token`

Release a hold before it runs out.

Returns `204` with no body. Returns `404` with code `hold_invalid` when the hold does not exist or has already been used.

---

### GET `/public/businesses/:slug/documents`

Returns the documents (terms, waivers, agreements) attached to a widget.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `slug` | path | Business slug |
| `widgetSlug` | query | (optional) Widget slug. Without it, the primary widget is used |

**Response**

```json
{
  "data": [
    {
      "id": "5e8a1d3c-9b27-4f60-b4c1-7a2d0e6f8b93",
      "title": "Service agreement",
      "documentType": "terms",
      "contentHtml": "<p>...</p>",
      "fileUrl": null,
      "contentMode": "html",
      "acceptanceMode": "checkbox",
      "version": 3,
      "isRequired": true
    }
  ]
}
```

### POST `/public/businesses/:slug/documents`

Returns the same documents with the customer's and the booking's details filled into the text, plus `renderedAt`. Show these to the customer at the terms step.

**Request body**

```json
{
  "context": {
    "serviceId": "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10",
    "customer": { "name": "Jane Example", "email": "jane@example.com" },
    "booking": { "scheduledAt": "2026-04-10T16:00:00Z", "total": 350 }
  }
}
```

All fields are optional: `widgetSlug`, `context.serviceId`, `context.customer` (`name`, `email`, `phone`, `address`), `context.booking` (`scheduledAt` as an instant with `Z` or an offset, `total`, `depositAmount`, `balanceDue`).

**Response**

The same `data` array as the GET, plus `renderedAt` beside it:

```json
{
  "data": [],
  "renderedAt": "2026-03-28T18:00:00.000Z"
}
```

When the customer accepts, send each document back in the booking's `acceptedDocuments` with its `id`, its `version` and this `renderedAt`.

---

### POST `/public/businesses/:slug/vouchers/validate`

Check a discount code before booking.

**Request body**

```json
{
  "code": "SPRING10",
  "serviceIds": ["3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10"],
  "subtotal": 350
}
```

`code` is required (1 to 32 characters). `serviceIds` and `subtotal` are optional.

**Response**

A valid code:

```json
{
  "data": {
    "valid": true,
    "code": "SPRING10",
    "discountType": "percent",
    "value": 10,
    "description": "Spring offer",
    "minOrderValue": null
  }
}
```

An invalid code also returns `200`:

```json
{
  "data": { "valid": false, "reason": "expired", "minOrderValue": null }
}
```

`discountType` is `percent` or `fixed`. `reason` is one of `not_found`, `inactive`, `expired`, `not_started`, `depleted`, `min_order_not_met`, `service_not_eligible`, `per_customer_limit`.

---

### POST `/public/businesses/:slug/bookings`

Create a booking. If the business takes payments and `paymentMethod` is `deposit` or `full`, returns a Stripe Payment Intent client secret to complete payment on the client.

**Request body**

```json
{
  "serviceId": "3f2b8c1e-5a47-4d09-9b6e-2c1a7d4e8f10",
  "scheduledAt": "2026-04-10T16:00:00Z",
  "customerInfo": {
    "name": "Jane Example",
    "email": "jane@example.com",
    "phone": "555-0100",
    "address": "123 Example St, Portland OR"
  },
  "verticalData": {
    "vehicle_size": "large",
    "vehicle_type": "suv"
  },
  "customFields": {
    "gate_code": "1234"
  },
  "addons": ["ceramic-coating"],
  "paymentMethod": "deposit",
  "quoteId": "b71c4e9a-2d58-4f03-8a6b-9e0d1c2f3a45",
  "notes": "Please bring extra towels",
  "source": "widget",
  "formToken": "eyJzY29wZSI6ImFjbWUtZGV0YWlsaW5nIn0.c2lnbmF0dXJl"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `serviceId` | string | **Required.** Service to book |
| `serviceIds` | string[] | Every service in the booking, when there is more than one (max 10) |
| `scheduledAt` | string | Start time. Either an instant with `Z` or a `±HH:MM` offset, or a local time with no offset (`2026-04-10T09:00:00`), which is read in the business's timezone. Required unless the service has no date and time, or a `slotId` or `holdToken` is sent |
| `slotId` | string | A slot `id` from `/availability`. Sets the time, team member and location |
| `holdToken` | string | A hold from `POST /holds`. The booking takes the held time |
| `checkOutDate` | string | `YYYY-MM-DD`, for a service sold by the night |
| `hours` | number | 1 to 24, for a service sold by the hour |
| `customerInfo` | object | **Required.** `name` and `email` are required. `phone` and `address` are optional. `address` is a string or an object with `line1`, `line2`, `city`, `region`, `postalCode`, `country` |
| `verticalData` | object | Pricing dimension key/value pairs |
| `customFields` | object | Values for any custom booking fields |
| `addons` | string[] | Add-on keys (max 50) |
| `paymentMethod` | string | **Required.** `deposit`, `full`, or `none` |
| `quoteId` | string | Quote ID from a prior `/quotes` call |
| `voucherCode` | string | Discount code |
| `recurringFrequency` | string | `weekly`, `biweekly` or `monthly`. Leave out for a one-time booking |
| `preferredTeamMemberId` | string | Team member the customer chose |
| `locationId` | string | Location to book at |
| `acceptedDocuments` | object[] | Documents the customer accepted: `documentId`, `documentVersion`, `renderedAt`, `acceptanceMode` (`checkbox`) |
| `notes` | string | Free-text note for the business (max 2000 characters) |
| `source` | string | Attribution label (max 50 characters). Defaults to `widget` |
| `widgetSlug` | string | The widget the booking came through. Sets the deposit terms. Defaults to the primary widget |
| `formToken` | string | See [Form token](#form-token) |
| `turnstileToken` | string | CAPTCHA token |

The price is always worked out by the server. Amounts sent by the client are not used.

**Response (201)**

```json
{
  "data": {
    "bookingId": "c0a8d2f4-6b19-4e73-9d5a-1f3e7b8c2d60",
    "orderNumber": 1042,
    "status": "pending_payment",
    "scheduledAt": "2026-04-10T16:00:00.000Z",
    "total": 350,
    "depositAmount": 87.5,
    "balanceDue": 262.5,
    "paymentStatus": "pending",
    "serviceName": "Full Detail",
    "durationMinutes": 240,
    "stripeClientSecret": "pi_xxx_secret_xxx"
  }
}
```

`status` is `pending_payment` when a payment is due now, `pending_confirmation` when the business confirms bookings by hand, and `confirmed` otherwise. `scheduledAt` is a UTC instant. Amounts are numbers. `orderNumber` may be `null`. The response may also carry `recurring` and `voucher` objects.

`stripeClientSecret` is only present when payment is required. Set up Stripe.js with the `stripePublishableKey` from `/config` and the `stripeAccountId` as its `stripeAccount` option, then call `stripe.confirmCardPayment()` with the client secret. When Stripe reports success, call `POST /public/bookings/:id/confirm-payment` to confirm the booking.

If the same booking is sent twice, the second response is `200` with the first booking and `"duplicate": true`.

**Refusals**

Each refusal has `error`, `code`, and sometimes extra fields.

| Status | Code | Meaning |
|--------|------|---------|
| `400` | `service_not_found` | A service id is unknown or not on sale |
| `400` | `invalid_location` | The location is not one of the business's active locations |
| `400` | `scheduling_required` | The service needs a date and time |
| `404` | `quote_not_found` | The quote does not exist for this business |
| `409` | `quote_converted` | The quote has already become a booking |
| `400` | `quote_expired`, `quote_declined` | The quote can no longer be booked |
| `409` | `service_not_offered` | The service is not offered through this widget |
| `400` | `address_incomplete`, `address_partial`, `address_outside_region` | The address is required, unreadable, or outside the area served |
| `400` | `invalid_team_member`, `team_member_required` | The team member cannot be booked, or one must be chosen |
| `400` | `checkout_required`, `checkout_not_after_checkin`, `stay_too_short`, `stay_too_long`, `not_sold_by_night` | Problems with a stay's dates |
| `409` | `closed_dates` | The stay runs through dates the business is closed |
| `400` | `hours_required`, `hours_too_few`, `hours_too_many`, `not_sold_by_hour` | Problems with `hours` |
| `400` | `voucher_invalid` | The discount code cannot be used. `reason` says why |
| `409` | `voucher_depleted` | The discount code has run out |
| `409` | `slot_unavailable` | The time has been taken. Show available times again |
| `400` | `slot_invalid` | The `slotId` could not be used. `reason` says why |
| `400` | `hold_invalid` | The hold does not exist, was used, or is for another time or service |
| `409` | `hold_expired` | The hold ran out and the time has been taken |
| `400` | `documents_required` | Required documents were not accepted |
| `409` | `document_version_changed`, `document_acceptance_expired` | Fetch the documents again and ask the customer to accept them. `documentIds` lists which |
| `400` | `payment_required` | The booking needs a deposit or full payment; `paymentMethod` was `none` |
| `400` | `addon_not_offered` | An add-on is not sold with these services |
| `400` | `answers_invalid` | An answer is not valid. `issues` lists each problem |
| `403` | `bookings_paused`, `example_site` | See [Error Format](#error-format) |

---

### POST `/public/bookings/:id/confirm-payment`

Call this after Stripe confirms the card payment. The server checks the payment with Stripe, then moves the booking from `pending_payment` to `confirmed`.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `id` | path | Booking ID |

No request body.

**Response**

```json
{
  "data": {
    "status": "confirmed",
    "paymentStatus": "deposit_paid"
  }
}
```

`paymentStatus` is `deposit_paid` or `paid_full`. The response may carry further fields about the booking, including `recurring`.

If the booking is not waiting for payment, the response is `200` with only its current `status`. Returns `402` with `Payment could not be verified` when Stripe has no successful payment for the booking, and `404` when the booking does not exist.

---

### POST `/public/businesses/:slug/leads`

Submit a lead without booking. Use it for "contact me" flows, or when the business is not taking online bookings.

**Request body**

```json
{
  "name": "Jane Example",
  "email": "jane@example.com",
  "phone": "555-0100",
  "serviceInterest": "Full Detail",
  "message": "Interested in monthly service",
  "verticalData": {
    "vehicle_size": "large"
  },
  "formToken": "eyJzY29wZSI6ImFjbWUtZGV0YWlsaW5nIn0.c2lnbmF0dXJl"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `name` | string | **Required** unless `partial` is true |
| `email` | string | **Required** |
| `phone` | string | Max 50 characters |
| `serviceInterest` | string | Max 255 characters |
| `message` | string | Max 2000 characters |
| `verticalData` | object | Pricing dimension key/value pairs |
| `quoteId` | string | A quote just created with `POST /quotes`, to attach the lead to it instead of creating a second record |
| `partial` | boolean | True when the customer left the form unfinished. A partial lead is recorded but nobody is emailed |
| `source` | string | Attribution label (max 50 characters). Defaults to `widget` |
| `formToken` | string | See [Form token](#form-token) |
| `turnstileToken` | string | CAPTCHA token |

**Response (200)**

```json
{
  "data": {
    "success": true,
    "leadId": "b71c4e9a-2d58-4f03-8a6b-9e0d1c2f3a45"
  }
}
```

`leadId` is the id of the quote record the lead is stored on.

---

### GET `/public/businesses/:slug/reviews`

Returns published reviews for a business.

**Parameters**

| Name | In | Default | Description |
|------|----|---------|-------------|
| `slug` | path | | Business slug |
| `page` | query | `1` | Page number |
| `limit` | query | `20` | Reviews per page (max 50) |
| `featured` | query | | `true` returns only featured reviews |

**Response**

```json
{
  "data": {
    "reviews": [
      {
        "id": "9a3d7e1f-4c82-4b56-8e0a-6d2f1b5c7e94",
        "rating": 5,
        "comment": "Incredible work, highly recommend.",
        "response": "Thanks so much, John!",
        "responseAt": "2026-03-20T10:00:00.000Z",
        "customerName": "John D.",
        "serviceName": "Full Detail",
        "photoUrls": null,
        "videoUrl": null,
        "videoThumbnail": null,
        "isVerified": true,
        "isFeatured": false,
        "source": "public",
        "createdAt": "2026-03-15T14:30:00.000Z"
      }
    ],
    "stats": {
      "count": 42,
      "avgRating": 4.8
    },
    "page": 1,
    "limit": 20,
    "timezone": "America/Los_Angeles"
  }
}
```

`stats` covers published reviews only. Dates are UTC instants; `timezone` is the business's timezone.

---

### POST `/public/businesses/:slug/reviews`

Submit a review of a business.

**Request body**

```json
{
  "rating": 5,
  "comment": "Incredible work, highly recommend.",
  "reviewerName": "John Example",
  "reviewerEmail": "john@example.com",
  "formToken": "eyJzY29wZSI6ImFjbWUtZGV0YWlsaW5nIn0.c2lnbmF0dXJl"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `rating` | number | **Required.** Whole number, 1 to 5 |
| `reviewerName` | string | **Required.** Max 100 characters |
| `comment` | string | Max 2000 characters |
| `reviewerEmail` | string | Links the review to an existing customer with that email |
| `photoUrls` | string[] | Up to 3 URLs |
| `videoUrl`, `videoThumbnail` | string | URLs |
| `formToken` | string | See [Form token](#form-token) |
| `turnstileToken` | string | CAPTCHA token |

**Response (201)**

```json
{
  "data": {
    "id": "9a3d7e1f-4c82-4b56-8e0a-6d2f1b5c7e94",
    "rating": 5
  }
}
```

The business decides whether new reviews are published straight away or after it has approved them.

---

### GET `/public/bookings/:id`

Look up a booking by ID. Useful for building custom confirmation or status pages.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `id` | path | Booking ID or share token |

**Response**

```json
{
  "data": {
    "id": "c0a8d2f4-6b19-4e73-9d5a-1f3e7b8c2d60",
    "status": "confirmed",
    "scheduledAt": "2026-04-10T16:00:00.000Z",
    "durationMinutes": 240,
    "serviceName": "Full Detail",
    "total": "350.00",
    "depositAmount": "87.50",
    "balanceDue": "262.50",
    "paymentStatus": "deposit_paid",
    "confirmedAt": "2026-03-28T18:05:00.000Z",
    "startedAt": null,
    "completedAt": null,
    "cancelledAt": null,
    "businessName": "Acme Detailing"
  }
}
```

On this endpoint `total`, `depositAmount` and `balanceDue` are strings with two decimals. Times are UTC instants.

**Status values:** `pending_payment`, `pending_confirmation`, `confirmed`, `in_progress`, `completed`, `cancelled`, `no_show`

**Payment status values:** `pending`, `deposit_paid`, `paid_full`, `refunded`, `partial_refund`

---

### POST `/public/bookings/:id/cancel`

Cancel a booking for the customer. Nothing is refunded by this call; the business is told what was paid.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `id` | path | The booking's share token. A booking ID is not accepted |

**Request body**

```json
{
  "reason": "Change of plans"
}
```

`reason` is optional (max 500 characters).

**Response**

```json
{
  "data": {
    "status": "cancelled",
    "amountPaid": 87.5
  }
}
```

**Refusals** (all `409`). Each carries `contact` with the business's `phone` and `email` (either may be `null`), so you can tell the customer how to reach the business.

| Code | Meaning |
|------|---------|
| `too_late` | The business's notice period for changes has passed |
| `online_changes_off` | This booking cannot be changed online |
| `not_changeable` | The booking is in a state that cannot be changed (for example already cancelled or completed) |

Returns `404` with `Booking not found` for an unknown share token.

---

### POST `/public/bookings/:id/reschedule`

Move a booking to a new time for the customer. The new time must pass the same checks as a new booking.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `id` | path | The booking's share token. A booking ID is not accepted |

**Request body**

```json
{
  "scheduledAt": "2026-04-12T16:00:00Z"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `slotId` | string | A slot `id` from `/availability` for the same service |
| `scheduledAt` | string | The new start, as an instant with `Z` or an offset |
| `confirmTotal` | number | The new total the customer agreed to, when the price changes |

Send exactly one of `slotId` and `scheduledAt`.

**Response**

Moved (`200`):

```json
{
  "data": {
    "status": "rescheduled",
    "scheduledAt": "2026-04-12T16:00:00.000Z",
    "total": 350,
    "leftToPay": 262.5
  }
}
```

Sent to the business as a request (`202`). This happens when the business confirms its bookings by hand; the booking does not move until the business agrees:

```json
{
  "data": {
    "status": "requested",
    "requestedAt": "2026-04-12T16:00:00.000Z"
  }
}
```

**Refusals**

| Status | Code | Meaning |
|--------|------|---------|
| `400` | `slot_invalid` | The `slotId` could not be read, or is for another business or service |
| `400` | `no_change` | The new time is the time already booked |
| `409` | `slot_unavailable` | The new time is not available |
| `409` | `price_changed` | The price is different at the new time. The response carries `previousTotal`, `newTotal` and `leftToPay`. Show the customer the new price and send the request again with `confirmTotal` set to `newTotal` |
| `409` | `too_late`, `online_changes_off`, `not_changeable` | As for cancel, with `contact` |

Returns `404` with `Booking not found` for an unknown share token.

---

### GET `/public/tiers`

Returns BookingMachine's current subscription tier list. Use this to build a pricing page or check feature availability.

**Response**

```json
{
  "data": [
    {
      "slug": "free",
      "name": "Free",
      "description": "Get started for free",
      "sortOrder": 0,
      "priceMonthly": 0,
      "priceAnnual": 0,
      "bookingsPerMonth": 25,
      "teamMembers": 1,
      "storageGb": 1,
      "features": {
        "bookingsPerMonth": 25,
        "teamMembers": 1,
        "hasPayments": false,
        "hasBadge": true
      },
      "badgeColor": null,
      "isPopular": false
    }
  ],
  "displayFeatures": []
}
```

The values above are an example; read the live values from the response. `bookingsPerMonth` and `teamMembers` are `null` when unlimited. `features` holds many more flags than shown. `displayFeatures` is the list of feature rows for a pricing table.

Returns `503` when the tiers cannot be loaded. This endpoint does not send CORS headers.
