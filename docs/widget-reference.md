# Widget Reference

Complete reference for the BookingMachine embed widget.

---

## Embed Snippet

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-widget="your-widget"
  data-mode="inline"
  async
></script>
```

The dashboard builds this snippet for you with your own values filled in: open the **Widget** page and click **Embed**.

The widget talks to the host that `embed.js` was loaded from, so load the script from `bookingmachine.io` (or from your custom domain, as the dashboard snippet does), not from a copy hosted elsewhere.

---

## Data Attributes

| Attribute | Required | Default | Description |
|-----------|----------|---------|-------------|
| `data-business` | Yes | | Your business slug. It is pre-filled in the snippet in the Widget page's Embed dialog, and it is the last part of your booking link (`bookingmachine.io/book/your-slug`) |
| `data-mode` | No | `inline` | Display mode: `inline`, `floating`, or `modal`. Any other value renders nothing |
| `data-widget` | No | primary widget | Widget slug: loads one specific widget configured in the dashboard. Without it the primary widget loads |
| `data-location` | No | widget's default location | A location slug or id to start on, or `none` to skip locations |
| `data-service` | No | | A service id to start on, for "Book this service" buttons. Ignored if the widget does not offer that service |
| `data-remember` | No | | Set to `off` to stop the widget remembering a customer's details on the device (for a shared tablet or kiosk) |
| `data-source` | No | `widget` | Attribution string passed to bookings and leads (e.g. `homepage`, `landing-page`) |
| `data-primary-color` | No | | Fallback hex color, used only when the business has no brand color saved. It does not override the colors set in the dashboard |

Renaming the business changes its slug. Copy the snippet again after a rename.

### Colors and design

The widget's colors, corners, font and header come from the dashboard: **Settings → Brand** for the logo and brand colors, and **Widget Setup** (the Widget page) for the form's design. Change them there and every embed updates, with no change to the snippet.

---

## Display Modes

### `inline` (default)

The widget renders at the location of the script tag, expanding vertically as the customer progresses through steps. No fixed height is needed. Best for dedicated booking pages.

```html
<script src="https://bookingmachine.io/embed.js" data-business="your-slug" async></script>
```

### `floating`

Renders a fixed **Book Now** button in the bottom-right corner. Clicking the button opens the widget in a panel above it. The widget is not created until the button is clicked.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="floating"
  async
></script>
```

### `modal`

Renders a **Book Now** button in the page, where the snippet is pasted (not in the corner). Clicking it opens the widget in a centered overlay with a backdrop. Clicking the backdrop closes it.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="modal"
  async
></script>
```

### Both `floating` and `modal`

- On screens 640px wide or narrower the panel opens full screen.
- The panel has a close button, and the Escape key closes it.
- The loader adds `window.BookingMachine` so your own buttons can drive the panel:

```js
document.querySelector('#my-book-button').addEventListener('click', () => {
  window.BookingMachine.open();
});

// and to close it
window.BookingMachine.close();
```

`window.BookingMachine` exists only in `floating` and `modal` modes, once `embed.js` has run.

---

## CSS Custom Properties

The widget uses Shadow DOM, so host page styles don't affect it. The supported way to change its look is the dashboard (see [Colors and design](#colors-and-design)).

The widget reads these custom properties on the `<bookkit-widget>` element:

| Property | Default | Description |
|----------|---------|-------------|
| `--bk-primary` | `#1e40af` | Primary brand color (buttons, highlights) |
| `--bk-accent` | `#3b82f6` | Accent color |
| `--bk-bg` | `#ffffff` | Background |
| `--bk-text` | `#0f172a` | Text color |
| `--bk-muted` | `#64748b` | Secondary text |
| `--bk-border` | `#e2e8f0` | Borders |
| `--bk-radius` | `8px` | Corner radius of buttons and boxes |
| `--bk-item-radius` | `8px` | Corner radius of selectable items |
| `--bk-card-radius` | `12px` | Corner radius of the widget card |
| `--bk-success` | `#16a34a` | Success color |
| `--bk-error` | `#dc2626` | Error color |
| `--bk-font` | system font stack | Font family |

