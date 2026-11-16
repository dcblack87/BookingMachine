# MCP server

The [Agent API](agent-api.md) as tools an AI assistant can call. Connect it once and the assistant can read a business, get its real price for a job, find a free time and ask for the booking, in the middle of a conversation or a phone call.

```
https://mcp.bookingmachine.io/mcp
```

It speaks the Model Context Protocol over Streamable HTTP. No API key is needed for the tools on this page. `https://api.bookingmachine.io/v1/mcp` is the same server under a second address.

The full guide is at [bookingmachine.io/developers/mcp](https://bookingmachine.io/developers/mcp), and every tool with its inputs is listed at [bookingmachine.io/developers/mcp-tools](https://bookingmachine.io/developers/mcp-tools).

---

## Connect it

### Claude Code

```bash
claude mcp add --transport http bookingmachine https://mcp.bookingmachine.io/mcp
```

### Cursor

In `.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "bookingmachine": {
      "url": "https://mcp.bookingmachine.io/mcp"
    }
  }
}
```

### Any other client

Add a remote MCP server with the address above and the Streamable HTTP transport. There is nothing to sign in to.

To say who your agent is, send an `X-Agent` header with its name where your client lets you set headers. It is kept on any booking the agent makes.

---

## Try it

Ask your assistant:

> Using BookingMachine, what would a standard clean cost at fresh-start-cleaning for three bedrooms and two bathrooms, and what times are free this Friday?

`fresh-start-cleaning` is the [sandbox](agent-api.md#the-sandbox): a practice business with real prices and times that emails nobody and never makes a booking. The price it should come back with is £187.20.

---

## The tools

| Tool | What it does |
| --- | --- |
| `get_business_profile` | Who a business is: contact details, opening hours, timezone, currency, booking rules, rating, and what can be done for it right now |
| `list_services` | Its services, with their length and base price |
| `get_service_requirements` | The questions that set a service's price, its other questions and its add-ons |
| `calculate_quote` | The price for what the customer wants, worked out by the business's own pricing rules |
| `check_availability` | The times a customer can book, for one day or up to seven |
| `hold_slot` | Keep a free time for a few minutes while the customer decides |
| `release_hold` | Give a held time back |
| `create_booking` | Ask for a booking for a named customer |
| `get_booking` | Whether the customer has confirmed, or the request has lapsed |
| `list_reviews` | The reviews the business publishes, with its average rating |

Every tool takes `business`: the business's slug, the last part of its booking page address.

The order of a booking is the order of the table: profile, services, requirements, ask the customer what the requirements list, quote, availability, hold, booking.

---

## What an assistant must know

**The price comes from `calculate_quote`, never from `basePrice`.** A service's base price is where the price starts. The customer's answers change it.

**`create_booking` does not book.** It emails the customer a Confirm button, and the booking is made when they press it. The assistant should say so: "You'll get an email to confirm." See [the customer confirms, not the agent](agent-api.md#the-customer-confirms-not-the-agent).

**Check `capabilities` first.** `get_business_profile` says whether holds and bookings are open for this business. When they are not, the assistant gives the price and the free times, then sends the customer to the business's booking page. See [real businesses](agent-api.md#real-businesses).

**A tool that fails says why.** The answer carries a sentence to act on and a `code`, the same ones the [Agent API](agent-api.md#refusals-worth-handling) gives.

---

## A prompt to start from

For a receptionist that answers for one business, with the server connected:

```text
You are the receptionist for Fresh Start Cleaning. You take bookings with the
bookingmachine tools. The business slug is fresh-start-cleaning: pass it as
`business` on every tool call.

Never guess a price or a time. Only say prices and times a tool returned.

1. Find out which service the caller wants (list_services).
2. Call get_service_requirements and ask each required question, one at a time.
3. Call calculate_quote and tell the caller the total.
4. Ask which day suits, call check_availability, and offer two or three times.
5. When they pick one, call hold_slot.
6. Ask for their full name, email address and phone number, then call
   create_booking with the hold token.
7. Tell them they will get an email to confirm, and that nothing is booked
   until they press Confirm.
```
