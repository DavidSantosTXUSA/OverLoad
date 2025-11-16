# Contributing to OverLoad

Thank you for your interest in contributing to OverLoad! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them learn
- Focus on constructive feedback
- Respect different viewpoints and experiences

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/OverLoad.git
   cd OverLoad
   ```
3. **Add the upstream repository**:
   ```bash
   git remote add upstream https://github.com/DavidSantosTXUSA/OverLoad.git
   ```

## Development Setup

### Prerequisites

- **Xcode 16.0+** (latest version recommended)
- **iOS 18.0+** SDK
- **Swift 5.0+**
- **macOS** (required for iOS development)

### Setup Steps

1. Open the project in Xcode:
   ```bash
   open MyWorkoutApp/MyWorkoutApp.xcodeproj
   ```

2. Select a simulator or connected device

3. Build the project (⌘B) to ensure everything compiles

4. Run the test suite (⌘U) to verify all tests pass

## Making Changes

### Branch Naming

Create a new branch for your changes:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
# or
git checkout -b docs/your-documentation-update
```

### Commit Messages

Write clear, descriptive commit messages:

```
Short summary (50 chars or less)

More detailed explanation if needed. Wrap at 72 characters.
Explain the problem and solution, not just what changed.

- Bullet points are okay
- Use present tense ("Add feature" not "Added feature")
- Reference issues: Fixes #123
```

### Example Commit Messages

**Good:**
```
Fix weight input field lag during typing

Implemented debounced auto-save to reduce I/O operations.
Changed from saving on every keystroke to saving 0.5s after
typing stops. This improves performance and reduces lag.

Fixes #45
```

**Bad:**
```
fix bug
```

## Coding Standards

### Swift Style Guide

- Follow [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- Use meaningful variable and function names
- Keep functions focused and small
- Add comments for complex logic
- Use SwiftUI best practices

### Code Formatting

- Use 4 spaces for indentation (Xcode default)
- Maximum line length: 120 characters
- Use trailing closures where appropriate
- Prefer `let` over `var` when possible

### Architecture

- Follow **MVVM** (Model-View-ViewModel) pattern
- Keep Views focused on UI
- Business logic belongs in ViewModels
- Use dependency injection for testability

### Example

```swift
// Good: Clear naming, focused function
func calculateTotalVolume(for session: WorkoutSession) -> Double {
    session.exerciseEntries.reduce(0) { total, entry in
        total + entry.sets.reduce(0) { setTotal, set in
            setTotal + (set.weight * Double(set.reps))
        }
    }
}

// Bad: Unclear naming, does too much
func calc(s: WorkoutSession) -> Double {
    var t = 0.0
    for e in s.exerciseEntries {
        for set in e.sets {
            t += set.weight * Double(set.reps)
        }
    }
    return t
}
```

## Testing

### Writing Tests

- Write unit tests for all ViewModels and utility functions
- Test edge cases and error conditions
- Use descriptive test names
- Follow the pattern: `test_whatItTests_expectedBehavior`

### Running Tests

```bash
# Run all tests
⌘U in Xcode

# Run specific test
Click the diamond icon next to the test function

# Run tests from command line
xcodebuild test -scheme MyWorkoutApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

### Test Structure

```swift
import Testing
@testable import MyWorkoutApp

struct MyFeatureTests {
    @Test func test_featureName_validInput_shouldReturnExpected() {
        // Arrange
        let input = "test"
        
        // Act
        let result = myFunction(input)
        
        // Assert
        #expect(result == expected)
    }
}
```

### Test Coverage

- Aim for high test coverage on business logic
- ViewModels should have comprehensive tests
- Utility functions should be fully tested
- Views can have minimal testing (focus on ViewModels)

## Submitting Changes

### Pull Request Process

1. **Update your branch**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Ensure tests pass**:
   ```bash
   ⌘U in Xcode
   ```

3. **Push your changes**:
   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request** on GitHub:
   - Use a clear, descriptive title
   - Reference related issues
   - Describe what changes were made and why
   - Include screenshots for UI changes

### Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] All existing tests pass
- [ ] New tests added for changes
- [ ] Tested on iOS Simulator
- [ ] Tested on physical device (if applicable)

## Screenshots (if applicable)
Add screenshots here

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
```

## Reporting Bugs

### Before Reporting

1. Check if the bug has already been reported
2. Try to reproduce the issue
3. Check if it's fixed in the latest version

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
If applicable, add screenshots.

**Environment:**
- iOS Version: [e.g., 18.0]
- Device: [e.g., iPhone 16 Pro]
- App Version: [e.g., 1.0]

**Additional context**
Any other relevant information.
```

## Feature Requests

### Before Requesting

1. Check if the feature has already been requested
2. Consider if it aligns with the app's goals
3. Think about implementation complexity

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature.

**Use Case**
Why is this feature needed? What problem does it solve?

**Proposed Solution**
How would you implement this feature?

**Alternatives Considered**
Other solutions you've thought about.

**Additional Context**
Any other relevant information.
```

## Questions?

If you have questions about contributing:
- Open an issue with the `question` label
- Check existing issues and discussions
- Review the codebase and documentation

Thank you for contributing to OverLoad! 🎉

