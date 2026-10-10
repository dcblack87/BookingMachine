# API Reference

BookingMachine's public REST API. Use it to build custom booking flows, check availability, or pull review data.

The widget uses this API internally: everything the widget does, you can do directly.

---

## Base URL

```
https://bookingmachine.io/api/v1
```

All public endpoints are under `/public/`. No authentication required.

---

## CORS

All public endpoints return `Access-Control-Allow-Origin: *`. You can call them directly from the browser.

---

## Error Format

All errors return JSON with an `error` string and an HTTP status code:

```json
{
  "error": "Human-readable error message"
}
```

Validation errors may include a `details` field:

```json
{
  "error": "Validation failed",
  "details": {
    "email": ["Invalid email address"],
    "serviceId": ["Required"]
  }
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200` | OK |
| `201` | Created (bookings, leads) |
| `400` | Bad request: validation error |
| `403` | CAPTCHA verification failed |
| `404` | Business or resource not found |
| `409` | Conflict: time slot no longer available |
| `429` | Rate limit exceeded |
| `500` | Server error |

---

## Rate Limits

Limits are per IP address, using a sliding window algorithm.

| Endpoint | Limit |
|----------|-------|
| `GET /availability` | 60 req/min |
| `POST /quotes` | 30 req/min |
| `GET /reviews` | 30 req/min |
| `GET /bookings/:id` | 30 req/min |
| `POST /leads` | 10 req/min |
| `POST /bookings` | 5 req/min |

When exceeded, the API returns HTTP `429`. Retry after 60 seconds.

---

## CAPTCHA

`POST /quotes`, `POST /bookings`, and `POST /leads` support optional Cloudflare Turnstile verification.

If the business has Turnstile enabled, the site key is returned in the `/config` response as `turnstileSiteKey`. Include the verified token as `turnstileToken` in the request body.

If no token is provided, the request is still accepted, and protection falls back to IP rate limiting.

---

## Endpoints

---

### GET `/public/businesses/:slug/config`

Returns the full configuration for a business: services, pricing rules, branding, add-ons, packages, and vertical settings.

**Parameters**

| Name | In | Description |
|------|----|-------------|
| `slug` | path | Business slug |
| `widget` | query | (optional) Widget config slug: returns filtered services for that widget |

**Response**

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
      "currency": "usd",
      "stripeEnabled": true,
      "stripePublishableKey": "pk_live_...",
      "stripeAccountId": "acct_..."
    },
    "services": [
      {
        "id": "svc_abc123",
        "name": "Full Detail",
        "description": "Interior + exterior full detail",
        "emoji": "✨",
        "category": "detailing",
        "durationMinutes": 180,
        "bufferMinutes": 30,
        "isActive": true,
        "sortOrder": 1
      }
    ],
    "pricingRules": [
      {
        "id": "rule_abc123",
        "serviceId": "svc_abc123",
        "ruleType": "multiplier",
        "dimensionKey": "vehicle_size",
        "dimensionValue": "large",
        "amount": 1.25,
        "amountType": "multiplier",
        "label": "Large vehicle",
        "isActive": true,
        "sortOrder": 1
      }
    ],
    "addons": [],
    "packages": [],
    "widget": null,
    "widgets": [],
    "turnstileSiteKey": null,
    "showPoweredBy": true,
    "vertical": {
      "slug": "generic",
      "terminology": {},
      "pricingDimensions": [],
      "customBookingFields": [],
      "bookingDefaults": {
        "min_notice_hours": 2,
        "advance_booking_days": 60,
        "deposit_percent": 25
      }
    }
  }
}
```

**Cache:** `public, max-age=60, stale-while-revalidate=300`

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
| `teamMemberId` | query | (optional) Filter by team member |

Use either `date` alone, or `startDate` + `endDate` for a range.

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
            "start": "2026-04-10T09:00:00",
            "end": "2026-04-10T12:00:00",
            "available": true
          },
          {
            "start": "2026-04-10T13:00:00",
            "end": "2026-04-10T16:00:00",
            "available": false
          }
        ]
      }
    ]
  }
}
```

Timestamps are in the business's configured timezone.

---

### POST `/public/businesses/:slug/quotes`

Calculate a price quote. Runs the same pricing engine as the widget.

**Request body**

