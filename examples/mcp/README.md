# Connect the MCP server

The server is at `https://mcp.bookingmachine.io/mcp` (Streamable HTTP). No API key is needed for the public tools. The guide is [docs/mcp.md](../../docs/mcp.md).

## Claude Code

```bash
claude mcp add --transport http bookingmachine https://mcp.bookingmachine.io/mcp
```

## Cursor

Copy [`cursor.mcp.json`](cursor.mcp.json) to `.cursor/mcp.json` in your project.

## Check it without a client

```bash
curl -s -X POST https://mcp.bookingmachine.io/mcp \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json, text/event-stream' \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

The answer lists the tools. Then ask your assistant what a standard clean costs at `fresh-start-cleaning` for three bedrooms and two bathrooms. It should say £187.20.
