# OverLoad Architecture Documentation

This document provides a detailed overview of the OverLoad app architecture, design patterns, and technical decisions.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Design Patterns](#design-patterns)
- [Data Flow](#data-flow)
- [Component Details](#component-details)
- [Persistence Layer](#persistence-layer)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Testing Strategy](#testing-strategy)

## Architecture Overview

OverLoad follows the **MVVM (Model-View-ViewModel)** architectural pattern, which provides clear separation of concerns and makes the codebase maintainable and testable.

```
┌─────────────┐
│    View     │  SwiftUI Views (UI Layer)
│  (SwiftUI)  │
└──────┬──────┘
       │ @ObservedObject / @StateObject
       ▼
┌─────────────┐
│  ViewModel  │  Business Logic & State Management
│ (Observable)│
└──────┬──────┘
       │ Uses
       ▼
┌─────────────┐
│    Model    │  Data Structures
│  (Structs)  │
└──────┬──────┘
       │ Persisted via
       ▼
┌─────────────┐
│ Persistence │  UserDefaults (via PersistenceService)
│   Service   │
└─────────────┘
```

## Design Patterns

### MVVM (Model-View-ViewModel)

**Models**: Pure data structures (structs)
- `WorkoutTemplate`
- `Exercise`
- `WorkoutSession`
- `ExerciseEntry`
- `SetEntry`

**Views**: SwiftUI views responsible for UI
- Display data from ViewModels
- Handle user interactions
- Trigger ViewModel actions

**ViewModels**: Observable objects managing state
- `WorkoutTemplateViewModel`
- `ExerciseLibraryViewModel`
- `WorkoutSessionViewModel`

### Dependency Injection

ViewModels accept `PersistenceService` as a dependency:

```swift
class WorkoutSessionViewModel: ObservableObject {
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = UserDefaultsPersistenceService()) {
        self.persistenceService = persistenceService
        // ...
    }
}
```

This allows:
- Easy testing with mock services
- Future migration to different storage (Core Data, SwiftData, etc.)
- Better separation of concerns

### Protocol-Oriented Programming

The `PersistenceService` protocol abstracts data persistence:

```swift
protocol PersistenceService {
    func save<T: Codable>(_ object: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func remove(forKey key: String)
}
```

## Data Flow

### Creating a Workout Template

```
User Input (CreateWorkoutView)
    ↓
WorkoutTemplateViewModel.addWorkoutTemplate()
    ↓
PersistenceService.save()
    ↓
UserDefaults
    ↓
WorkoutTemplateViewModel.workoutTemplates (Published)
    ↓
UI Updates (WorkoutListView)
```

### Starting a Workout

```
User Taps Template (WorkoutListView)
    ↓
Creates WorkoutSession from Template
    ↓
WorkoutDetailView displays session
    ↓
User logs sets
    ↓
Debounced Auto-Save (0.5s delay)
    ↓
WorkoutSessionViewModel.saveActiveWorkout()
    ↓
PersistenceService.save()
    ↓
UserDefaults
```

### Viewing Progress

```
WorkoutProgressView loads
    ↓
WorkoutSessionViewModel.workoutSessions
    ↓
Filter/Sort/Search applied
    ↓
Display filtered results
    ↓
User can export data
    ↓
DataExportService generates CSV/JSON
```

## Component Details

### ViewModels

#### WorkoutSessionViewModel

**Responsibilities:**
- Manage workout sessions (CRUD operations)
- Track active workout
- Calculate analytics and PRs
- Handle persistence

**Key Properties:**
```swift
@Published var workoutSessions: [WorkoutSession]
@Published var activeWorkout: WorkoutSession?
@Published var lastError: AppError?
```

**Key Methods:**
- `addWorkoutSession(_:)` - Add completed workout
- `saveActiveWorkout(_:)` - Save in-progress workout
- `loadActiveWorkout()` - Resume workout
- `getStatistics()` - Calculate overall stats
- `getExercisePRs()` - Calculate personal records

#### WorkoutTemplateViewModel

**Responsibilities:**
- Manage workout templates
- Handle template persistence
- Provide templates for workout creation

#### ExerciseLibraryViewModel

**Responsibilities:**
- Manage exercise library
- Handle exercise persistence
- Provide exercises for template creation

### Services

#### PersistenceService

**Purpose:** Abstract data persistence layer

**Implementation:** `UserDefaultsPersistenceService`

**Benefits:**
- Easy to test with mocks
- Can swap implementations (Core Data, SwiftData, etc.)
- Centralized error handling

#### DataExportService

**Purpose:** Export workout data to various formats

**Methods:**
- `exportToCSV(workoutSessions:)` - Generate CSV string
- JSON export handled in `WorkoutProgressView`

#### WorkoutAnalytics

**Purpose:** Calculate workout statistics and PRs

**Key Functions:**
- `WorkoutSession.analytics.totalVolume` - Calculate volume for a session
- `WorkoutSessionViewModel.getStatistics()` - Overall statistics
- `WorkoutSessionViewModel.getExercisePRs()` - Personal records

### Utilities

#### InputValidators

**Purpose:** Validate and clamp user input

**Methods:**
- `clampReps(_:)` - Clamp reps to 1-999
- `clampWeight(_:)` - Clamp weight to 0-9999.9

#### AppError

**Purpose:** Structured error handling

**Types:**
- `persistenceError(String)`
- `encodingError(String)`
- `decodingError(String)`
- `validationError(String)`
- `genericError(String)`

#### RestTimer

**Purpose:** Manage rest timer between sets

**Features:**
- Start, pause, resume, stop
- Configurable duration
- Observable for UI updates

## Persistence Layer

### Storage Strategy

**Current:** UserDefaults
- Simple key-value storage
- Suitable for small to medium datasets
- Automatic encoding/decoding via Codable

**Data Stored:**
- `workoutTemplates` - Array of WorkoutTemplate
- `workoutSessions` - Array of WorkoutSession
- `exercises` - Array of Exercise
- `activeWorkout` - Single WorkoutSession (in-progress)

### Error Handling

```swift
do {
    try persistenceService.save(data, forKey: key)
} catch {
    // Clear corrupted data
    persistenceService.remove(forKey: key)
    throw AppError.decodingError("...")
}
```

### Future Migration Path

The `PersistenceService` protocol allows easy migration:

```swift
// Future: CoreDataPersistenceService
class CoreDataPersistenceService: PersistenceService {
    // Implementation using Core Data
}

// Future: SwiftDataPersistenceService
class SwiftDataPersistenceService: PersistenceService {
    // Implementation using SwiftData
}
```

## State Management

### SwiftUI Property Wrappers

**@StateObject:**
- Used for ViewModels created in the view
- Owns the object's lifecycle
- Example: `@StateObject private var restTimer = RestTimer()`

**@ObservedObject:**
- Used for ViewModels passed from parent
- Doesn't own the object
- Example: `@ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel`

**@Published:**
- Used in ViewModels to notify views of changes
- Triggers view updates automatically

**@State:**
- Used for local view state
- Example: `@State private var showErrorAlert = false`

### State Flow Example

```swift
// ViewModel
class MyViewModel: ObservableObject {
    @Published var items: [Item] = []
    
    func addItem(_ item: Item) {
        items.append(item)
        // View automatically updates
    }
}

// View
struct MyView: View {
    @ObservedObject var viewModel: MyViewModel
    
    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
            // Automatically updates when viewModel.items changes
        }
    }
}
```

## Error Handling

### Error Flow

```
Operation (e.g., save)
    ↓
Throws AppError
    ↓
ViewModel catches error
    ↓
Sets lastError (Published)
    ↓
View observes lastError
    ↓
Displays alert to user
```

### Error Display

```swift
// ViewModel
@Published var lastError: AppError?

func handleError(_ error: Error) {
    if let appError = error as? AppError {
        lastError = appError
    } else {
        lastError = .genericError(error.localizedDescription)
    }
}

// View
.alert("Error", isPresented: $showErrorAlert) {
    Button("OK") { }
} message: {
    Text(viewModel.lastError?.errorDescription ?? "Unknown error")
}
```

## Testing Strategy

### Unit Tests

**Location:** `MyWorkoutAppTests/`

**Coverage:**
- ViewModels (with mock PersistenceService)
- Utility functions (InputValidators, etc.)
- Models (computed properties)
- Services (PersistenceService, Analytics)

### Test Structure

```swift
import Testing
@testable import MyWorkoutApp

struct MyViewModelTests {
    @Test func test_featureName_condition_expectedResult() {
        // Arrange
        let mockPersistence = MockPersistenceService()
        let viewModel = MyViewModel(persistenceService: mockPersistence)
        
        // Act
        viewModel.performAction()
        
        // Assert
        #expect(viewModel.state == expected)
    }
}
```

### Mock Services

```swift
class MockPersistenceService: PersistenceService {
    var store: [String: Data] = [:]
    
    func save<T: Codable>(_ object: T, forKey key: String) throws {
        let encoded = try JSONEncoder().encode(object)
        store[key] = encoded
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = store[key] else { return nil }
        return try JSONDecoder().decode(type, from: data)
    }
    
    func remove(forKey key: String) {
        store[key] = nil
    }
}
```

## Performance Considerations

### Debouncing

Auto-save is debounced to reduce I/O:

```swift
func debouncedAutoSave() {
    autoSaveWork?.cancel()
    let work = DispatchWorkItem { [self] in
        self.autoSaveWorkout()
    }
    autoSaveWork = work
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
}
```

### Local State for Text Fields

Text fields use local state to prevent re-renders:

```swift
@State private var weightTextFields: [String: String] = [:]

TextField("Weight", text: Binding(
    get: { /* Check local state first */ },
    set: { /* Update local state, then model */ }
))
```

## Future Architecture Considerations

### Potential Improvements

1. **Repository Pattern**: Add repository layer between ViewModels and PersistenceService
2. **Use Cases**: Extract business logic into use case classes
3. **Coordinator Pattern**: For complex navigation flows
4. **Combine Framework**: For reactive data flows
5. **SwiftData**: Migrate from UserDefaults to SwiftData for better performance

### Scalability

Current architecture supports:
- Small to medium datasets (UserDefaults)
- Single-user scenarios
- Local-only data

For future growth:
- Consider Core Data or SwiftData
- Add cloud sync layer
- Implement offline-first architecture
- Add data migration strategies