```json
{
  "serviceIds": ["svc_abc123"],
  "selections": {
    "vehicle_size": "large",
    "vehicle_type": "suv"
  },
  "addons": ["ceramic-coating"],
  "packageKey": null,
  "isRecurring": false,
  "customerInfo": {
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "555-0100"
  },
  "turnstileToken": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `serviceIds` | string[] | One or more service IDs |
| `selections` | object | Pricing dimension key/value pairs |
| `addons` | string[] | Add-on keys to include |
| `packageKey` | string \| null | Package key to apply |
| `isRecurring` | boolean | Apply recurring discount if configured |
| `customerInfo` | object | Optional, used for loyalty pricing |
| `turnstileToken` | string \| null | CAPTCHA token (if required) |

**Response**

```json
{
  "data": {
    "quoteId": "qt_abc123",
    "subtotal": 200.00,
    "discount": 0,
    "total": 200.00,
    "depositAmount": 50.00,
    "balanceDue": 150.00,
    "lineItems": [
      { "label": "Full Detail", "amount": 160.00, "type": "base" },
      { "label": "Large vehicle", "amount": 40.00, "type": "multiplier" }
    ]
  }
}
```

---

### POST `/public/businesses/:slug/bookings`

Create a booking. If Stripe is connected and `paymentMethod` is `deposit` or `full`, returns a Stripe Payment Intent client secret to complete payment on the client.

**Request body**

```json
{
  "serviceId": "svc_abc123",
  "scheduledAt": "2026-04-10T14:00:00",
  "customerInfo": {
    "name": "Jane Smith",
    "email": "jane@example.com",
    "phone": "555-0100",
    "address": "123 Main St, Portland OR"
  },
  "verticalData": {
    "vehicle_size": "large",
    "vehicle_type": "suv"
  },
  "customFields": {
    "gate_code": "1234"
  },
  "paymentMethod": "deposit",
  "quoteId": "qt_abc123",
  "notes": "Please bring extra towels",
  "source": "widget",
  "widgetSlug": null,
  "turnstileToken": null
}
```

| Field | Type | Description |
|-------|------|-------------|
| `serviceId` | string | Service to book |
| `scheduledAt` | string | ISO 8601 datetime in business's timezone |
| `customerInfo` | object | name, email, phone, address |
| `verticalData` | object | Pricing dimension key/value pairs |
| `customFields` | object | Values for any custom booking fields |
| `paymentMethod` | string | `deposit`, `full`, or `none` |
| `quoteId` | string \| null | Quote ID from a prior `/quotes` call |
| `notes` | string \| null | Free-text note for the business |
| `source` | string | Attribution: `widget`, `dashboard`, `directory`, `manual` |
| `turnstileToken` | string \| null | CAPTCHA token (if required) |

**Response (201)**

```json
{
  "data": {
    "bookingId": "bk_abc123",
    "status": "pending_payment",
    "scheduledAt": "2026-04-10T14:00:00",
    "total": 200.00,
    "depositAmount": 50.00,
    "balanceDue": 150.00,
    "paymentStatus": "pending_deposit",
    "serviceName": "Full Detail",
    "durationMinutes": 180,
    "stripeClientSecret": "pi_xxx_secret_xxx"
  }
}
```

`stripeClientSecret` is only present when payment is required. Use it with Stripe.js `stripe.confirmCardPayment()` to complete the transaction.

**Conflict:** Returns `409` if the time slot was taken between quote and booking. Show an availability picker again.

---

### POST `/public/businesses/:slug/leads`

Submit a lead without booking. Used when Stripe isn't connected or for "contact me" flows.

**Request body**

```json
{
  "name": "Jane Smith",
  "email": "jane@example.com",
  "phone": "555-0100",
  "serviceInterest": "Full Detail",
  "message": "Interested in monthly service",
  "verticalData": {
    "vehicle_size": "large"
  },
  "turnstileToken": null
}
```

**Response (201)**

```json
{
  "data": {
    "success": true,
    "leadId": "qt_abc123"
  }
}
```

---

### GET `/public/businesses/:slug/reviews`

Returns published reviews for a business.

**Parameters**

| Name | In | Default | Description |
|------|----|---------|-------------|
| `slug` | path | | Business slug |
| `page` | query | `1` | Page number |
| `limit` | query | `20` | Reviews per page (max 50) |

**Response**

```json
{
  "data": {
    "reviews": [
      {
        "id": "rv_abc123",
        "rating": 5,
        "comment": "Incredible work, highly recommend.",
        "customerName": "John D.",
        "serviceName": "Full Detail",
        "response": "Thanks so much, John!",
        "responseAt": "2026-03-20T10:00:00Z",
        "createdAt": "2026-03-15T14:30:00Z"
      }
    ],
    "stats": {
      "count": 42,
      "avgRating": 4.8
    },
    "page": 1,
    "limit": 20
  }
}
```

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
    "id": "bk_abc123",
    "status": "confirmed",
    "scheduledAt": "2026-04-10T14:00:00",
    "durationMinutes": 180,
    "serviceName": "Full Detail",
    "total": 200.00,
    "depositAmount": 50.00,
    "balanceDue": 150.00,
    "paymentStatus": "deposit_paid",
    "businessName": "Acme Detailing",
    "confirmedAt": "2026-04-09T10:00:00Z",
    "completedAt": null,
    "cancelledAt": null
  }
}
```

**Status values:** `pending_payment`, `confirmed`, `in_progress`, `completed`, `cancelled`

**Payment status values:** `pending`, `pending_deposit`, `deposit_paid`, `paid_full`

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
      "features": {
        "bookingsPerMonth": 25,
        "teamMembers": 1,
        "hasPayments": false,
        "hasBadge": true
      },
      "isPopular": false
    }
  ]
}
```
