# Platform Guides

How to add the BookingMachine widget to common website platforms.

---

## WordPress

### Theme (functions.php or child theme)

Add the script to your theme's footer:

```php
function quotelab_embed() {
  echo '<script src="https://bookingmachine.io/embed.js" data-business="your-slug" async></script>';
}
add_action('wp_footer', 'quotelab_embed');
```

### Block Editor (Gutenberg)

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

### Elementor

1. Drag an **HTML** widget onto the page
2. Paste the embed script into the HTML field
3. Click **Update**

### Divi

1. Add a **Code** module to your page
2. Paste the embed script
3. Save

---

## Wix

1. Open the page in the Wix Editor
2. Click **Add** → **Embed** → **Custom Code** (or **HTML iFrame**)
3. Select **Embed Code**
4. Paste the embed script:

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

5. Set the element to the desired height (at least 600px for inline mode)
6. Publish

> **Note:** Wix sandboxes custom code in an iframe. The widget will render correctly but custom events won't bubble to the parent page. Use the [API](api-reference.md) directly if you need to track conversions in Wix analytics.

---

## Squarespace

### Code Injection (site-wide)

1. Go to **Settings** → **Advanced** → **Code Injection**
2. Paste the embed script in the **Footer** field

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

### Code Block (single page)

1. Edit the page in Squarespace
2. Add a **Code** block where you want the widget
3. Paste the embed script
4. Switch to **Preview** to confirm it renders

---

## Webflow

### Project-wide (Webflow Designer)

1. Open your project in the Webflow Designer
2. Go to **Project Settings** → **Custom Code**
3. Paste the embed script in the **Footer Code** field

```html
<script
  src="https://bookingmachine.io/embed.js"
  data-business="your-slug"
  async
></script>
```

### Single page (Embed element)

1. Add an **Embed** element to the page
2. Paste the embed script into the HTML field
3. Save and publish

> **Tip:** For inline mode, wrap the embed in a `<div>` and set its minimum height to avoid layout shift while the widget loads.

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

For a floating button on every page, add the script to a shared layout file or footer partial.

---

## iframe Fallback

If the platform enforces a strict Content Security Policy that blocks external scripts, use an iframe pointing to the hosted booking page:

```html
<iframe
  src="https://bookingmachine.io/book/your-slug"
  width="100%"
  height="700"
  frameborder="0"
  style="border: none; border-radius: 8px;"
></iframe>
```

Replace `your-slug` with your business slug.

> The iframe approach works everywhere but custom events won't fire into the parent page, and you lose the Shadow DOM CSS isolation advantage. Use it only as a fallback.
