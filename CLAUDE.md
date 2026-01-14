# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

**Claude Usage Widget** is a macOS menu bar widget that displays Claude Code usage limits in real-time:
- **Session usage**: Current session token/request consumption
- **Weekly (Hebdo) usage**: Weekly limit progress and reset time

### Tech Stack
- **SwiftUI** for the menu bar widget UI
- **WidgetKit** (optional, for desktop widgets)
- **Swift 5.9+** / Xcode 15+
- **macOS 14.0+ (Sonoma)** target

## Architecture

```
claude-usage-widget/
├── ClaudeUsageWidget/
│   ├── App/
│   │   ├── ClaudeUsageWidgetApp.swift    # Main app entry
│   │   └── AppDelegate.swift              # Menu bar setup
│   ├── Views/
│   │   ├── MenuBarView.swift              # Main menu bar popover
│   │   ├── UsageProgressView.swift        # Progress bar component
│   │   └── SettingsView.swift             # Settings window
│   ├── Models/
│   │   ├── UsageData.swift                # Usage data models
│   │   └── Settings.swift                 # User preferences
│   ├── Services/
│   │   ├── ClaudeAPIService.swift         # API calls to get usage
│   │   ├── UsageMonitor.swift             # Background monitoring
│   │   └── NotificationService.swift      # Alert when near limit
│   └── Resources/
│       └── Assets.xcassets                # App icons
├── ClaudeUsageWidget.xcodeproj
├── CLAUDE.md
├── README.md
└── .gitignore
```

## Getting Usage Data

### Option 1: Claude Code CLI (Recommended)
Parse output from Claude Code CLI commands:
```bash
# Check if there's a usage command
claude --help | grep -i usage

# Or parse from config/cache files
cat ~/.claude/usage.json  # If exists
```

### Option 2: Anthropic API
Use the Anthropic API to check usage (requires API key):
```
GET https://api.anthropic.com/v1/usage
Authorization: x-api-key YOUR_API_KEY
```

### Option 3: Parse Claude Code Internal Files
Look for usage data in:
- `~/.claude/` directory
- `~/Library/Application Support/Claude Code/`
- Parse session logs

## Data Models

```swift
struct UsageData: Codable {
    let sessionUsage: SessionUsage
    let weeklyUsage: WeeklyUsage
    let lastUpdated: Date
}

struct SessionUsage: Codable {
    let tokensUsed: Int
    let tokensLimit: Int
    let requestsUsed: Int
    let requestsLimit: Int
}

struct WeeklyUsage: Codable {
    let tokensUsed: Int
    let tokensLimit: Int
    let resetsAt: Date
    let percentUsed: Double
}
```

## UI Design

### Menu Bar Icon
- Show percentage as small text or color-coded dot
- Green: < 50% used
- Yellow: 50-80% used
- Red: > 80% used

### Popover Content
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
├─────────────────────────────┤
│  ⚙️ Settings    🔄 Refresh  │
└─────────────────────────────┘
```

## Common Commands

### Development
```bash
# Open in Xcode
open ClaudeUsageWidget.xcodeproj

# Build from command line
xcodebuild -scheme ClaudeUsageWidget -configuration Debug build

# Run tests
xcodebuild test -scheme ClaudeUsageWidget
```

### Git Workflow
```bash
# Feature branch
git checkout -b feature/feature-name

# Commit with conventional commits
git commit -m "feat: add usage progress bar"
git commit -m "fix: correct weekly reset calculation"
git commit -m "style: improve dark mode colors"

# Before PR
git rebase main
```

## Code Standards

### Swift Style
- Use SwiftUI for all views
- Follow Apple's Swift API Design Guidelines
- Use `@Observable` (iOS 17+) or `@ObservableObject` for state
- Prefer `async/await` over callbacks
- Use `Result` type for error handling

### File Naming
- Views: `*View.swift` (e.g., `MenuBarView.swift`)
- Models: Descriptive names (e.g., `UsageData.swift`)
- Services: `*Service.swift` (e.g., `ClaudeAPIService.swift`)

### Code Organization
```swift
// MARK: - Properties
// MARK: - Initialization
// MARK: - Body (for Views)
// MARK: - Private Methods
// MARK: - Extensions
```

### Error Handling
```swift
enum UsageError: LocalizedError {
    case networkError(Error)
    case parseError
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .parseError: return "Failed to parse usage data"
        case .unauthorized: return "Invalid API key"
        }
    }
}
```

## Git Flow

### Branches
- `main` - Production-ready code
- `develop` - Development integration
- `feature/*` - New features
- `fix/*` - Bug fixes

### Commit Convention
```
<type>(<scope>): <subject>

Types:
- feat: New feature
- fix: Bug fix
- style: UI/styling changes
- refactor: Code refactoring
- docs: Documentation
- test: Tests
- chore: Build/config changes

Examples:
- feat(menu): add usage progress indicator
- fix(api): handle rate limit errors
- style(ui): improve dark mode contrast
```

### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with clean commits
3. Test on macOS
4. Create PR to `develop`
5. Merge after review

## Environment Setup

### Requirements
- Xcode 15+
- macOS 14.0+ (Sonoma)
- Swift 5.9+

### Optional
- API key for Anthropic API (if using direct API calls)
- Store in Keychain, not in code

### First Time Setup
```bash
# Clone repo
git clone <repo-url>
cd claude-usage-widget

# Open in Xcode
open ClaudeUsageWidget.xcodeproj

# Build and run
# Press Cmd+R in Xcode
```

## Features Roadmap

### MVP (v1.0)
- [ ] Menu bar icon with usage indicator
- [ ] Popover showing session + weekly usage
- [ ] Manual refresh button
- [ ] Basic settings (refresh interval)

### v1.1
- [ ] Auto-refresh in background
- [ ] Notifications when approaching limit
- [ ] Dark/light mode support

### v2.0
- [ ] Desktop widget (WidgetKit)
- [ ] Usage history graph
- [ ] Multiple account support

## Testing

### Unit Tests
- Test data parsing
- Test percentage calculations
- Test date/time handling for reset

### UI Tests
- Test popover opens/closes
- Test refresh updates data
- Test settings persistence

## Notes

### Rate Limiting
- Don't poll too frequently (minimum 30 seconds)
- Cache data locally
- Show "last updated" timestamp

### Privacy
- Never log API keys
- Store credentials in Keychain
- No analytics/telemetry

### Performance
- Lightweight menu bar app
- Minimal memory footprint
- Battery-efficient polling
