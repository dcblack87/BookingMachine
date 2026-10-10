<p align="center"><img src="brand/mark.svg" width="72" height="72" alt="The BookingMachine mark: a calendar page with a teal header and one teal day picked out"></p>

<h1 align="center">The booking form</h1>

<p align="center"><strong>Quote first, then book. On any site, from one line of code.</strong></p>

<p align="center">
  <a href="https://bookingmachine.io/features/widget">Widget</a> ·
  <a href="https://bookingmachine.io/features/pricing-engine">Pricing</a> ·
  <a href="https://bookingmachine.io/help">Help</a> ·
  <a href="../README.md">Back to the tour</a>
</p>

The booking form is what your customers use. It shows your services, works out a real price from the options they choose, offers only the times you are free, and takes the booking. It is the same form whether it sits on your website, behind a link or a QR code, or on the site BookingMachine hosts for you.

![A customer books a portrait session: picks the service, watches the price change as they choose options, picks a day and a time, and is confirmed. The booking then shows in the owner's calendar and dashboard](gifs/hero.gif)

Every screen below is from a demo business called Bright Focus Photography, filled with made-up customers and numbers. Nothing here is a mock-up.

## What the customer does, step by step

<table>
  <tr>
    <td width="50%"><img src="screenshots/booking/services.webp" alt="The Bright Focus Photography booking page: a Book Now form headed Select a service, listing Mini Session from 150 dollars and Portrait Session from 300 dollars with a line about each"></td>
    <td width="50%"><img src="screenshots/booking/quote.webp" alt="The Customize your quote step: session length set to 2 hours, location set to Studio, a printed album ticked under Add extras, and an estimated total with each line of the price under it"></td>
  </tr>
  <tr>
    <td>One. Pick a service. Each one shows its starting price and how long it takes.</td>
    <td>Two. Choose the options. The total and its breakdown change with every choice.</td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/booking/time.webp" alt="The Pick a date and time step: the service and its price at the top, the chosen day, and its times as buttons with the taken ones struck through"></td>
    <td width="50%"><img src="screenshots/booking/booked.webp" alt="The confirmation: a green tick, Booking Confirmed, and the service, date, time, duration and total, with buttons to add it to a calendar"></td>
  </tr>
  <tr>
    <td>Three. Pick a day and a time. Times that are taken cannot be picked.</td>
    <td>Four. After their name and contact details, the booking is confirmed on the spot.</td>
  </tr>
</table>

If the business takes payment online, a card step sits between the details and the confirmation. The demo business here does not, so its bookings confirm straight away.

<p align="center"><img src="screenshots/booking/phone-form.webp" width="300" alt="The booking page for Paws and Claws Grooming on a phone: an orange Book Now form listing Bath and Brush, Full Groom and Puppy Intro with their prices"></p>

<p align="center">The same form on a phone, in another business's colours.</p>

## Building what it shows

Everything on the form comes from four screens in the dashboard.

![Building a service in the dashboard: a new service called Standard Clean gets a base price, a price variable called Bedrooms gets three options, and each option gets its own price while the customer preview updates beside it](gifs/build.gif)

<table>
  <tr>
    <td width="50%"><img src="screenshots/build/services.webp" alt="The Services and Pricing screen: Mini Session, Portrait Session, Branding Session and Wedding Coverage with their prices, lengths, variables and add-ons, beside a live customer preview of the booking form"></td>
    <td width="50%"><img src="screenshots/build/price-variables.webp" alt="The Price variables screen: Session length and Location, each a dropdown with three options, and the editor for Session length open on the right with its label, input type and options"></td>
  </tr>
  <tr>
    <td>Services and Pricing. The preview on the right is the real form.</td>
    <td>Price variables. A question whose answer changes the price.</td>
  </tr>
  <tr>
    <td width="50%"><img src="screenshots/build/hours.webp" alt="Business Hours in settings: a switch for each day of the week with its opening and closing times"></td>
    <td width="50%"><img src="screenshots/build/widget-setup.webp" alt="Widget Setup: the widget name, its description and a choice of Booking, Order or Quote Only on the left, and a preview of the form on a sample page on the right"></td>
  </tr>
  <tr>
    <td>Business Hours. The form only offers times inside them.</td>
    <td>Widget Setup. Its wording, its look and what kind of form it is.</td>
  </tr>
</table>

## How the price is worked out

- **A base price** for the service.
- **Price variables.** Each option of a variable gets its own price, and a service can use several variables at once.
- **Extras.** Add-ons the customer can tick, each with its own price.
- **Rules.** Seasonal prices and prices by the night or by the hour, for the businesses that need them.
- **The same sum on both sides.** The form works the price out as the customer chooses, and the server works it out again when the booking is made, so the price shown is the price charged.

## Putting it on a site

```html
<script src="https://bookingmachine.io/embed.js" data-business="your-slug" async></script>
```

![The share panel in Widget Setup with the booking link, the embed code and a QR code, then the form embedded on a photographer's own site, the same form on a phone, and a hosted site for a lawn care business](gifs/share.gif)

<table>
  <tr>
    <td width="50%"><img src="screenshots/build/share.webp" alt="Share this widget, in Widget Setup: a booking link with a Copy link button, the embed code with Inline, Floating Bubble and Modal display choices, and a QR code with a Download PNG button"></td>
    <td>
      <strong>Inline</strong> draws the form where the snippet sits.<br><br>
      <strong>Floating Bubble</strong> adds a button to the corner of every page.<br><br>
      <strong>Modal</strong> opens the form over the page when a button is pressed.<br><br>
      The form keeps its styles to itself, so the page around it cannot change how it looks.
    </td>
  </tr>
</table>

## The guides

**Start here:** [Quickstart](quickstart.md) · [Platform guides](platform-guides.md)

**Go further:** [Widget reference](widget-reference.md) · [Analytics](analytics.md) · [API reference](api-reference.md)

**In the help centre:** [bookingmachine.io/help](https://bookingmachine.io/help)

<p align="right"><a href="../README.md">Back to the tour →</a></p>
