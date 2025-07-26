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
- **UserDefaults Safety**: NEVER use `UserDefaults.standard` in tests. Always use test-specific suite:
  ```swift
  // CORRECT: Isolated test UserDefaults
  let testUserDefaults = UserDefaults(suiteName: "com.shoecycle.tests")!
  
  // WRONG: Pollutes user data
  UserDefaults.standard
  ```
- **Focus on App Logic**: Test your app's behavior, not Foundation APIs (avoid testing `Calendar`, `DateFormatter`, etc.)
- **Meaningful Edge Cases**: Test boundary conditions your app encounters, not hypothetical scenarios
- **Avoid Cargo Cult Testing**: Remove tests that only verify system behavior (thread safety, locale handling, etc.)
- **Simple Validation**: Prefer direct constant validation over complex approximation testing
- **Gherkin Documentation**: All test methods MUST include Given/When/Then documentation above the function declaration:
  ```swift
  // Given: Initial state and conditions
  // When: Action being performed
  // Then: Expected outcome
  func testSomeFeature() throws {
      // test implementation
  }
  ```

### Key Design Patterns
- **Strategy Pattern**: `SelectedShoeStrategy` for shoe selection logic
- **Factory Pattern**: `AnalyticsFactory` for analytics initialization
- **Observer Pattern**: Core Data change notifications via `@Published` properties

## SwiftUI Architecture Pattern

**IMPORTANT: Use View State Interactor (VSI) pattern for ALL SwiftUI views**

### Structure Template
```swift
// State: Pure struct with data only
struct FeatureState {
    var property: Type
}

// Interactor: Struct with Actions enum and handle method
struct FeatureInteractor {
    enum Action {
        case actionName(Type)
        case viewAppeared
    }
    
    private let dependencies: Dependencies
    
    func handle(state: inout FeatureState, action: Action) {
        switch action {
        case .actionName(let value):
            // Inline logic for simple cases
            state.property = value
            dependencies.sideEffect()
        }
    }
}

// View: Thin UI layer with custom bindings
struct FeatureView: View {
    @State private var state = FeatureState()
    private let interactor: FeatureInteractor
    
    init(dependencies: Dependencies = .shared) {
        self.interactor = FeatureInteractor(dependencies: dependencies)
    }
    
    var body: some View {
        // UI elements use propertyBinding, not $state.property
        TextField("", text: propertyBinding)
            .onAppear { interactor.handle(state: &state, action: .viewAppeared) }
    }
    
    private var propertyBinding: Binding<Type> {
        Binding(
            get: { state.property },
            set: { interactor.handle(state: &state, action: .actionName($0)) }
        )
    }
}
```

### VSI Architecture Rules
- **State**: Structs only, no behavior or logic
- **Actions**: All user interactions must go through action enum
- **Interactor**: Handles ALL business logic, uses `inout state` for mutations
- **View**: Custom bindings for all state changes, NEVER use `$state.property` directly
- **Files**: Keep State/Interactor in separate `FeatureInteractions.swift` files
- **Simple handlers**: Keep logic inline in switch cases unless complex
- **Dependencies**: Inject services through interactor init, not environment objects

### SwiftUI Keyboard Toolbar Rule
- **NavigationView Required**: Views with TextField keyboard toolbars MUST be wrapped in NavigationView
- **Reason**: SwiftUI requires NavigationView context for keyboard toolbar buttons (like "Done") to appear
- **Implementation**: Wrap the main view content in `NavigationView { ... }`
- **Comment**: Always add comment: `// NavigationView is required for keyboard toolbars to work properly in SwiftUI`

### VSI Benefits
- Unidirectional data flow prevents state management bugs
- Excellent testability - business logic is pure and isolated
- Clear separation of concerns (View ↔ State ↔ Interactor)
- Predictable state changes - easy debugging
- Consistent pattern across entire codebase
- SwiftUI-optimized architecture

## Xcode Project File Modification

### Overview
The project includes a Ruby script (`xcode_project_modifier.rb`) for programmatically modifying Xcode project files using the `xcodeproj` gem.

### Setup
```bash
# Install the xcodeproj gem (already installed)
gem install xcodeproj
```

### Usage
The script provides a command-line interface for common project modifications:

```bash
# Add a file to the project
./xcode_project_modifier.rb add path/to/file.swift [group/path]

# Remove a file from the project  
./xcode_project_modifier.rb remove path/to/file.swift

# List files in the project (with optional pattern filter)
./xcode_project_modifier.rb list [pattern]
```

### Key Features
- **Automatic Build Phase Management**: Swift files are automatically added to compile sources
- **Group Support**: Files can be organized into specific groups/folders
- **Path Handling**: Handles both absolute and relative paths correctly
- **Duplicate Detection**: Prevents adding files that already exist in the project
- **Clean Removal**: Removes files from both project references and build phases

### Use Cases
- Adding new VSI Interactions files after refactoring
- Removing deprecated files from the project
- Organizing files into proper groups
- Automating project structure changes
- **Writing Unit Tests**: Add new test files to ShoeCycleTests target for testing business logic
- **Test Cleanup**: Remove obsolete or deprecated test files from the test target

### Technical Details
- Uses the industry-standard `xcodeproj` Ruby gem (same as CocoaPods)
- Maintains proper UUID generation and project file integrity
- Handles PBXGroup hierarchy and build phase updates automatically
