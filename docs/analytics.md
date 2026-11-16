# Analytics Integration

How to track BookingMachine events in your analytics tools.

There are two ways. Use one of them for a given tool, not both:

1. **Built-in tracking**: enter your GA4, Google Tag Manager or Meta Pixel id in the dashboard and the widget sends the events for you.
2. **Your own listeners**: listen for the widget's custom events on the page and send them wherever you like.

---

## Why Standard Click Tracking Won't Work

The widget runs inside a Shadow DOM. Standard "click any button" tag manager rules can't see elements inside a Shadow DOM: they're hidden from the outer document's DOM queries.

Instead, the widget dispatches **custom events**. These bubble out of the Shadow DOM (`composed: true`) and are visible on `document`. Built-in tracking and your own listeners both work from these events.

---

## Built-in Tracking

In the dashboard, go to **Settings → Tracking** and enter any of:

- a GA4 Measurement ID
- a Google Tag Manager Container ID
- a Meta (Facebook) Pixel ID

Three switches on the same page choose what is tracked: steps, quotes and bookings. All three are on by default.

When an id is set, a widget embedded with `embed.js` adds that tag to the page it is embedded in and forwards its events to it. If the page already loads the same tag, it is loaded a second time, so enter an id here only for a tag the page does not already load.

What it sends:

| Widget event | GA4 | Tag Manager (`dataLayer` event) | Meta Pixel |
|--------------|-----|---------------------------------|------------|
| `bookkit:step-changed` | `bookkit_step_viewed` (`step`) | `bookkit_step_viewed` | `ViewContent` |
| `bookkit:quote-calculated` | `bookkit_quote_calculated` (`value`, `currency`) | `bookkit_quote_calculated` | `AddToCart` |
| `bookkit:booking-confirmed` | `purchase` and `bookkit_booking_completed` (`transaction_id`, `value`, `currency`) | `bookkit_booking_completed` | `Purchase` |
| `bookkit:booking-pending` | `generate_lead` (`transaction_id`, `value`, `currency`, `service`) | `bookkit_booking_pending` | `Lead` |
| `bookkit:lead-submitted` | `generate_lead` | `generate_lead` | `Lead` |
| `bookkit:customer-info-submitted` | `generate_lead` | `generate_lead` | `Lead` |

The currency sent is the business's own currency.

> **Do not double-count.** If an id is set in Settings → Tracking and you also add your own listener that sends the same event to the same tool (for example a `purchase` on `bookkit:booking-confirmed`), every booking is recorded twice. Pick built-in tracking or your own listeners for each tool.

**WordPress plugin:** widgets placed by the BookingMachine WordPress plugin are loaded by the plugin, not by `embed.js`, so Settings → Tracking is not applied to them. The plugin has its own analytics bridge, which forwards events to GA4, Tag Manager and the Meta Pixel under the names `quotelab_widget_loaded`, `quotelab_step_changed`, `quotelab_quote_calculated`, `quotelab_date_selected`, `quotelab_booking_confirmed` and `quotelab_lead_submitted`.

---

## Your Own Listeners

Use these if you do not use built-in tracking for that tool. The examples below share one helper that reads the business's currency from `bookkit:config-loaded`, so put it first:

```html
<script>
  window.bmCurrency = 'USD';
  document.addEventListener('bookkit:config-loaded', (e) => {
    if (e.detail.currency) window.bmCurrency = e.detail.currency.toUpperCase();
  });
</script>
```

Things to know before you wire events up:

- `bookkit:quote-calculated` fires on **every** recalculation: each option the customer changes and each date they pick. It is not one event per quote. Debounce it or send only the last value if you want one hit per customer.
- A widget where the business confirms bookings by hand fires `bookkit:booking-pending` **instead of** `bookkit:booking-confirmed`. Listen for both if you want every booking.
- `e.detail.total` on a booking event can be `undefined` on some card-payment paths. Guard for it.
- Totals are in whole currency units (e.g. `85.5`), not cents.

---

## GA4 via gtag.js

### Track quote calculations

```html
<script>
  let bmQuoteTimer;
  document.addEventListener('bookkit:quote-calculated', (e) => {
    clearTimeout(bmQuoteTimer);
    bmQuoteTimer = setTimeout(() => {
      gtag('event', 'view_item', {
        currency: window.bmCurrency,
        value: e.detail.total,
      });
    }, 2000);
  });
</script>
```

### Track confirmed bookings (purchase event)

```html
<script>
  document.addEventListener('bookkit:booking-confirmed', (e) => {
    const value = e.detail.total ?? 0;
    gtag('event', 'purchase', {
      transaction_id: e.detail.bookingId,
      value: value,
      currency: window.bmCurrency,
      items: [
        {
          item_name: e.detail.service,
          price: value,
          quantity: 1,
        },
      ],
    });
  });
</script>
```

