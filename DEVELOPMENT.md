# Development Guide

This guide provides information for developers working on the OverLoad project.

## Table of Contents

- [Development Environment](#development-environment)
- [Project Setup](#project-setup)
- [Building the Project](#building-the-project)
- [Running Tests](#running-tests)
- [Debugging](#debugging)
- [Code Style](#code-style)
- [Git Workflow](#git-workflow)
- [Common Tasks](#common-tasks)
- [Troubleshooting](#troubleshooting)

## Development Environment

### Required Software

- **macOS**: Latest version recommended
- **Xcode**: 16.0 or later
- **iOS SDK**: 18.0 or later
- **Swift**: 5.0 or later
- **Git**: For version control

### Recommended Tools

- **Xcode**: Primary IDE
- **Simulator**: For testing on various iOS devices
- **Git**: Version control
- **Terminal**: For command-line operations

## Project Setup

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/DavidSantosTXUSA/OverLoad.git
   cd OverLoad
   ```

2. **Open in Xcode:**
   ```bash
   open MyWorkoutApp/MyWorkoutApp.xcodeproj
   ```

3. **Select a scheme:**
   - Choose "Overload" scheme
   - Select a simulator (e.g., iPhone 16 Pro)

4. **Build the project:**
   - Press `⌘B` or select Product → Build
   - Ensure there are no compilation errors

### Project Structure

```
MyWorkoutApp/
├── MyWorkoutApp/              # Main app target
│   ├── Models/                # Data models
│   ├── ViewModels/            # ViewModels (MVVM)
│   ├── Views/                 # SwiftUI views
│   ├── Services/              # Business logic services
│   └── Utilities/             # Helper utilities
├── MyWorkoutAppTests/         # Unit tests
└── MyWorkoutAppUITests/       # UI tests
```

## Building the Project

### Build Commands

**In Xcode:**
- Build: `⌘B`
- Clean Build: `⌘⇧K` then `⌘B`
- Build for Testing: `⌘U`

**Command Line:**
```bash
# Build for simulator
xcodebuild -scheme Overload -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Build for device (requires signing)
xcodebuild -scheme Overload -destination 'generic/platform=iOS' build
```

### Build Configurations

- **Debug**: Development builds with debugging symbols
- **Release**: Optimized builds for distribution

### Build Settings

Key build settings are in `project.pbxproj`:
- **iOS Deployment Target**: 18.0
- **Swift Version**: 5.0
- **Code Signing**: Automatic

## Running Tests

### Running All Tests

**In Xcode:**
- Press `⌘U`
- Or: Product → Test

**Command Line:**
```bash
xcodebuild test \
  -scheme Overload \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Running Specific Tests

1. Open Test Navigator (`⌘6`)
2. Click the diamond icon next to the test
3. Or right-click → Run

### Test Targets

- **MyWorkoutAppTests**: Unit tests
- **MyWorkoutAppUITests**: UI tests

### Writing New Tests

1. Create test file in `MyWorkoutAppTests/`
2. Import Testing framework:
   ```swift
   import Testing
   @testable import MyWorkoutApp
   ```
3. Write test functions:
   ```swift
   struct MyTests {
       @Test func test_something() {
           // Test code
       }
   }
   ```

## Debugging

### Breakpoints

**Set Breakpoint:**
- Click in the gutter next to line number
- Or press `⌘\` on a line

**Breakpoint Types:**
- Regular breakpoint: Pauses execution
- Conditional breakpoint: Pauses when condition is true
- Exception breakpoint: Pauses on exceptions

### Debugging Tools

**LLDB Console:**
- View variables: `po variableName`
- Print expression: `p expression`
- Continue: `continue` or `c`
- Step over: `next` or `n`
- Step into: `step` or `s`

**View Debugger:**
- Debug → View Debugging → Capture View Hierarchy
- Inspect view hierarchy and constraints

### Common Debugging Scenarios

**App Crashes:**
1. Check console for error messages
2. Set exception breakpoint
3. Check stack trace
4. Review recent changes

**UI Issues:**
1. Use View Debugger
2. Check console for layout warnings
3. Verify state updates
4. Check SwiftUI preview

**Performance Issues:**
1. Use Instruments (Product → Profile)
2. Check for memory leaks
3. Profile CPU usage
4. Check for excessive re-renders

## Code Style

### Swift Style Guide

Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/).

**Naming:**
- Types: PascalCase (`WorkoutSession`)
- Functions: camelCase (`addWorkout()`)
- Variables: camelCase (`workoutName`)
- Constants: camelCase (`maxReps`)

**Formatting:**
- 4 spaces for indentation
- Maximum 120 characters per line
- Trailing commas in multi-line arrays/dictionaries

**Example:**
```swift
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [Exercise]
    
    func calculateVolume() -> Double {
        exercises.reduce(0) { total, exercise in
            total + exercise.totalVolume
        }
    }
}
```

### SwiftUI Best Practices

**View Structure:**
```swift
struct MyView: View {
    @ObservedObject var viewModel: MyViewModel
    @State private var localState = false
    
    var body: some View {
        VStack {
            // View content
        }
        .onAppear {
            // Setup
        }
    }
}
```

**State Management:**
- Use `@State` for local view state
- Use `@ObservedObject` for ViewModels from parent
- Use `@StateObject` for ViewModels created in view
- Use `@Published` in ViewModels for reactive updates

## Git Workflow

### Branch Strategy

- **main**: Production-ready code
- **feature/**: New features
- **fix/**: Bug fixes
- **docs/**: Documentation updates

### Commit Workflow

1. **Create branch:**
   ```bash
   git checkout -b feature/my-feature
   ```

2. **Make changes and commit:**
   ```bash
   git add .
   git commit -m "Add feature description"
   ```

3. **Push to remote:**
   ```bash
   git push origin feature/my-feature
   ```

4. **Create Pull Request on GitHub**

### Commit Message Format

```
Type: Short description (50 chars)

Longer description if needed. Explain what and why,
not just what changed.

- Bullet points for details
- Reference issues: Fixes #123
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Tests
- `chore`: Maintenance

## Common Tasks

### Adding a New Feature

1. Create feature branch
2. Implement feature
3. Add tests
4. Update documentation
5. Commit and push
6. Create Pull Request

### Fixing a Bug

1. Reproduce the bug
2. Create fix branch
3. Write test that fails
4. Fix the bug
5. Verify test passes
6. Commit and push
7. Create Pull Request

### Adding a New View

1. Create SwiftUI view file
2. Add to appropriate folder
3. Update navigation if needed
4. Add to project in Xcode
5. Test in simulator
6. Update documentation

### Adding a New ViewModel

1. Create ViewModel class
2. Inherit from `ObservableObject`
3. Add `@Published` properties
4. Implement business logic
5. Add tests
6. Inject into views

### Updating Dependencies

Currently no external dependencies. If adding:
1. Add via Swift Package Manager
2. Update project settings
3. Test thoroughly
4. Document in README

## Troubleshooting

### Build Errors

**"No such module":**
- Clean build folder: `⌘⇧K`
- Rebuild: `⌘B`
- Check import statements

**"Cannot find type":**
- Check file is added to target
- Verify import statements
- Clean and rebuild

**Code signing errors:**
- Check signing settings in project
- Verify team is selected
- Check bundle identifier

### Runtime Errors

**App crashes on launch:**
- Check console for errors
- Verify all required files are included
- Check for nil unwrapping

**UI not updating:**
- Verify `@Published` properties
- Check `@ObservedObject` binding
- Ensure updates on main thread

**Data not persisting:**
- Check UserDefaults keys
- Verify Codable conformance
- Check error handling

### Test Issues

**Tests not running:**
- Check test target membership
- Verify test scheme is selected
- Clean build folder

**Tests failing:**
- Check test data
- Verify mock implementations
- Check for timing issues

### Simulator Issues

**Simulator won't start:**
- Restart Xcode
- Reset simulator: Device → Erase All Content and Settings
- Check available disk space

**App won't install:**
- Clean build folder
- Delete app from simulator
- Rebuild and install

## Performance Tips

### Optimization

1. **Use debouncing** for frequent operations (auto-save)
2. **Lazy loading** for large lists
3. **Local state** for text fields to prevent re-renders
4. **Profile with Instruments** regularly

### Memory Management

1. **Avoid retain cycles** (use `[weak self]` in closures for classes)
2. **Release resources** in `deinit` if needed
3. **Use value types** (structs) when possible
4. **Profile memory** with Instruments

## Resources

- [Swift Documentation](https://www.swift.org/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)
- [Xcode User Guide](https://developer.apple.com/documentation/xcode)
- [Testing in Xcode](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)

## Getting Help

- Check existing issues on GitHub
- Review code comments
- Ask in Pull Request discussions
- Open an issue with `question` label

Happy coding! 🚀

