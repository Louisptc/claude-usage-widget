# Claude Usage Widget

A lightweight macOS menu bar widget to monitor your Claude Code usage limits.

## Features

- **Real-time usage display** in the menu bar
- **Session usage** tracking (current session tokens/requests)
- **Weekly usage** tracking with reset countdown
- **Visual progress bars** with color-coded status
- **Notifications** when approaching limits

## Screenshots

```
┌─────────────────────────────┐
│  Claude Usage               │
├─────────────────────────────┤
│  Session                    │
│  ████████░░ 80%            │
│  8,000 / 10,000 tokens     │
├─────────────────────────────┤
│  Weekly                     │
│  ██████░░░░ 60%            │
│  600K / 1M tokens          │
│  Resets in 3 days          │
└─────────────────────────────┘
```

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15+ (for development)

## Installation

### From Source

```bash
git clone https://github.com/yourusername/claude-usage-widget.git
cd claude-usage-widget
open ClaudeUsageWidget.xcodeproj
# Build and Run (Cmd+R)
```

### Pre-built Release

Download the latest `.dmg` from [Releases](https://github.com/yourusername/claude-usage-widget/releases).

## Usage

1. Launch the app - it will appear in your menu bar
2. Click the icon to see detailed usage stats
3. Use Settings to configure refresh interval and notifications

## Configuration

The widget reads usage data from Claude Code's local files:
- `~/.claude/` directory

## Development

See [CLAUDE.md](CLAUDE.md) for development guidelines and architecture.

```bash
# Build
xcodebuild -scheme ClaudeUsageWidget build

# Run tests
xcodebuild test -scheme ClaudeUsageWidget
```

## License

MIT
