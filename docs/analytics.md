# Analytics Integration

How to track BookingMachine events in your analytics tools.

---

## Why Standard Click Tracking Won't Work

The widget runs inside a Shadow DOM. Standard "click any button" tag manager rules can't see elements inside a Shadow DOM — they're hidden from the outer document's event listeners and DOM queries.

Instead, listen for the **custom events** that the widget dispatches. These bubble out of the Shadow DOM (`composed: true`) and are visible on `document`.

---

## GA4 via gtag.js

### Track quote calculations

```html
<script>
  document.addEventListener('bookkit:quote-calculated', (e) => {
    gtag('event', 'view_item', {
      currency: 'USD',
      value: e.detail.total,
    });
  });
</script>
```

### Track confirmed bookings (purchase event)

```html
<script>
  document.addEventListener('bookkit:booking-confirmed', (e) => {
    gtag('event', 'purchase', {
      transaction_id: e.detail.bookingId,
      value: e.detail.total,
      currency: 'USD',
      items: [
        {
          item_name: e.detail.service,
          price: e.detail.total,
          quantity: 1,
        },
      ],
    });
  });
</script>
```

### Track lead submissions

```html
<script>
  document.addEventListener('bookkit:lead-submitted', (e) => {
    gtag('event', 'generate_lead', {
      currency: 'USD',
    });
  });
</script>
```

Place these scripts anywhere after the gtag.js initialization — they don't need to be next to the widget embed.

---

## Google Tag Manager

GTM can't use click triggers for Shadow DOM elements. Use a **Custom Event** trigger instead.

### 1. Push to dataLayer from the page

Add a Custom HTML tag (trigger: All Pages) with:

```html
<script>
  document.addEventListener('bookkit:booking-confirmed', (e) => {
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({
      event: 'quotelab_booking_confirmed',
      booking_id: e.detail.bookingId,
      booking_value: e.detail.total,
      booking_service: e.detail.service,
    });
  });

  document.addEventListener('bookkit:quote-calculated', (e) => {
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({
      event: 'quotelab_quote_calculated',
      quote_total: e.detail.total,
    });
  });

  document.addEventListener('bookkit:lead-submitted', () => {
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({ event: 'quotelab_lead_submitted' });
  });
</script>
```

### 2. Create triggers in GTM

For each event:
- Trigger type: **Custom Event**
- Event name: `quotelab_booking_confirmed` (or `quotelab_quote_calculated`, `quotelab_lead_submitted`)

### 3. Create GA4 Event tags

Create a GA4 Event tag triggered by each custom event. Use GTM variables to pass `booking_value`, `booking_id`, etc. as event parameters.

---

## Meta Pixel

### Purchase event on booking

```html
<script>
  document.addEventListener('bookkit:booking-confirmed', (e) => {
    fbq('track', 'Purchase', {
      value: e.detail.total,
      currency: 'USD',
    });
  });
</script>
```

### Lead event on form submission

```html
<script>
  document.addEventListener('bookkit:lead-submitted', () => {
    fbq('track', 'Lead');
  });
</script>
```

Place these after the Meta Pixel base code initializes.

---

## Generic / Custom Analytics

The full event list with their `detail` payloads:

```js
const QUOTELAB_EVENTS = [
  'bookkit:config-loaded',      // { businessName }
  'bookkit:quote-calculated',   // { total, lineItems }
  'bookkit:step-changed',       // { step }
  'bookkit:date-selected',      // { date, time? }
  'bookkit:booking-confirmed',  // { bookingId, total, service, date, time }
  'bookkit:lead-submitted',     // { name, email }
  'bookkit:reviews-loaded',     // { avgRating, count }
];

QUOTELAB_EVENTS.forEach((eventName) => {
  document.addEventListener(eventName, (e) => {
    // send to your analytics provider
    console.log(eventName, e.detail);
  });
});
```

All events bubble up from inside the Shadow DOM and are available on `document`. Register listeners after `DOMContentLoaded` or in a script tag at the bottom of `<body>`.
