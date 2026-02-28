# Google Sheets MCP Server — MuleSoft

A **Model Context Protocol (MCP) Server** built with MuleSoft that exposes Google Sheets operations as MCP tools, allowing AI agents (Claude, Copilot, Cursor, etc.) to interact with Google Spreadsheets directly through natural language.

---

## What is this?

This project implements an MCP server using the [MuleSoft MCP Connector](https://anypoint.mulesoft.com/exchange/com.mulesoft.connectors/mule-mcp-connector/). It bridges AI agents with the Google Sheets API using OAuth 2.0, exposing spreadsheet operations as tools that any MCP-compatible client can discover and invoke.

---

## Architecture

```
MCP Client (AI Agent)
        │
        ▼
MuleSoft MCP Server (Streamable HTTP)
        │
        ▼
Google Sheets API v4 (OAuth 2.0)
```

- **MCP Transport:** Streamable HTTP on `http://localhost:8080/api`
- **Auth:** Google OAuth 2.0 Authorization Code flow
- **Token Storage:** Mule Object Store (persisted across requests)
- **Config:** Secure Properties Module (AES/CBC encrypted credentials)

---

## MCP Tools

### 1. `get-sheet-values-by-tab-name`
Retrieves all values from a Google Spreadsheet given a tab name.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `sheetId` | string | ✅ | Spreadsheet ID (found in the sheet URL) |
| `tabName` | string | ✅ | Name of the tab to read from |

---

### 2. `get-sheet-values-by-range`
Retrieves values from a specific cell range in a Google Spreadsheet.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `sheetId` | string | ✅ | Spreadsheet ID (found in the sheet URL) |
| `range` | string | ✅ | Cell range in A1 notation (e.g. `Sheet1!A1:D10`) |

---

### 3. `create-new-spreadsheet`
Creates a new Google Spreadsheet with a given name and optional tab structure.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `title` | string | ✅ | Name of the new spreadsheet |
| `sheets` | string[] | ❌ | Array of tab names to create. Defaults to `["Sheet1"]` |

---

### 4. `append-sheet-values`
Appends new rows of data to a Google Spreadsheet at a given range.

| Parameter | Type | Required | Description |
|---|---|---|---|
| `sheetId` | string | ✅ | Spreadsheet ID (found in the sheet URL) |
| `range` | string | ✅ | Target range in A1 notation (e.g. `Sheet1!A:D`) |
| `values` | array[] | ✅ | Array of arrays — each inner array is a row (e.g. `[["John", "Doe", "30"]]`) |

---

## HTTP Endpoints

In addition to the MCP tools, the following REST endpoints are available for direct use or debugging:

| Method | Path | Description |
|---|---|---|
| `GET` | `/api/get-sheet-values-by-range` | Read sheet values by range |
| `GET` | `/api/get-sheet-values-by-tab` | Read all values from a tab |
| `POST` | `/api/append-values` | Append rows to a sheet |
| `POST` | `/api/create-new-spreadsheet` | Create a new spreadsheet |
| `GET` | `/api/get-access-token` | Retrieve the current OAuth access token |
| `GET` | `/api/health` | Health check |
| `GET` | `/api/google/auth` | Initiate Google OAuth flow |

---

## Prerequisites

- **Anypoint Code Builder** or **Anypoint Studio**
- **Mule Runtime** 4.11.0+
- **JDK 17**
- A **Google Cloud Project** with the Google Sheets API enabled
- An **OAuth 2.0 Client ID** (type: Web Application) with the callback URL:
  ```
  http://localhost:8080/api/callback
  ```

---

## Configuration

Credentials are stored encrypted in `src/main/resources/config/ws/ws-config.yaml` using the [Mule Secure Properties Module](https://docs.mulesoft.com/secure-configuration-properties/1.2/) (AES/CBC).

```yaml
google:
  spread-sheets:
    client_id: "![ENCRYPTED_VALUE]"
    client_secret: "![ENCRYPTED_VALUE]"
    scope: "https://www.googleapis.com/auth/spreadsheets"
  oauth-callback:
    callback_path: "/callback"
    authorize-path: "/google/auth"
    external-callback-url: "http://localhost:8080/callback"
```

To encrypt your own values use the [Secure Properties Tool](https://docs.mulesoft.com/mule-runtime/4.4/secure-configuration-properties#secure_props_tool) with algorithm `AES` and mode `CBC`.

---

## Running the Server

Pass your encryption key as a JVM argument:

```bash
-Dsecure.key=YOUR_ENCRYPTION_KEY
```

In Anypoint Code Builder, add it to the run configuration under **Additional JVM args**.

Once started:

1. **Authorize Google:** Open `http://localhost:8080/api/google/auth` in your browser and complete the OAuth flow.
2. **Connect your MCP client** to `http://localhost:8080/api/sse` (or the streamable HTTP endpoint).
3. The 4 tools will be available for any MCP-compatible AI agent.

---

## MCP Client Configuration (Claude Desktop / Cursor)

```json
{
  "mcpServers": {
    "google-sheets": {
      "url": "http://localhost:8080/api/sse"
    }
  }
}
```

---

## Project Structure

```
src/main/mule/
├── global.xml                    # Global configs: Secure Properties, Google Sheets connector, Object Store
├── gogle-sheets-mcp-server.xml   # MCP tool listeners
└── implementation.xml            # Flow implementations

src/main/resources/
├── config/ws/ws-config.yaml      # Encrypted credentials
└── dataweave/                    # DataWeave scripts
```

---

## License

MIT
