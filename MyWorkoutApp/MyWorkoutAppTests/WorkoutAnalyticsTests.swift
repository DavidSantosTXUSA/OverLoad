import Testing
@testable import MyWorkoutApp
import Foundation

struct WorkoutAnalyticsTests {
    
    @Test("WorkoutSession analytics - calculate total volume")
    func testWorkoutAnalyticsTotalVolume() {
        let exercise = Exercise(name: "Bench Press")
        let sets = [
            SetEntry(reps: 10, weight: 135),
            SetEntry(reps: 8, weight: 155),
            SetEntry(reps: 6, weight: 175)
        ]
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: sets)
        
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 0
        )
        
        let analytics = session.analytics
        // Volume = (10*135) + (8*155) + (6*175) = 1350 + 1240 + 1050 = 3640
        #expect(analytics.totalVolume == 3640.0)
    }
    
    @Test("WorkoutSession analytics - calculate average weight")
    func testWorkoutAnalyticsAverageWeight() {
        let exercise = Exercise(name: "Squat")
        let sets = [
            SetEntry(reps: 5, weight: 225),
            SetEntry(reps: 5, weight: 245),
            SetEntry(reps: 5, weight: 265)
        ]
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: sets)
        
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 0
        )
        
        let analytics = session.analytics
        // Average = (225 + 245 + 265) / 3 = 245
        #expect(analytics.averageWeight == 245.0)
    }
    
    @Test("WorkoutSession analytics - find max weight")
    func testWorkoutAnalyticsMaxWeight() {
        let exercise = Exercise(name: "Deadlift")
        let sets = [
            SetEntry(reps: 5, weight: 315),
            SetEntry(reps: 3, weight: 365),
            SetEntry(reps: 1, weight: 405)
        ]
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: sets)
        
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 0
        )
        
        let analytics = session.analytics
        #expect(analytics.maxWeight == 405.0)
    }
    
    @Test("WorkoutSession analytics - calculate total sets and reps")
    func testWorkoutAnalyticsSetsAndReps() {
        let exercise = Exercise(name: "Pull-ups")
        let sets = [
            SetEntry(reps: 10, weight: 0),
            SetEntry(reps: 8, weight: 0),
            SetEntry(reps: 6, weight: 0)
        ]
        let exerciseEntry = ExerciseEntry(exercise: exercise, sets: sets)
        
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [exerciseEntry],
            duration: 0
        )
        
        let analytics = session.analytics
        #expect(analytics.totalSets == 3)
        #expect(analytics.totalReps == 24)
        #expect(analytics.averageReps == 8.0)
    }
    
    @Test("WorkoutSessionViewModel - get statistics")
    func testGetStatistics() {
        let viewModel = WorkoutSessionViewModel()
        
        // Add some test workouts
        let exercise1 = Exercise(name: "Bench Press")
        let exercise2 = Exercise(name: "Squat")
        
        let session1 = WorkoutSession(
            templateID: UUID(),
            name: "Workout 1",
            date: Date(),
            exerciseEntries: [
                ExerciseEntry(exercise: exercise1, sets: [SetEntry(reps: 10, weight: 135)])
            ],
            duration: 1200,
            isInProgress: false
        )
        session1.isCompleted = true
        
        let session2 = WorkoutSession(
            templateID: UUID(),
            name: "Workout 2",
            date: Date(),
            exerciseEntries: [
                ExerciseEntry(exercise: exercise2, sets: [SetEntry(reps: 8, weight: 225)])
            ],
            duration: 1800,
            isInProgress: false
        )
        session2.isCompleted = true
        
        do {
            try viewModel.addWorkoutSession(session1)
            try viewModel.addWorkoutSession(session2)
            
            let stats = viewModel.getStatistics()
            #expect(stats.totalWorkouts >= 2)
            #expect(stats.exercisesPerformed >= 2)
            #expect(stats.totalVolume > 0)
        } catch {
            Issue.record("Failed to add test sessions: \(error)")
        }
    }
    
    @Test("WorkoutSessionViewModel - get exercise PRs")
    func testGetExercisePRs() {
        let viewModel = WorkoutSessionViewModel()
        
        let exercise = Exercise(name: "Bench Press")
        let date1 = Date()
        let date2 = Date().addingTimeInterval(86400) // Next day
        
        let session1 = WorkoutSession(
            templateID: UUID(),
            name: "Workout 1",
            date: date1,
            exerciseEntries: [
                ExerciseEntry(exercise: exercise, sets: [SetEntry(reps: 10, weight: 135)])
            ],
            duration: 0,
            isInProgress: false
        )
        session1.isCompleted = true
        
        let session2 = WorkoutSession(
            templateID: UUID(),
            name: "Workout 2",
            date: date2,
            exerciseEntries: [
                ExerciseEntry(exercise: exercise, sets: [SetEntry(reps: 8, weight: 155)])
            ],
            duration: 0,
            isInProgress: false
        )
        session2.isCompleted = true
        
        do {
            try viewModel.addWorkoutSession(session1)
            try viewModel.addWorkoutSession(session2)
            
            let prs = viewModel.getExercisePRs()
            let benchPR = prs.first { $0.exercise.name == "Bench Press" }
            
            #expect(benchPR != nil)
            #expect(benchPR?.maxWeight == 155.0) // Higher weight from session2
            #expect(benchPR?.maxReps == 10) // Higher reps from session1
        } catch {
            Issue.record("Failed to add test sessions: \(error)")
        }
    }
}