The widget also sets button and header gradient properties (`--bk-btn-gradient-from`, `--bk-btn-gradient-to`, `--bk-btn-gradient-angle`, `--bk-gradient-from`, `--bk-gradient-to`, `--bk-gradient-angle`) and calendar colors (`--bk-on-primary`, `--bk-day-ink`, `--bk-day-tint`, `--bk-day-tint-hover`, `--bk-day-muted`) from the saved design.

What you can and cannot override from the host page:

- **`:root` does not work.** The widget declares these properties on itself, so a value set on `:root` never reaches it. The one exception is the floating **Book Now** button, which sits in your page and reads `--bk-primary`.
- **A rule on `bookkit-widget` works only for properties the dashboard design has not set.** Once its configuration loads, the widget writes the saved design onto itself as inline styles, and those win over a normal stylesheet rule. For most accounts that includes `--bk-primary` and `--bk-accent`.
- **To force a value, use `!important`:**

```css
bookkit-widget {
  --bk-primary: #1a6b3c !important;
  --bk-accent: #f59e0b !important;
}
```

For the reviews widget (set on `bookkit-reviews` or on `:root`):

| Property | Default | Description |
|----------|---------|-------------|
| `--bk-reviews-text` | `#0f172a` | Reviews text color |
| `--bk-reviews-bg` | `#ffffff` | Reviews card background |
| `--bk-reviews-border` | `#e2e8f0` | Reviews card border color |
| `--bk-reviews-primary` | `#1e40af` | Reviews link color |

For the review form (set on `bookkit-review-form` or on `:root`):

| Property | Default | Description |
|----------|---------|-------------|
| `--bk-form-text` | `#0f172a` | Form text color |
| `--bk-form-bg` | `#ffffff` | Form background |
| `--bk-form-border` | `#e2e8f0` | Form border color |
| `--bk-form-primary` | `#2563eb` | Form button and highlight color |

---

## Booking Flow

The steps depend on how the widget is set up in the dashboard. A typical booking widget runs:

```
1. Service Select
   └── customer picks one or more services

2. Quote Form  (only if the services have options to choose)
   └── customer selects pricing options (size, area, quantity, etc.)
       live price updates as they make selections

3. Date and Time
   └── calendar showing available dates
       time slot picker for the selected date

4. Customer Info
   └── contact details
       any custom questions configured for this business

5. Payment  (only if payments are connected and this widget collects payment)
   └── Stripe Card Element
       deposit or full amount depending on business config

6. Confirmation
   └── booking summary, confirmation email sent
```

Variations:

- **Order of steps.** The widget can be set to ask for the date first (calendar-first), then the service.
- **Extra steps.** A location picker (more than one location), a staff picker, a photo upload step and a terms acceptance step appear when they are switched on.
- **No payment.** Without the payment step the widget still creates a real booking; nothing is charged.
- **Quote mode.** A widget in quote mode has no time picker or payment. It ends with a lead form and fires `bookkit:lead-submitted`. A widget also runs this way while the business has bookings paused.

The step names the widget reports in `bookkit:step-changed` are: `service-select`, `location-select`, `quote-form`, `staff-picker`, `date-overview`, `date-picker`, `time-picker`, `photo-upload`, `customer-info`, `terms-acceptance`, `payment`, `confirmation`, `lead-capture`, `success`, `error`.

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
| `bookkit:config-loaded` | Widget config fetched | `{ businessName: string; currency: string; trackingConfig: object \| null }` |
| `bookkit:quote-calculated` | Quote recalculated. Fires on every recalculation (each option change, each date pick), not once per quote | `{ total: number; lineItems: Array<{ label: string; amount: number; type: string }> }` |
| `bookkit:step-changed` | Customer moves to a new step. Not fired for the step the widget opens on | `{ step: string; index: number; total: number; flowOrder: string[] }` |
| `bookkit:date-selected` | Date or time slot selected | One of: `{ date }`, `{ date, time }`, `{ date, checkOutDate, nights }` (stays), `{ date, stage: 'overview' }` (calendar-first day pick) |
| `bookkit:customer-info-submitted` | Customer completes the contact details step of a booking | none |
| `bookkit:booking-confirmed` | Booking created and confirmed | `{ bookingId: string; total: number; service: string; date: string; time: string }` |
| `bookkit:booking-pending` | Booking created on a widget where the business confirms bookings by hand. Fired instead of `booking-confirmed` | Same as `booking-confirmed` |
| `bookkit:lead-submitted` | Lead form submitted (quote mode) | `{ name: string; email: string }` |
| `bookkit:reviews-loaded` | Reviews widget loaded its reviews | `{ avgRating: number; count: number }` |
| `bookkit:review-submitted` | Review form submitted | `{ rating: number }` |

