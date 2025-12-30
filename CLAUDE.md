# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the app
xcodebuild -scheme quip -configuration Debug build

# Run tests
xcodebuild -scheme quip -configuration Debug test

# Clean build
xcodebuild -scheme quip clean
```

## Architecture

Quip is a native macOS menu bar text expansion app. Type `;shortcut` + space to expand text.

### Core Components

**App Entry (`quipApp.swift`, `AppDelegate.swift`)**
- `MenuBarExtra` with `.menuBarExtraStyle(.window)` for custom popover UI
- `Window` scene for onboarding flow
- `@AppStorage("hasCompletedOnboarding")` tracks first-launch state
- `AppDelegate` handles app lifecycle and keyboard monitor startup

**Data Layer (`Models/Expansion.swift`)**
- SwiftData `@Model` for trigger/content/category persistence
- `fullTrigger` computed property prepends `;` to trigger

**Services**
- `KeyboardMonitor` - CGEventTap for global keyboard capture (requires accessibility permission)
- `ExpansionEngine` - Maintains character buffer, detects `;trigger` + space, performs expansion via clipboard injection (Cmd+V)
- `PermissionManager` - `AXIsProcessTrusted()` checks and permission polling

**Views**
- `MenuBar/` - Main popover with search, expansion list, CRUD
- `Onboarding/` - 3-page flow: Welcome → Permission → Demo
- `Management/` - Row views and edit sheet

### Key Technical Details

- **Sandboxing disabled** - Required for CGEventTap accessibility features
- **LSUIElement = YES** - Hides app from Dock (menu bar only)
- Text injection uses clipboard preservation: saves clipboard → paste → restores clipboard
- Permission polling via Timer when user is in System Settings

### Data Flow

1. `KeyboardMonitor` captures keyDown events via CGEventTap
2. Events passed to `ExpansionEngine.processKeyEvent()`
3. Buffer tracks typed characters, checks for `;trigger` + space
4. On match: delete trigger text (simulated backspaces) → inject expansion via clipboard