### Track bookings awaiting confirmation

```html
<script>
  document.addEventListener('bookkit:booking-pending', (e) => {
    gtag('event', 'generate_lead', {
      transaction_id: e.detail.bookingId,
      value: e.detail.total ?? 0,
      currency: window.bmCurrency,
    });
  });
</script>
```

### Track lead submissions

```html
<script>
  document.addEventListener('bookkit:lead-submitted', (e) => {
    gtag('event', 'generate_lead', {
      currency: window.bmCurrency,
    });
  });
</script>
```

Place these scripts anywhere after the gtag.js initialization. They don't need to be next to the widget embed.

---

## Google Tag Manager

GTM can't use click triggers for Shadow DOM elements. Use a **Custom Event** trigger instead.

### 1. Push to dataLayer from the page

Add a Custom HTML tag (trigger: All Pages) with:

```html
<script>
  window.dataLayer = window.dataLayer || [];
  var bmCurrency = 'USD';

  document.addEventListener('bookkit:config-loaded', (e) => {
    if (e.detail.currency) bmCurrency = e.detail.currency.toUpperCase();
  });

  document.addEventListener('bookkit:booking-confirmed', (e) => {
    window.dataLayer.push({
      event: 'bookingmachine_booking_confirmed',
      booking_id: e.detail.bookingId,
      booking_value: e.detail.total ?? 0,
      booking_currency: bmCurrency,
      booking_service: e.detail.service,
    });
  });

  document.addEventListener('bookkit:booking-pending', (e) => {
    window.dataLayer.push({
      event: 'bookingmachine_booking_pending',
      booking_id: e.detail.bookingId,
      booking_value: e.detail.total ?? 0,
      booking_currency: bmCurrency,
      booking_service: e.detail.service,
    });
  });

  document.addEventListener('bookkit:quote-calculated', (e) => {
    window.dataLayer.push({
      event: 'bookingmachine_quote_calculated',
      quote_total: e.detail.total,
      quote_currency: bmCurrency,
    });
  });

  document.addEventListener('bookkit:lead-submitted', () => {
    window.dataLayer.push({ event: 'bookingmachine_lead_submitted' });
  });
</script>
```

### 2. Create triggers in GTM

For each event:
- Trigger type: **Custom Event**
- Event name: `bookingmachine_booking_confirmed` (or `bookingmachine_booking_pending`, `bookingmachine_quote_calculated`, `bookingmachine_lead_submitted`)

`bookingmachine_quote_calculated` is pushed on every recalculation, so limit its trigger if you want one hit per customer.

### 3. Create GA4 Event tags

Create a GA4 Event tag triggered by each custom event. Use GTM variables to pass `booking_value`, `booking_currency`, `booking_id`, etc. as event parameters.

---

## Meta Pixel

### Purchase event on booking

```html
<script>
  document.addEventListener('bookkit:booking-confirmed', (e) => {
    fbq('track', 'Purchase', {
      value: e.detail.total ?? 0,
      currency: window.bmCurrency,
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

  document.addEventListener('bookkit:booking-pending', () => {
    fbq('track', 'Lead');
  });
</script>
```

Place these after the Meta Pixel base code initializes.

---

## Generic / Custom Analytics

The full event list with their `detail` payloads:

```js
const BOOKINGMACHINE_EVENTS = [
  'bookkit:config-loaded',           // { businessName, currency, trackingConfig }
  'bookkit:quote-calculated',        // { total, lineItems }  (every recalculation)
  'bookkit:step-changed',            // { step, index, total, flowOrder }
  'bookkit:date-selected',           // { date } | { date, time } | { date, checkOutDate, nights } | { date, stage: 'overview' }
  'bookkit:customer-info-submitted', // no detail
  'bookkit:booking-confirmed',       // { bookingId, total, service, date, time }
  'bookkit:booking-pending',         // { bookingId, total, service, date, time }
  'bookkit:lead-submitted',          // { name, email }
  'bookkit:reviews-loaded',          // { avgRating, count }  (reviews widget)
  'bookkit:review-submitted',        // { rating }            (review form)
];

BOOKINGMACHINE_EVENTS.forEach((eventName) => {
  document.addEventListener(eventName, (e) => {
    // send to your analytics provider
    console.log(eventName, e.detail);
  });
});
```

See [widget-reference.md](widget-reference.md#custom-events) for each field.

All events bubble up from inside the Shadow DOM and are available on `document`. A widget shown inside an iframe (see the Wix and iframe sections of [platform-guides.md](platform-guides.md)) fires its events inside the frame, so listeners on the parent page do not receive them.
