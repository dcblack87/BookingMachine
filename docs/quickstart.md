# Quickstart

Get a client's BookingMachine widget live in about 10 minutes.

---

## 1. Create an account

Go to [bookingmachine.io](https://bookingmachine.io) and sign up with a name, business name, email and password, or with Google.

A short setup wizard follows. It asks for the country, timezone and currency, the first service, and opening hours, then publishes the booking page.

---

## 2. Set up the business profile

In the dashboard:

- **Settings → General**: business name, contact details, timezone, country, currency, and the address and service area
- **Settings → Brand**: logo and brand colors

The timezone is critical: all availability is computed in it.

---

## 3. Add services and pricing

A new account has no pre-made services. The setup wizard starts you with one, and you add the rest in the dashboard:

- **Services**: add services, set base prices, switch a service on or off
- **Price variables**: the options that change a price (e.g. vehicle size, property square footage)
- **Add-ons**: optional extras

Live pricing is calculated in the widget as the customer makes selections, with no server round-trip.

---

## 4. Set up payments (or skip)

Taking payment in the widget needs three things:

1. **A paid plan.** The free plan does not include payments; **Settings → Payments** shows an upgrade screen instead.
2. **An approved application.** On a paid plan, fill in the short application on **Settings → Payments**. It is reviewed by hand, usually within a business day, and you are emailed the result.
3. **A Stripe account.** Once approved, **Connect with Stripe** appears on the same page and starts Stripe's onboarding.

Then switch on payment collection for the widget on the **Widget** page.

**If you skip this step**, the widget still takes real bookings: customers get a price, pick a time and book, and no payment is collected. Bookings work as normal while an application is under review. You can add payments later without changing anything on the website.

---

## 5. Get the embed code

Open the **Widget** page and click **Embed**. The dialog shows the snippet with the business slug and widget already filled in, plus the booking link.

The slug looks like `acme-detailing` or `sunrise-lawn-care`. It is also the last part of the booking link (`bookingmachine.io/book/acme-detailing`). Renaming the business changes the slug, so copy the snippet again after a rename.

---

## 6. Add the embed script

Paste the snippet into the client's website where you want the widget to appear:

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

Replace `your-slug` with the slug from step 5, or use the snippet from the Embed dialog as it is.

The script is about 3 KB gzipped and loads the widget bundle (about 63 KB gzipped) lazily. It won't block page rendering.

**Default behavior:** the widget renders inline at the script tag's location.

For floating or modal modes, see [widget-reference.md](widget-reference.md#display-modes). For WordPress, Wix and other site builders, see [platform-guides.md](platform-guides.md).

---

## 7. Test end-to-end

1. Open the client's website (or a local preview)
2. Select a service and confirm the pricing options appear
3. Get a quote and confirm the price matches what's configured in the dashboard
4. Pick a date and time
5. Fill in customer info
6. Complete the booking
7. Confirm the booking appears in the dashboard under **Bookings**
8. Confirm the customer receives a confirmation email

---

## 8. Optional next steps

**Colors and design:** Set the logo and brand colors in **Settings → Brand** and the form's design in **Widget Setup** on the Widget page. Every embed picks the changes up; the snippet stays the same. The `data-primary-color` attribute is only a fallback for a business with no brand color saved, so it does not change the color of a normal account.

**Choose a display mode:**
```html
<!-- Floating Book Now button in the corner -->
<script ... data-mode="floating" async></script>

<!-- Book Now button where the snippet is pasted, opening a popup -->
<script ... data-mode="modal" async></script>
```

**Track bookings in GA4:** See [analytics.md](analytics.md).

**More than one widget:** Use `data-widget` to load a specific widget created in the dashboard. Without it the primary widget loads.
