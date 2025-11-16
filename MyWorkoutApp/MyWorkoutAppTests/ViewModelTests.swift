import Testing
@testable import MyWorkoutApp
import Foundation

struct ViewModelTests {
    
    @Test("WorkoutSessionViewModel - add workout session")
    func testAddWorkoutSession() throws {
        let viewModel = WorkoutSessionViewModel()
        let initialCount = viewModel.workoutSessions.count
        
        let exercise = Exercise(name: "Bench Press")
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: [])
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test Workout",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 120
        )
        
        try viewModel.addWorkoutSession(session)
        #expect(viewModel.workoutSessions.count == initialCount + 1)
        #expect(viewModel.workoutSessions.first?.name == "Test Workout")
    }
    
    @Test("WorkoutSessionViewModel - save and load active workout")
    func testSaveAndLoadActiveWorkout() throws {
        let viewModel = WorkoutSessionViewModel()
        
        let exercise = Exercise(name: "Squat")
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: [])
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Active Workout",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 60,
            isInProgress: true
        )
        
        try viewModel.saveActiveWorkout(session)
        #expect(viewModel.activeWorkout?.name == "Active Workout")
        #expect(viewModel.activeWorkout?.isInProgress == true)
    }
    
    @Test("WorkoutSessionViewModel - clear active workout")
    func testClearActiveWorkout() throws {
        let viewModel = WorkoutSessionViewModel()
        
        let exercise = Exercise(name: "Deadlift")
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: [])
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Active Workout",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 0,
            isInProgress: true
        )
        
        try viewModel.saveActiveWorkout(session)
        #expect(viewModel.activeWorkout != nil)
        
        viewModel.clearActiveWorkout()
        #expect(viewModel.activeWorkout == nil)
    }
    
    @Test("WorkoutTemplateViewModel - add workout template")
    func testAddWorkoutTemplate() throws {
        let viewModel = WorkoutTemplateViewModel()
        let initialCount = viewModel.workoutTemplates.count
        
        let exercise = Exercise(name: "Pull-ups")
        let template = WorkoutTemplate(
            name: "Back Day",
            exercises: [exercise]
        )
        
        try viewModel.addWorkoutTemplate(template)
        #expect(viewModel.workoutTemplates.count == initialCount + 1)
        #expect(viewModel.workoutTemplates.first?.name == "Back Day")
    }
    
    @Test("ExerciseLibraryViewModel - add exercise")
    func testAddExercise() throws {
        let viewModel = ExerciseLibraryViewModel()
        let initialCount = viewModel.exercises.count
        
        try viewModel.addExercise(name: "Push-ups")
        #expect(viewModel.exercises.count == initialCount + 1)
        #expect(viewModel.exercises.first?.name == "Push-ups")
    }
    
    @Test("ExerciseLibraryViewModel - remove exercise")
    func testRemoveExercise() throws {
        let viewModel = ExerciseLibraryViewModel()
        
        try viewModel.addExercise(name: "Exercise 1")
        try viewModel.addExercise(name: "Exercise 2")
        let countBefore = viewModel.exercises.count
        
        try viewModel.removeExercise(at: IndexSet(integer: 0))
        #expect(viewModel.exercises.count == countBefore - 1)
    }
    
    @Test("WorkoutSessionViewModel - error handling on invalid data")
    func testErrorHandling() {
        let viewModel = WorkoutSessionViewModel()
        
        // Try to load corrupted data (this should be handled gracefully)
        // The init should catch errors and set lastError
        // Since we can't easily corrupt UserDefaults in a test, we'll test error handling differently
        
        // Test that handleError works
        let testError = AppError.persistenceError("Test error")
        viewModel.handleError(testError)
        #expect(viewModel.lastError != nil)
    }
}