Notes on the payloads:

- `total` and line item `amount` are in the business's currency, in whole units (e.g. `85.5`), not cents. The currency code is in `bookkit:config-loaded`.
- `total` in `booking-confirmed` can be `undefined` on some card-payment paths. Guard for it.
- `service` is the selected service names joined with `, `.
- Line item `type` is one of `service`, `multiplier`, `addon`, `surcharge`, `discount`, `package_discount`, `recurring_discount`, `voucher_discount`.

### Examples

**Fire a GA4 event on booking:**
```js
let bmCurrency = 'USD';
document.addEventListener('bookkit:config-loaded', (e) => {
  if (e.detail.currency) bmCurrency = e.detail.currency.toUpperCase();
});

document.addEventListener('bookkit:booking-confirmed', (e) => {
  gtag('event', 'purchase', {
    transaction_id: e.detail.bookingId,
    value: e.detail.total ?? 0,
    currency: bmCurrency,
  });
});
```

If you have set a GA4, Tag Manager or Meta Pixel id in **Settings → Tracking**, the widget already sends these events for you. See [analytics.md](analytics.md) before adding your own.

**Push to dataLayer on quote:**
```js
document.addEventListener('bookkit:quote-calculated', (e) => {
  window.dataLayer = window.dataLayer || [];
  window.dataLayer.push({
    event: 'bookingmachine_quote_calculated',
    quote_total: e.detail.total,
  });
});
```

---

## Reviews Widget

Embed a standalone reviews display (no booking flow). It has its own loader, `reviews-embed.js`:

```html
<script
  src="https://bookingmachine.io/reviews-embed.js"
  data-business="your-slug"
  async
></script>
```

| Attribute | Required | Default | Description |
|-----------|----------|---------|-------------|
| `data-business` | Yes | | Your business slug |
| `data-mode` | No | `inline` | `inline` shows the reviews; `badge` shows only the average rating and review count, linking to the full reviews page |
| `data-count` | No | `5` | How many reviews to show, 1 to 10 |
| `data-theme` | No | `light` | `light` or `dark` |

Inline mode renders the average rating, up to `data-count` reviews with star ratings and the business's responses, and a "See all reviews" link. It is not paginated. Fires the `bookkit:reviews-loaded` event with aggregate stats when loaded.

---

## Review Form

Embed a form where customers leave a review. It has its own loader, `review-form-embed.js`:

```html
<script
  src="https://bookingmachine.io/review-form-embed.js"
  data-business="your-slug"
  async
></script>
```

| Attribute | Required | Default | Description |
|-----------|----------|---------|-------------|
| `data-business` | Yes | | Your business slug |
| `data-theme` | No | `light` | `light` or `dark` |
| `data-allow-photos` | No | `true` | Set to `false` to hide photo upload |

Fires `bookkit:review-submitted` with `{ rating }` when a review is sent.

---

## Performance

| Asset | Size (gzipped) | Notes |
|-------|---------------|-------|
| `embed.js` (loader) | about 3.3 KB | Loads async, defers widget creation |
| `widget.js` (main bundle) | about 63 KB | Lazy-loaded after loader runs |

- **Stripe.js** is loaded lazily only when the customer reaches the payment step
- **Floating/modal** mode defers loading the main bundle until the button is clicked
- Shadow DOM ensures the widget's styles are fully isolated from the host page
