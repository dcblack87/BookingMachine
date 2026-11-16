# Platform Guides

How to add the BookingMachine widget to common website platforms.

The embed code for your own business, with the slug and widget filled in, is in the dashboard: open the **Widget** page and click **Embed**. The dialog has tabs for plain HTML, Wix and WordPress.

---

## WordPress

### BookingMachine plugin (recommended)

1. In WordPress, go to **Plugins → Add New** and search **BookingMachine**. Click **Install Now**, then **Activate**. The plugin is also at [wordpress.org/plugins/quotelab-io](https://wordpress.org/plugins/quotelab-io/).
2. Go to **Settings → BookingMachine** and paste your API key. Create the key in the BookingMachine dashboard under **Settings → Integrations**.
3. Enter your business slug and click **Verify Connection**.
4. Add the widget to a page with the shortcode, a block or a page builder element.

**Shortcodes:**

```
[bookingmachine]
[bookingmachine widget="your-widget" mode="inline"]
[bookingmachine_reviews count="5" theme="light" mode="inline"]
```

| Shortcode | Attribute | Values |
|-----------|-----------|--------|
| `[bookingmachine]` | `widget` | A widget slug. Defaults to the plugin's default widget |
| | `mode` | `inline` or `floating` |
| `[bookingmachine_reviews]` | `count` | 1 to 10, default 5 |
| | `theme` | `light` or `dark` |
| | `mode` | `inline` or `badge` |

**Blocks (Gutenberg):** BookingMachine Booking Widget, BookingMachine Reviews, BookingMachine Pricing Table.

**Page builders:** the plugin adds its own Elementor widget and WPBakery element.

**Site-wide button:** the plugin can show a floating Book Now button on every page.

The plugin has its own analytics bridge. See [analytics.md](analytics.md).

### Without the plugin

The plain embed script also works in WordPress.

#### Block Editor (Gutenberg)

1. Edit the page where you want the widget
2. Add a **Custom HTML** block
3. Paste the embed script

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

#### Elementor

1. Drag an **HTML** widget onto the page
2. Paste the embed script into the HTML field
3. Click **Update**

#### Divi

1. Add a **Code** module to your page
2. Paste the embed script
3. Save

#### Theme (functions.php or child theme)

To show a floating Book Now button on every page, add the script to your theme's footer. Use `data-mode="floating"` here: an inline widget in the footer would put the whole booking form at the bottom of every page.

```php
function bookingmachine_embed() {
  echo '<script src="https://bookingmachine.io/embed.js" data-business="your-slug" data-mode="floating" async></script>';
}
add_action('wp_footer', 'bookingmachine_embed');
```

---

## Wix

Wix uses an address, not the script. Copy it from the **Wix** tab of the Embed dialog, or build it yourself:

```
https://bookingmachine.io/wix-embed?slug=your-slug&widget=your-widget
```

1. In the Wix Editor, click **+ Add** and search for **Embed**
2. Add the **Embed Code** element to your page
3. Select the element and choose **Link** mode (not Code)
4. Paste the address above
5. Drag the element to the width you want and set the height to at least **700px**
6. Publish and test

> **Note:** Wix shows the widget inside an iframe. The widget renders correctly, but its custom events fire inside the frame and do not reach the parent page. Tracking ids set in **Settings → Tracking** run inside the frame with the widget.

### Wix app

BookingMachine also has a Wix app, described at [bookingmachine.io/wix](https://bookingmachine.io/wix):

1. Find BookingMachine in the Wix App Market and click **Add to Site**
2. The setup wizard in your Wix dashboard asks for your API key and business slug
3. Add the BookingMachine Booking Widget from the Wix Editor to a page, or pin it and enable "Show on all pages" for a site-wide Book Now button

The app also has a Reviews Widget.

---

## Squarespace

Squarespace only runs JavaScript on plans that include custom code. On the current plans that means Core and above; on older plans, Business and Commerce. On a plan without it, use the button method below.

### Code Block (single page)

1. Edit the page in Squarespace and click an insert point
2. Choose **Code** from the block menu. Set the type to **HTML** and switch off **Display Source**
3. Paste the embed script and save the page

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

The widget does not run inside the Squarespace editor, so the block looks empty there. Open the live page (a private browser window works) to see it.

### Code Injection (site-wide button)

To show a floating Book Now button across the whole site, paste the floating version of the code into **Code Injection**, in the **Footer** field. Code Injection is in your site settings under custom code.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="floating"
  async
></script>
```

### No custom code on your plan

Add a **Button** block, label it Book Now and link it to your BookingMachine booking link (`https://bookingmachine.io/book/your-slug`). Customers book on your hosted booking page. This works on every Squarespace plan.

---

## Webflow

Webflow runs custom code on paid site plans and paid Workspaces. On a free site, use the button method below.

### Single page (Code Embed element)

1. In the Webflow Designer, open the **Add** panel and drag a **Code Embed** element to where the booking form should sit
2. Paste the embed script into the editor that opens, then save and close
3. Publish

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

Custom code does not run on the Designer canvas, so the element shows a placeholder there. Publish the site and open the live page to see the widget.

### Site-wide button

To show a floating Book Now button across the site, open **Site settings**, go to **Custom code**, and paste the floating version of the code into the **Footer code** field. Publish for it to take effect.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="floating"
  async
></script>
```

### On a free Webflow site

Add a **Button** element, label it Book Now and set its link to your BookingMachine booking link (`https://bookingmachine.io/book/your-slug`). No custom code is involved, so it works on any plan.

---

## Shopify

You need a theme with a **Custom Liquid** section, which most current Shopify themes have. There is no BookingMachine app in the Shopify App Store; the embed code does not need one.

### Single page

1. In the Shopify admin, go to **Online Store → Pages** and add a page called Book or Services. Give it its own template if you want the widget on that page only
2. Go to **Online Store → Themes** and click **Customize**. Use the page selector at the top to open the page you created
3. Click **Add section**, choose **Custom Liquid**, paste the embed script into the field and save

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

### Site-wide button

To show a floating Book Now button across the store, add a **Custom Liquid** section to the footer group in the theme editor and paste in the floating version of the code. It then appears on every page that uses that footer.

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  data-mode="floating"
  async
></script>
```

### Without touching the theme

Add a link to your BookingMachine booking link (`https://bookingmachine.io/book/your-slug`) in the store navigation, or on a button in any section. Customers book on your hosted booking page.

Booking payments are taken by the widget through Stripe, separately from Shopify checkout.

---

## Custom HTML / Static Sites

Paste the script tag anywhere in the page body:

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Book Now</title>
</head>
<body>

  <h1>Schedule a Service</h1>

  <script
    src="https://bookingmachine.io/embed.js"
    data-business="your-slug"
    async
  ></script>

</body>
</html>
```

Inline mode grows to fit its content, so no fixed height is needed.

For a floating button on every page, add the script with `data-mode="floating"` to a shared layout file or footer partial.

---

## iframe Fallback

If the platform enforces a strict Content Security Policy that blocks external scripts, use an iframe. Point it at the embed address, not at the hosted booking page (`/book/your-slug`), which does not allow framing:

```html
<iframe
  src="https://bookingmachine.io/wix-embed?slug=your-slug&widget=your-widget"
  width="100%"
  height="700"
  frameborder="0"
  style="border: none; border-radius: 8px;"
></iframe>
```

Replace `your-slug` with your business slug and `your-widget` with the widget's slug. Leave `&widget=...` off to load the primary widget.

The framed page posts its height to the parent page as the widget grows, so you can size the iframe to fit:

```js
window.addEventListener('message', (e) => {
  if (e.origin !== 'https://bookingmachine.io') return;
  if (e.data && e.data.type === 'quotelab:resize') {
    document.querySelector('iframe').style.height = e.data.height + 'px';
  }
});
```

> The iframe approach is a fallback. The widget's custom events fire inside the frame and do not reach the parent page.
