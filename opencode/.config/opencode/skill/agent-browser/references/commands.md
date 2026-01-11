# Agent Browser Command Reference

## Core Commands

```bash
agent-browser open <url>              # Navigate to URL
agent-browser click <sel>             # Click element
agent-browser dblclick <sel>          # Double-click element
agent-browser focus <sel>             # Focus element
agent-browser type <sel> <text>       # Type into element
agent-browser fill <sel> <text>       # Clear and fill
agent-browser press <key>             # Press key (Enter, Tab, Control+a)
agent-browser keydown <key>           # Hold key down
agent-browser keyup <key>             # Release key
agent-browser hover <sel>             # Hover element
agent-browser select <sel> <val>      # Select dropdown option
agent-browser check <sel>             # Check checkbox
agent-browser uncheck <sel>           # Uncheck checkbox
agent-browser scroll <dir> [px]       # Scroll (up/down/left/right)
agent-browser scrollintoview <sel>    # Scroll element into view
agent-browser drag <src> <tgt>        # Drag and drop
agent-browser upload <sel> <files>    # Upload files
agent-browser screenshot [path]       # Take screenshot (--full for full page)
agent-browser pdf <path>              # Save as PDF
agent-browser snapshot                # Accessibility tree with refs
agent-browser eval <js>               # Run JavaScript
agent-browser close                   # Close browser
```

## Get Info

```bash
agent-browser get text <sel>          # Get text content
agent-browser get html <sel>          # Get innerHTML
agent-browser get value <sel>         # Get input value
agent-browser get attr <sel> <attr>   # Get attribute
agent-browser get title               # Get page title
agent-browser get url                 # Get current URL
agent-browser get count <sel>         # Count matching elements
agent-browser get box <sel>           # Get bounding box
```

## Check State

```bash
agent-browser is visible <sel>        # Check if visible
agent-browser is enabled <sel>        # Check if enabled
agent-browser is checked <sel>        # Check if checked
```

## Find Elements (Semantic Locators)

```bash
agent-browser find role <role> <action> [value]       # By ARIA role
agent-browser find text <text> <action>               # By text content
agent-browser find label <label> <action> [value]     # By label
agent-browser find placeholder <ph> <action> [value]  # By placeholder
agent-browser find alt <text> <action>                # By alt text
agent-browser find title <text> <action>              # By title attr
agent-browser find testid <id> <action> [value]       # By data-testid
agent-browser find first <sel> <action> [value]       # First match
agent-browser find last <sel> <action> [value]        # Last match
agent-browser find nth <n> <sel> <action> [value]     # Nth match
```

**Actions:** `click`, `fill`, `check`, `hover`, `text`

**Examples:**
```bash
agent-browser find role button click --name "Submit"
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "test@test.com"
agent-browser find first ".item" click
agent-browser find nth 2 "a" text
```

## Wait

```bash
agent-browser wait <selector>         # Wait for element
agent-browser wait <ms>               # Wait for time
agent-browser wait --text "Welcome"   # Wait for text
agent-browser wait --url "**/dash"    # Wait for URL pattern
agent-browser wait --load networkidle # Wait for load state
agent-browser wait --fn "window.ready === true"  # Wait for JS condition
```

**Load states:** `load`, `domcontentloaded`, `networkidle`

## Mouse Control

```bash
agent-browser mouse move <x> <y>      # Move mouse
agent-browser mouse down [button]     # Press button (left/right/middle)
agent-browser mouse up [button]       # Release button
agent-browser mouse wheel <dy> [dx]   # Scroll wheel
```

## Browser Settings

```bash
agent-browser set viewport <w> <h>    # Set viewport size
agent-browser set device <name>       # Emulate device ("iPhone 14")
agent-browser set geo <lat> <lng>     # Set geolocation
agent-browser set offline [on|off]    # Toggle offline mode
agent-browser set headers <json>      # Extra HTTP headers
agent-browser set credentials <u> <p> # HTTP basic auth
agent-browser set media [dark|light]  # Emulate color scheme
```

## Cookies & Storage

```bash
agent-browser cookies                 # Get all cookies
agent-browser cookies set <name> <val> # Set cookie
agent-browser cookies clear           # Clear cookies

agent-browser storage local           # Get all localStorage
agent-browser storage local <key>     # Get specific key
agent-browser storage local set <k> <v>  # Set value
agent-browser storage local clear     # Clear all

agent-browser storage session         # Same for sessionStorage
```

## Network

```bash
agent-browser network route <url>              # Intercept requests
agent-browser network route <url> --abort      # Block requests
agent-browser network route <url> --body <json>  # Mock response
agent-browser network unroute [url]            # Remove routes
agent-browser network requests                 # View tracked requests
agent-browser network requests --filter api    # Filter requests
```

## Tabs & Windows

```bash
agent-browser tab                     # List tabs
agent-browser tab new [url]           # New tab (optionally with URL)
agent-browser tab <n>                 # Switch to tab n
agent-browser tab close [n]           # Close tab
agent-browser window new              # New window
```

## Frames

```bash
agent-browser frame <sel>             # Switch to iframe
agent-browser frame main              # Back to main frame
```

## Dialogs

```bash
agent-browser dialog accept [text]    # Accept (with optional prompt text)
agent-browser dialog dismiss          # Dismiss
```

## Debug

```bash
agent-browser trace start [path]      # Start recording trace
agent-browser trace stop [path]       # Stop and save trace
agent-browser console                 # View console messages
agent-browser console --clear         # Clear console
agent-browser errors                  # View page errors
agent-browser errors --clear          # Clear errors
agent-browser highlight <sel>         # Highlight element
agent-browser state save <path>       # Save auth state
agent-browser state load <path>       # Load auth state
```

## Navigation

```bash
agent-browser back                    # Go back
agent-browser forward                 # Go forward
agent-browser reload                  # Reload page
```

## Setup

```bash
agent-browser install                 # Download Chromium browser
agent-browser install --with-deps     # Also install system deps (Linux)
```

## Selectors

### Refs (Recommended)

```bash
# From snapshot output: button "Submit" [ref=e2]
agent-browser click @e2
agent-browser fill @e3 "text"
agent-browser get text @e1
```

### CSS Selectors

```bash
agent-browser click "#id"
agent-browser click ".class"
agent-browser click "div > button"
```

### Text & XPath

```bash
agent-browser click "text=Submit"
agent-browser click "xpath=//button"
```

## Global Options

| Option | Description |
|--------|-------------|
| `--session <name>` | Use isolated session (or `AGENT_BROWSER_SESSION` env) |
| `--json` | JSON output (for agents) |
| `--full, -f` | Full page screenshot |
| `--name, -n` | Locator name filter |
| `--exact` | Exact text match |
| `--headed` | Show browser window (not headless) |
| `--debug` | Debug output |
