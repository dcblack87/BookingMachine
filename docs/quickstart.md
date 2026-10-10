# Quickstart

Get a client's BookingMachine widget live in about 10 minutes.

---

## 1. Create an account

Go to [bookingmachine.io](https://bookingmachine.io) and sign up. You can create the account yourself and transfer ownership later, or have the client do it directly.

---

## 2. Set up the business profile

In the dashboard, go to **Settings → Business Profile** and fill in:

- Business name and address
- Timezone (critical: all availability is computed in this timezone)
- Primary color (used as the widget's accent color)
- Logo (optional)

---

## 3. Review services and pricing

BookingMachine pre-configures a set of services based on the business type selected at signup. Go to **Services** to:

- Enable or disable services
- Adjust base prices
- Add pricing dimensions (e.g. vehicle size, property square footage)
- Add add-ons and packages

Live pricing is calculated in the widget as the customer makes selections, with no server round-trip.

---

## 4. Connect Stripe (or skip)

Go to **Settings → Payments** and click **Connect with Stripe**. This starts a Stripe Express onboarding flow, which takes about 5 minutes.

**If you skip this step**, the widget runs in lead-capture mode: customers can still get a quote and submit their contact info, but no payment is collected at booking. You can add Stripe later without changing anything on the website.

---

## 5. Find the business slug

Go to **Settings → Business Profile**. The slug is shown under the business name. It looks like `acme-detailing` or `sunrise-lawn-care`.

You'll use this in the embed script.

---

## 6. Add the embed script

Paste this snippet into the client's website where you want the widget to appear:

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

Replace `your-slug` with the slug from step 5.

The script is ~3KB and loads the widget bundle (~40KB) lazily. It won't block page rendering.

**Default behavior:** the widget renders inline at the script tag's location.

For floating or modal modes, see [widget-reference.md](widget-reference.md#display-modes).

---

## 7. Test end-to-end

1. Open the client's website (or a local preview)
2. Select a service and confirm the pricing options appear
3. Get a quote and confirm the price matches what's configured in the dashboard
4. Pick a date and time
5. Fill in customer info
6. Complete a test payment (use Stripe test card `4242 4242 4242 4242`)
7. Confirm the booking appears in the dashboard under **Bookings**
8. Confirm the customer receives a confirmation email

---

## 8. Optional next steps

**Custom theme color:**
```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-primary-color="#1a6b3c"
  async
></script>
```

**Choose a display mode:**
```html
<!-- Floating button in the corner -->
<script ... data-mode="floating" async></script>

<!-- Opens in a modal -->
<script ... data-mode="modal" async></script>
```

**Track bookings in GA4:** See [analytics.md](analytics.md).

**Multiple widgets on one page:** Use `data-widget` to target a specific widget configuration created in the dashboard.
