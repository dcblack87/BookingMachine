<p align="center">
  <a href="https://bookingmachine.io">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="docs/brand/mark-dark.svg">
      <img src="docs/brand/mark.svg" width="88" height="88" alt="The BookingMachine mark: a calendar page with a teal header and one teal day picked out">
    </picture>
  </a>
</p>

<h1 align="center">BookingMachine</h1>

<p align="center"><strong>Get booked, paid and reviewed on autopilot.</strong></p>

<p align="center">
  <a href="https://bookingmachine.io">Site</a> ·
  <a href="https://bookingmachine.io/features">Features</a> ·
  <a href="https://bookingmachine.io/pricing">Pricing</a> ·
  <a href="https://bookingmachine.io/help">Help</a> ·
  <a href="https://bookingmachine.io/wordpress">WordPress</a> ·
  <a href="https://bookingmachine.io/wix">Wix</a> ·
  <a href="https://bookingmachine.io/blog">Blog</a>
</p>

<br>

![A customer books a portrait session: picks the service, watches the price change as they choose options, picks a day and a time, and is confirmed. The booking then shows in the owner's calendar and dashboard, and a review from a finished job shows on the public reviews page](docs/gifs/hero.gif)

BookingMachine is booking, quoting and payments for local service businesses: detailers, cleaners, groomers, photographers, landscapers and anyone else who sells their time. You build your services and prices once. Customers then see a live price, pick a time and book, on your own website, from a link, from a QR code or on a free site BookingMachine hosts for you. After the job, a review request goes out without you lifting a finger.

It runs at [bookingmachine.io](https://bookingmachine.io) and is free to start. This page is the tour. The step-by-step guides are in the [help centre](https://bookingmachine.io/help), and the [developer docs](#for-developers) for the embed and the API are in this repository.

## Build it. Share it. Get paid.

<table>
  <tr>
    <th align="left" width="22%">Step</th>
    <th align="left">What you do</th>
    <th align="left">What the customer sees</th>
    <th align="left">Links</th>
  </tr>
  <tr>
    <td><strong>Build it</strong></td>
    <td>Add your services, the options that change the price, your extras and your hours.</td>
    <td>A booking form in your colours, with a price that moves as they choose.</td>
    <td><a href="https://bookingmachine.io/features/pricing-engine">Pricing</a> · <a href="docs/booking-form.md">Tour</a></td>
  </tr>
  <tr>
    <td><strong>Share it</strong></td>
    <td>Paste one line into your website, send the link, print the QR code or switch on the hosted site.</td>
    <td>The same form wherever they find you, with nothing to install and no account to make.</td>
    <td><a href="https://bookingmachine.io/features/widget">Widget</a> · <a href="https://bookingmachine.io/link">Link</a> · <a href="https://bookingmachine.io/microsite">Site</a></td>
  </tr>
  <tr>
    <td><strong>Get paid</strong></td>
    <td>Connect Stripe and choose a deposit or the full amount. Bookings, customers and money land in one dashboard.</td>
    <td>A confirmation the moment they book, and a review request after the job.</td>
    <td><a href="https://bookingmachine.io/features/payments">Payments</a> · <a href="docs/dashboard.md">Tour</a></td>
  </tr>
</table>

## How it works

1. **Add what you sell.** A service has a name, a base price and a length. Price variables (vehicle size, room count, session length) and extras change the price, and you set by how much.
2. **Set when you work.** Opening hours, closed days and holidays decide which times a customer is offered. A time that is taken is never offered twice.
3. **Put the form where your customers are.** One script tag on any website, a booking link, a QR code, a WordPress plugin, a Wix app, or the hosted site.
4. **Do the job.** Each booking makes a customer record. Mark the job complete and the review request sends itself.

## The booking form

**Quote first, then book.** The customer picks a service and sees a real price before they give a single detail. Each option they change moves the total, and the breakdown underneath shows why.

<table>
  <tr>
    <td width="33%"><img src="docs/screenshots/booking/services.webp" alt="The Bright Focus Photography booking page: a Book Now form listing Mini Session, Portrait Session and Branding Session, each with a from price and a length"></td>
    <td width="33%"><img src="docs/screenshots/booking/quote.webp" alt="The Customize your quote step: session length set to 2 hours, a printed album ticked, and an estimated total with each line of the price listed under it"></td>
    <td width="33%"><img src="docs/screenshots/booking/time.webp" alt="The Pick a date and time step: the chosen day with its free times as buttons and the times already taken struck through"></td>
  </tr>
  <tr>
    <td>Every service shows its starting price and how long it takes.</td>
    <td>Options and extras change the total as they are chosen.</td>
    <td>Only the times that are really free can be picked.</td>
  </tr>
</table>

<p align="right"><a href="docs/booking-form.md">The booking form, step by step →</a></p>

![Building a service in the dashboard: a new service called Standard Clean gets a base price, a price variable called Bedrooms gets three options, and each option gets its own price while the customer preview updates beside it](docs/gifs/build.gif)

**Build a service in a few minutes.** Name it, price it, and add the variables that change the price. The customer preview beside the editor is the real form, so what you see is what they get.

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/build/services.webp" alt="The Services and Pricing screen: four services with their prices, lengths, variables and add-ons, beside a live customer preview of the booking form"></td>
    <td width="50%"><img src="docs/screenshots/build/price-variables.webp" alt="The Price variables screen: Session length and Location, each a dropdown with three options, with the editor for one of them open on the right"></td>
  </tr>
  <tr>
    <td>Services on the left, the form your customers will see on the right.</td>
    <td>A price variable is a question whose answer changes the price.</td>
  </tr>
</table>

## Four ways to share it

**One form, wherever your customers find you.** The embed is a single script tag. It draws the form inside your page with its own isolated styles, so your site's CSS cannot break it and it cannot break your site. No iframe and no redirect.

```html
<script src="https://bookingmachine.io/embed.js" data-business="your-slug" async></script>
```

![The share panel in Widget Setup with the booking link, the embed code and a QR code, then the form embedded on a photographer's own site, the same form on a phone, and a hosted site for a lawn care business](docs/gifs/share.gif)

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/build/share.webp" alt="Share this widget, in Widget Setup: a booking link with a Copy link button, the embed code with Inline, Floating Bubble and Modal display choices, and a QR code with a Download PNG button"></td>
    <td width="50%"><img src="docs/screenshots/build/widget-setup.webp" alt="Widget Setup: the widget name, description and type on the left, and a preview of the form on a sample page on the right"></td>
  </tr>
  <tr>
    <td>The link, the embed code and the QR code are all in one panel.</td>
    <td>Name the form, choose how it behaves and see it before it goes live.</td>
  </tr>
</table>

- **On your website.** Inline in the page, as a floating button, or in a pop-up. Guides for [WordPress, Wix, Squarespace, Webflow and plain HTML](docs/platform-guides.md).
- **As a link.** A booking page of your own to put in a bio, a text or an email. [More on the booking link](https://bookingmachine.io/link).
- **As a QR code.** For flyers, cards, vans and shop windows. It opens the same booking page.
- **As a whole site.** A hosted site with your services, reviews and a Book Now button. [More on the hosted site](https://bookingmachine.io/microsite).

## Run the day

**Every booking, customer and payment in one place.** The dashboard opens on today: what is booked, what has been earned, what is still owed and what needs a reply. Each booking carries its price breakdown, its payment status, its photos and its notes.

<table>
  <tr>
    <td width="33%"><img src="docs/screenshots/run/overview.webp" alt="The dashboard overview: tiles for revenue, bookings, average ticket, customers and the amount outstanding, above a month calendar and a list of things that need attention"></td>
    <td width="33%"><img src="docs/screenshots/run/calendar.webp" alt="Bookings on the Calendar tab: a month grid with each booking shown on its day with the time, the customer and the team member"></td>
    <td width="33%"><img src="docs/screenshots/run/booking.webp" alt="One booking: the customer and service at the top with a Start Job button, then the date, time and team member, the price breakdown and the payment status"></td>
  </tr>
  <tr>
    <td>The overview: money in, money owed and what needs attention.</td>
    <td>The calendar shows who is booked, when and with whom.</td>
    <td>A booking holds everything about one job.</td>
  </tr>
  <tr>
    <td width="33%"><img src="docs/screenshots/run/bookings.webp" alt="Bookings as a list: date and time, customer, service, staff, total, payment and status for each, with a Create Booking button"></td>
    <td width="33%"><img src="docs/screenshots/run/customers.webp" alt="The Customers screen: each customer with their email, phone, tags such as new and high-value, what they have spent and when they last booked"></td>
    <td width="33%"><img src="docs/screenshots/build/hours.webp" alt="Business Hours in settings: a switch and opening and closing times for each day of the week"></td>
  </tr>
  <tr>
    <td>The same bookings as a list, with payment and status.</td>
    <td>Every booking makes or updates a customer record.</td>
    <td>Hours decide which times the form offers.</td>
  </tr>
</table>

<p align="right"><a href="docs/dashboard.md">The dashboard tour →</a></p>

Also in the dashboard: [quotes](https://bookingmachine.io/features/quotes) a customer can accept, [invoices](https://bookingmachine.io/features/invoicing), [recurring bookings](https://bookingmachine.io/features/recurring), [vouchers](https://bookingmachine.io/features/vouchers), [team members](https://bookingmachine.io/features/team-management) and [more than one location](https://bookingmachine.io/features/multi-location).

## Reviews on autopilot

**Finish the job and the review asks for itself.** Marking a booking complete schedules an email to the customer with a one-tap star rating. Reviews land in the dashboard, where you can reply, and show on a public reviews page and in a reviews widget you can embed on your own site.

![A job is started and marked complete in the dashboard, the review request email the customer receives, the public reviews page with the new review, the reviews widget on another site, and the Reviews screen in the dashboard](docs/gifs/reviews.gif)

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/reviews/reviews-page.webp" alt="The public reviews page for Evergreen Lawn Care: a five-star average, the count of reviews by star, and a verified review with photos from the job"></td>
    <td width="50%"><img src="docs/screenshots/reviews/dashboard.webp" alt="The Reviews screen in the dashboard: the average rating and star counts, filters by star and by needs response, and the newest review with its photos and video"></td>
  </tr>
  <tr>
    <td>Reviews are public on a page of their own.</td>
    <td>Read, reply and publish from the dashboard.</td>
  </tr>
</table>

<p align="right"><a href="docs/reviews-and-site.md">Reviews and the hosted site →</a></p>

## A site of your own

**No website? BookingMachine hosts one.** Each business gets a site with its services, its reviews, a gallery, a contact page and a Book Now button that opens the same booking form. It can run on your own domain.

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/site/home.webp" alt="The hosted site for Evergreen Lawn Care: a green banner with the headline A tidy lawn, without the weekend work, Book Now and Contact Us buttons and a five-star rating"></td>
    <td width="50%"><img src="docs/screenshots/site/services.webp" alt="The Our Services page of the hosted site: Lawn Mowing, Hedge Trimming and Seasonal Clean-up, each with a description, a length and a Book Now button"></td>
  </tr>
  <tr>
    <td>The home page of a hosted site, written and coloured in the dashboard.</td>
    <td>Every service has its own Book Now button.</td>
  </tr>
</table>

## Who it is for

Any business that sells a service by appointment, by quote or by the job. There is a page for each of these, with the pricing set-up that suits it:

[Dog grooming](https://bookingmachine.io/for/dog-grooming) · [House cleaning](https://bookingmachine.io/for/house-cleaning) · [Photography](https://bookingmachine.io/for/photography) · [Mobile detailing](https://bookingmachine.io/for/mobile-detailing) · [Personal training](https://bookingmachine.io/for/personal-training) · [Mobile beauty](https://bookingmachine.io/for/mobile-beauty) · [Landscaping](https://bookingmachine.io/for/landscaping) · [Pressure washing](https://bookingmachine.io/for/pressure-washing) · [Pet sitting](https://bookingmachine.io/for/pet-sitting) · [Pet boarding](https://bookingmachine.io/for/pet-boarding) · [Tutoring](https://bookingmachine.io/for/tutoring)

## For developers

The booking form is a web component loaded by one script tag. It fires events you can listen for, takes its colours from CSS custom properties, and talks to a public REST API you can call yourself.

| Guide | What it covers |
| --- | --- |
| [Quickstart](docs/quickstart.md) | From a new account to a live form on a site |
| [Widget reference](docs/widget-reference.md) | Embed attributes, display modes, CSS custom properties, events |
| [Platform guides](docs/platform-guides.md) | WordPress, Wix, Squarespace, Webflow and plain HTML |
| [Analytics](docs/analytics.md) | Google Analytics, Google Tag Manager, Meta Pixel and your own tracking |
| [API reference](docs/api-reference.md) | The public REST API: endpoints, shapes, errors and rate limits |

Found something wrong in a guide? [Open an issue](https://github.com/dcblack87/BookingMachine/issues).

## Free to start

- Make an account and build your form without a card.
- Paid plans add online payments and room for a bigger team.
- Your customers never need an account to book.

Plans and what each includes are on the [pricing page](https://bookingmachine.io/pricing).

## Questions

**Do I need a website?** No. Every business gets a booking link and a hosted site. If you do have a website, the form goes on it with one line.

**Will it work on my site builder?** The embed is plain HTML, so it works anywhere you can paste a snippet. There is a plugin for WordPress, an app for Wix and a guide for Squarespace and Webflow.

**How do I get paid?** Through Stripe, into your own account. You choose whether a booking takes a deposit or the full amount, or no payment at all.

**Can customers get a quote without booking?** Yes. A form can be set to take bookings, take orders or give a quote only.

More answers in the [help centre](https://bookingmachine.io/help).

<br>

<p align="center">
  <a href="https://bookingmachine.io">bookingmachine.io</a> ·
  <a href="https://bookingmachine.io/pricing">Pricing</a> ·
  <a href="https://bookingmachine.io/help">Help</a> ·
  <a href="https://bookingmachine.io/blog">Blog</a>
</p>

<p align="center">A <a href="https://dcblack.co.uk">DC Black</a> product, built by <a href="https://github.com/dcblack87">David Black</a>.<br>
© 2026 David Black. BookingMachine is commercial software. Every screenshot and film on this page is of a demo business filled with made-up customers and numbers, and the demo business in the films takes no card payment.</p>
