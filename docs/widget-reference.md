# Widget Reference

Complete reference for the BookingMachine embed widget.

---

## Embed Snippet

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="inline"
  data-primary-color="#1a6b3c"
  async
></script>
```

---

## Data Attributes

| Attribute | Required | Default | Description |
|-----------|----------|---------|-------------|
| `data-business` | Yes | — | Your business slug (found in Settings → Business Profile) |
| `data-mode` | No | `inline` | Display mode: `inline`, `floating`, or `modal` |
| `data-widget` | No | — | Widget config slug — filters to a specific set of services configured in the dashboard |
| `data-primary-color` | No | — | Hex color to override the business's default primary color (e.g. `#1a6b3c`) |
| `data-source` | No | — | Attribution string passed to bookings and leads (e.g. `homepage`, `landing-page`) |

---

## Display Modes

### `inline` (default)

The widget renders at the location of the script tag, expanding vertically as the customer progresses through steps. Best for dedicated booking pages.

```html
<script src="https://bookingmachine.io/embed.js" data-business="your-slug" async></script>
```

### `floating`

Renders a fixed button in the bottom-right corner. Clicking the button opens the full widget panel. The widget is not created until the button is clicked.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="floating"
  async
></script>
```

### `modal`

Same as floating but opens in a centered overlay with a backdrop.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="modal"
  async
></script>
```

---

## CSS Custom Properties

The widget uses Shadow DOM, so host page styles don't affect it. To customize colors, set CSS custom properties on the `<bookkit-widget>` element or on `:root`:

```css
bookkit-widget {
  --bk-primary: #1a6b3c;
  --bk-accent: #f59e0b;
}
```

| Property | Description |
|----------|-------------|
| `--bk-primary` | Primary brand color (buttons, highlights) |
| `--bk-accent` | Accent color |

For the reviews widget specifically:

| Property | Default | Description |
|----------|---------|-------------|
| `--bk-reviews-text` | `#0f172a` | Reviews text color |
| `--bk-reviews-bg` | `#ffffff` | Reviews card background |
| `--bk-reviews-border` | `#e2e8f0` | Reviews card border color |
| `--bk-reviews-primary` | `#1e40af` | Reviews link color |

---

## Booking Flow

```
1. Service Select
   └── customer picks one or more services

2. Quote Form
   └── customer selects pricing dimensions (size, area, quantity, etc.)
       live price updates as they make selections

3. Date Picker
   └── calendar showing available dates
       time slot picker for the selected date

4. Customer Info
   └── name, email, phone, address
       any custom fields configured for this business

5. Payment  (skipped if Stripe not connected)
   └── Stripe Card Element
       deposit or full amount depending on business config

6. Confirmation
   └── booking ID, summary, confirmation email sent
```

---

## Custom Events

The widget dispatches DOM events that bubble out of the Shadow DOM (`bubbles: true, composed: true`). Listen on `document` or any ancestor element.

```js
document.addEventListener('bookkit:booking-confirmed', (e) => {
  console.log('Booking confirmed:', e.detail);
});
```

### Event Reference

| Event | Fired when | `detail` shape |
|-------|-----------|----------------|
| `bookkit:config-loaded` | Widget config fetched | `{ businessName: string }` |
| `bookkit:quote-calculated` | Quote recalculated | `{ total: number; lineItems: Array<{ label: string; amount: number; type: string }> }` |
| `bookkit:step-changed` | Customer moves to a new step | `{ step: string }` |
| `bookkit:date-selected` | Date or time slot selected | `{ date: string; time?: string }` |
| `bookkit:booking-confirmed` | Booking successfully created | `{ bookingId: string; total: number; service: string; date: string; time: string }` |
| `bookkit:lead-submitted` | Lead form submitted (no-Stripe mode) | `{ name: string; email: string }` |
| `bookkit:reviews-loaded` | Reviews widget loaded | `{ avgRating: number; count: number }` |

### Examples

**Fire a GA4 event on booking:**
```js
document.addEventListener('bookkit:booking-confirmed', (e) => {
  gtag('event', 'purchase', {
    transaction_id: e.detail.bookingId,
    value: e.detail.total,
    currency: 'USD',
  });
});
```

**Push to dataLayer on quote:**
```js
document.addEventListener('bookkit:quote-calculated', (e) => {
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: 'quotelab_quote_calculated',
    quote_total: e.detail.total,
  });
});
```

---

## Reviews Widget

Embed a standalone reviews display (no booking flow):

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-component="reviews"
  async
></script>
```

This renders a paginated list of reviews with star ratings and business response. Fires the `bookkit:reviews-loaded` event with aggregate stats when loaded.

---

## Performance

| Asset | Size (gzipped) | Notes |
|-------|---------------|-------|
| `embed.js` (loader) | < 3 KB | Blocking budget — loads async, defers widget creation |
| `widget.js` (main bundle) | < 40 KB | Lazy-loaded after loader runs |

- **Stripe.js** is loaded lazily only when the customer reaches the payment step
- **Floating/modal** mode defers widget creation until the button is clicked
- Shadow DOM ensures the widget's styles are fully isolated from the host page
