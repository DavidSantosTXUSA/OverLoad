# OverLoad

An iOS app designed to help users track and manage their workouts effortlessly. Built with SwiftUI and Swift in Xcode!

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Data Models](#data-models)
- [Key Features Details](#key-features-details)
- [Project Structure](#project-structure)
- [User Workflow](#user-workflow)
- [Technical Details](#technical-details)
- [Visual Components](#visual-components)
- [Development Notes](#development-notes)
- [Screenshots](#-screenshots)
- [Future Improvements](#future-improvements)
- [Getting Started](#getting-started)

## Overview

OverLoad is a comprehensive workout tracking application that allows users to create workout templates, log exercise sessions with sets and reps, track progress over time, and use built-in calculators for plate loading and RPE (Rate of Perceived Exertion) calculations. The app features a modern dark-themed UI with neon accents and provides a seamless workout logging experience.

## Features

### Core Features
- **Workout Templates**: Create reusable workout templates with custom exercises
- **Exercise Library**: Build and manage a personal library of exercises
- **Workout Logging**: Log workout sessions with sets, reps, and weights
- **Workout Timer**: Built-in timer to track workout duration
- **Progress Tracking**: View completed workout history with detailed session information
- **Plate Calculator**: Calculate plate loading for barbells in both pounds (lbs) and kilograms (kg)
  - Input mode: Enter target weight and get plate configuration
  - Reverse mode: Select plates visually and calculate total weight
  - Visual barbell representation
- **RPE Calculator**: Estimate 1RM (One Rep Max) based on weight, reps, and RPE
- **Data Persistence**: All data is saved locally using UserDefaults
- **Dark Mode UI**: Modern dark-themed interface with neon green/cyan accents

## Architecture

The app follows the **MVVM (Model-View-ViewModel)** architecture pattern:

### Models
- **`WorkoutTemplate`**: Represents a reusable workout template with a name and list of exercises
- **`Exercise`**: Represents an individual exercise with a name
- **`WorkoutSession`**: Represents a completed or in-progress workout session with date, duration, and exercise entries
- **`ExerciseEntry`**: Links an exercise to its sets within a workout session
- **`SetEntry`**: Represents a single set with reps and weight

### ViewModels
- **`WorkoutTemplateViewModel`**: Manages workout templates (CRUD operations, persistence)
- **`ExerciseLibraryViewModel`**: Manages the exercise library (add, remove, persistence)
- **`WorkoutSessionViewModel`**: Manages workout sessions (add, load, save, sorting)

### Views
- **`WorkoutApp`**: Main app entry point with TabView navigation
- **`WorkoutListView`**: Displays list of workout templates
- **`CreateWorkoutView`**: Interface for creating new workout templates
- **`WorkoutDetailView`**: Active workout session interface with timer and set logging
- **`ProgressView`**: Displays completed workout history
- **`CalcView`**: Container for calculator tools (Plate Calculator and RPE Calculator)
- **`PlateCalculatorView`**: Plate loading calculator with visual barbell
- **`RPECalculatorView`**: RPE-based 1RM calculator
- **`EditWorkoutView`**: Edit completed workout sessions (modify sets, reps, and weights)

## Data Models

### WorkoutTemplate
```swift
struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [Exercise]
}
```

### Exercise
```swift
struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
}
```

### WorkoutSession
```swift
struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var templateID: UUID
    var name: String
    var date: Date
    var exerciseEntries: [ExerciseEntry]
    var duration: TimeInterval
    var isCompleted: Bool
}
```

### ExerciseEntry
```swift
struct ExerciseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var exercise: Exercise
    var sets: [SetEntry]
}
```

### SetEntry
```swift
struct SetEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var reps: Int
    var weight: Double
}
```

## Key Features Details

### Plate Calculator
- **Input Mode**: Enter target weight and bar weight to calculate required plates
- **Reverse Mode**: Visually select plates to calculate total barbell weight
- **Unit Conversion**: Switch between pounds (lbs) and kilograms (kg)
- **Visual Representation**: Barbell view showing plate arrangement
- **Available Plates**:
  - LBS: 45, 35, 25, 10, 5, 2.5
  - KG: 25, 20, 15, 10, 5, 2.5, 1.25

### RPE Calculator
- Calculates estimated 1RM based on:
  - Weight lifted
  - Number of reps (1-10)
  - RPE (Rate of Perceived Exertion: 7.5-10.0)
- Supports both lbs and kg
- Uses standard RPE percentage tables

### Workout Timer
- Start/stop timer functionality
- Tracks total workout duration
- Timer must be running to add sets (prevents accidental logging)

### Data Persistence
- All data stored locally using `UserDefaults`
- Automatic saving on data modifications
- Data persists between app launches
- Keys used:
  - `"workoutTemplates"`: Workout templates
  - `"workoutSessions"`: Workout session history
  - `"exercises"`: Exercise library

## Project Structure

```
MyWorkoutApp/
├── MyWorkoutApp/
│   ├── WorkoutApp.swift              # Main app entry point
│   ├── Models/
│   │   ├── WorkoutTemplate.swift
│   │   ├── Exercise.swift
│   │   ├── WorkoutSession.swift
│   │   ├── ExerciseEntry.swift
│   │   └── SetEntry.swift
│   ├── ViewModels/
│   │   ├── WorkoutTemplateViewModel.swift
│   │   ├── ExerciseLibraryViewModel.swift
│   │   └── WorkoutSessionViewModel.swift
│   ├── Views/
│   │   ├── WorkoutListView.swift
│   │   ├── CreateWorkoutView.swift
│   │   ├── WorkoutDetailView.swift
│   │   ├── ProgressView.swift
│   │   ├── CalcView.swift
│   │   ├── PlateCalculatorView.swift
│   │   ├── RPECalculatorView.swift
│   │   ├── BarbellView.swift
│   │   ├── PlateView.swift
│   │   └── PlatePickerGrid.swift
│   └── Helpers/
│       ├── Helpers.swift
│       └── KeyboardDismissModifier.swift
└── README.md
```

## User Workflow

1. **Create Exercise Library**: Add exercises to your library from the Create Workout screen
2. **Create Workout Template**: Select exercises from your library to create a reusable workout template
3. **Start Workout**: Select a template from the Workouts tab to begin a session
4. **Log Sets**: Start the timer, then add sets with reps and weights for each exercise
5. **Finish Workout**: Stop the timer and finish the workout to save it to history
6. **View Progress**: Check the Progress tab to see all completed workouts
7. **Use Calculators**: Access plate and RPE calculators from the Calc tab

## Technical Details

### Dependencies
- **SwiftUI**: Modern declarative UI framework
- **Foundation**: Core Swift functionality
- **UIKit**: Used for keyboard dismissal helper

### Minimum Requirements
- iOS 14.0+ (SwiftUI support)
- Xcode 12.0+

### Color Scheme
- Background: Black
- Primary Accent: Green (neon)
- Secondary Accent: Cyan
- Text: White/Gray
- Forced dark mode throughout the app

### Keyboard Handling
- Custom `KeyboardDismissModifier` allows tapping anywhere to dismiss keyboard
- Applied to all views with text input

### Visual Components

#### BarbellView
- Visual representation of a barbell with plates loaded on one side
- Shows bar shaft, grip zone, and sleeve
- Displays plates stacked in order with proper sizing

#### PlateView
- Individual plate visualization with:
  - Color coding based on weight (matches competition standards)
  - Size proportional to weight (larger plates = bigger visual)
  - Weight label and unit (lbs/kg)
  - Index numbers for large plates (45lb/25kg)
- **Color Scheme**:
  - **KG**: Red (25kg), Blue (20kg), Yellow (15kg), Green (10kg), White (5kg), Gray (2.5kg/1.25kg)
  - **LBS**: Blue (45lb), Yellow (35lb), Green (25lb), Dark (10lb/5lb/2.5lb)

#### PlatePickerGrid
- Interactive grid for selecting plates in reverse calculator mode
- Shows all available plates with +/- buttons
- Displays count of each selected plate
- Color-coded to match PlateView

## Development Notes

### Data Flow
1. **Workout Templates**: Created in `CreateWorkoutView` → Saved via `WorkoutTemplateViewModel` → Displayed in `WorkoutListView`
2. **Workout Sessions**: Created from templates in `WorkoutDetailView` → Logged during workout → Saved via `WorkoutSessionViewModel` → Displayed in `ProgressView`
3. **Exercise Library**: Managed in `ExerciseLibraryViewModel` → Used when creating workout templates

### Key Implementation Details
- **State Management**: Uses `@StateObject` and `@ObservedObject` for ViewModels
- **Persistence**: All ViewModels handle their own save/load operations using UserDefaults
- **Navigation**: Uses SwiftUI NavigationView and NavigationLink
- **Timer**: Uses `Timer.scheduledTimer` for workout duration tracking
- **Unit Conversion**: Plate calculator handles real-time conversion between lbs and kg
- **RPE Table**: Hardcoded RPE percentage table based on standard powerlifting formulas

### Known Limitations
- Data stored in UserDefaults (not suitable for large datasets)
- No cloud sync or backup functionality
- No data export feature
- Exercise library is shared across all workouts (no per-workout exercises)
- Timer resets when navigating away from workout detail view

## 📸 Screenshots

| Home Screen | Workouts Saved | Workout History |
|-------------|----------------|-----------------|
| ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.28.52.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.28.55.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.28.59.png) |

| Workout Creation | Workout Creation | Workout Creation |
|-------------|------------------|----------|
| ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.29.04.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.29.28.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.30.03.png) |

| New Workout Saved | Workout Logger and Timer | Workout History |
|-------------------|----------------|----------------|
| ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.30.06.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.30.19.png) | ![](./Simulator%20Screenshot%20-%20iPhone%2016%20Pro%20-%202025-03-25%20at%2019.30.25.png) |


## Future Improvements

- **Goal-Setting Feature**: Allow users to set personal goals and milestones
- **Enhanced Analytics**: Provide more in-depth analysis of workout progress with charts and graphs
- **Social Sharing**: Enable sharing achievements with friends on social media
- **Cloud Sync**: Add iCloud or other cloud storage for data backup and sync across devices
- **Data Export**: Export workout data to CSV or JSON format
- **Rest Timer**: Built-in rest timer between sets
- **Exercise Notes**: Add notes field for exercises and sets
- **Workout Templates Sharing**: Share workout templates with other users
- **Body Weight Tracking**: Track body weight alongside workouts
- **Volume Calculations**: Automatic calculation of total volume (sets × reps × weight)
- **Progressive Overload Tracking**: Visual indicators for progressive overload
- **Exercise History**: View historical performance for specific exercises
- **Workout Statistics**: Weekly/monthly statistics and trends

## Getting Started

### Prerequisites
- Xcode (latest version recommended)
- iOS device or Simulator

### Installation
1. Clone the repository:
   
```
   git clone https://github.com/yourusername/WorkoutApp.git
```
2. Open project in Xcode
```
   cd WorkoutApp
   open WorkoutApp.xcodeproj
```
3. Run the app! Have fun :)
