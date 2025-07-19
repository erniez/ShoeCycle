# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
- **Build**: Open `ShoeCycle.xcodeproj` in Xcode and use Cmd+B
- **Run**: Use Xcode's Run button or Cmd+R 
- **Test**: `fastlane test` or use Xcode's Test navigator
- **Clean**: Use Xcode's Product → Clean Build Folder

### Setup
1. Clone repo and checkout `develop` branch for latest code
2. Open `ShoeCycle.xcodeproj` in Xcode
3. Wait for Swift Package Manager dependencies to resolve
4. Remove/recreate `Secrets.swift` file in Supporting Files directory
5. Run the app

### Dependencies
- Uses **Carthage** for framework dependencies (AFNetworking, Charts, MBProgressHUD)
- Uses **Swift Package Manager** for Firebase Analytics
- No CocoaPods or other package managers

## Architecture Overview

### Core Data Model
- **Shoe** entity: Stores shoe information (brand, maxDistance, imageKey, etc.)
- **History** entity: Stores individual run records with distance and date
- **Relationship**: Shoe has many History records
- Core Data stack initialized in `ShoeStore.swift`

### App Structure
- **SwiftUI-based** with TabView navigation (4 main tabs)
- **MVVM pattern** throughout SwiftUI views
- **ObservableObject stores**: `ShoeStore`, `UserSettings`, `HealthKitService`
- **Environment objects** passed down through view hierarchy

### Key Components
- **ShoeStore**: Core Data interface for shoe and history management
- **UserSettings**: App preferences and selected shoe tracking
- **HealthKitService**: Integration with iOS HealthKit
- **StravaService**: Strava API integration for activity sync
- **Analytics**: Firebase Analytics with factory pattern

### Main Screens
1. **Add Distance**: Log runs for selected shoe with charts/history
2. **Active Shoes**: Manage active shoes, add new ones
3. **Hall of Fame**: View retired shoes
4. **Settings**: App preferences, Strava integration, distance units

### Legacy Code
- `LegacyCode/` directory contains old Objective-C implementation
- Being gradually migrated to SwiftUI
- Do not reference legacy code for new features

### Testing
- Unit tests in `ShoeCycleTests/`
- Uses standard XCTest framework
- Run via `fastlane test` command

#### Testing Best Practices
- **Database Safety**: Use `DBInteractiveTestCase` base class for Core Data tests to prevent database pollution
- **Focus on App Logic**: Test your app's behavior, not Foundation APIs (avoid testing `Calendar`, `DateFormatter`, etc.)
- **Meaningful Edge Cases**: Test boundary conditions your app encounters, not hypothetical scenarios
- **Avoid Cargo Cult Testing**: Remove tests that only verify system behavior (thread safety, locale handling, etc.)
- **Simple Validation**: Prefer direct constant validation over complex approximation testing

### Key Design Patterns
- **Strategy Pattern**: `SelectedShoeStrategy` for shoe selection logic
- **Factory Pattern**: `AnalyticsFactory` for analytics initialization
- **Observer Pattern**: Core Data change notifications via `@Published` properties