# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Run
```bash
cd GoogleCalendarApp
swift build
swift run
```

### Xcode Development
```bash
cd GoogleCalendarApp
open Package.swift
```

## Architecture

This is a native macOS SwiftUI application that integrates with Google Calendar API. The app uses OAuth 2.0 for authentication and displays calendar events in a split-view interface.

### Key Components

- **GoogleAuthManager**: Handles OAuth 2.0 authentication flow with Google, token management via macOS Keychain, and API calls to Google Calendar
- **CalendarEvent**: Data model representing calendar events with formatting utilities for dates and times
- **ContentView**: Main SwiftUI view implementing a NavigationSplitView with sidebar for event list and detail view for selected events
- **AppDelegate**: Handles URL scheme redirects for OAuth callback and window management

### Authentication Flow
The app uses AppAuth-iOS library for OAuth 2.0. Authentication state is persisted in macOS Keychain. The redirect URI scheme must be configured in Info.plist and match Google Cloud Console settings.

### API Integration
- Uses Google Calendar API v3 for read-only access
- Fetches events for the next 7 days from primary calendar
- Implements proper error handling and token refresh

### Configuration Requirements
- Client ID and redirect URI must be set in GoogleAuthManager.swift
- URL scheme must be configured in Info.plist
- Google Cloud Console project must have Calendar API enabled

### Dependencies
- AppAuth-iOS: OAuth 2.0 and OpenID Connect client library
- SwiftUI: Native macOS UI framework
- Foundation: Core Swift framework for networking and data handling