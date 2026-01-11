---
name: agent-browser
description: Headless browser automation CLI for AI agents. Use when you need to interact with web pages, fill forms, click buttons, scrape content, take screenshots, or automate any browser-based workflow. Provides snapshot-based element selection optimized for AI agents, session management for parallel browsing, and full Playwright capabilities via CLI.
---

# Agent Browser

CLI for headless browser automation. Optimized for AI agent workflows.

## Core Workflow

The recommended workflow uses snapshots with refs for deterministic element selection:

```bash
# 1. Navigate and get accessibility tree
agent-browser open example.com
agent-browser snapshot

# 2. Identify elements by ref from snapshot output
# Output shows: button "Submit" [ref=e2], textbox "Email" [ref=e3]

# 3. Interact using refs
agent-browser click @e2
agent-browser fill @e3 "test@example.com"

# 4. Get new snapshot if page changed
agent-browser snapshot
```

**Why refs?** Deterministic (points to exact element), fast (no DOM re-query), AI-friendly.

## Snapshot Options

```bash
agent-browser snapshot                    # Full accessibility tree
agent-browser snapshot -i                 # Interactive elements only (recommended)
agent-browser snapshot -c                 # Compact (remove empty structural elements)
agent-browser snapshot -d 3               # Limit depth
agent-browser snapshot -s "#main"         # Scope to selector
agent-browser snapshot -i -c --json       # Combine options, JSON output
```

Use `-i` (interactive) for most AI tasks - returns only buttons, links, inputs.

## Sessions

Run multiple isolated browser instances:

```bash
# Named sessions
agent-browser --session agent1 open site-a.com
agent-browser --session agent2 open site-b.com

# Or via environment variable
AGENT_BROWSER_SESSION=agent1 agent-browser click @e2

# List/show sessions
agent-browser session list
agent-browser session
```

Each session has isolated cookies, storage, history, and auth state.

## Common Patterns

### Form Filling

```bash
agent-browser open example.com/form
agent-browser snapshot -i
agent-browser fill @e3 "test@example.com"
agent-browser fill @e4 "password123"
agent-browser click @e5  # Submit button
agent-browser wait --load networkidle
```

### Authentication

```bash
agent-browser open example.com/login
agent-browser snapshot -i
agent-browser fill @e2 "username"
agent-browser fill @e3 "password"
agent-browser click @e4
agent-browser wait --url "**/dashboard"
agent-browser state save auth.json  # Save for later

# Restore later
agent-browser state load auth.json
```

### Data Extraction

```bash
agent-browser open example.com
agent-browser snapshot -i --json  # Parse in code
agent-browser get text @e1
agent-browser get html @e2
agent-browser get attr @e3 "href"
```

### Screenshots and PDFs

```bash
agent-browser screenshot page.png
agent-browser screenshot page.png --full  # Full page
agent-browser pdf document.pdf
```

## Waiting

```bash
agent-browser wait @e1                    # Wait for element
agent-browser wait 2000                   # Wait ms
agent-browser wait --text "Welcome"       # Wait for text
agent-browser wait --url "**/dashboard"   # Wait for URL pattern
agent-browser wait --load networkidle     # Wait for network idle
agent-browser wait --fn "window.ready === true"  # Custom JS condition
```

## Output Modes

Use `--json` for machine-readable output:

```bash
agent-browser snapshot --json
agent-browser get text @e1 --json
agent-browser is visible @e2 --json
```

## Debugging

```bash
agent-browser open example.com --headed   # Show browser window
agent-browser highlight @e1               # Highlight element
agent-browser console                     # View console messages
agent-browser errors                      # View page errors
agent-browser trace start                 # Start trace recording
agent-browser trace stop trace.zip        # Save trace
```

## Full Command Reference

See [references/commands.md](references/commands.md) for complete command documentation including:
- All core commands (click, fill, type, press, scroll, etc.)
- Element state checks (is visible, is enabled, is checked)
- Find commands with semantic locators
- Mouse control, cookies, storage, network interception
- Tabs, frames, and dialogs
