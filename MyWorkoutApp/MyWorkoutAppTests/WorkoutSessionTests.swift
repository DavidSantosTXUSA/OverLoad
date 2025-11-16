import Testing
@testable import MyWorkoutApp
import Foundation

struct WorkoutSessionTests {
    
    @Test("WorkoutSession - currentElapsedTime when timer not started")
    func testCurrentElapsedTimeNoTimer() {
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 0
        )
        #expect(session.currentElapsedTime == 0)
    }
    
    @Test("WorkoutSession - currentElapsedTime when timer started")
    func testCurrentElapsedTimeWithTimer() async throws {
        let startTime = Date().addingTimeInterval(-60) // 60 seconds ago
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 0,
            isInProgress: true,
            timerStartTime: startTime
        )
        // Should be approximately 60 seconds (allow some tolerance)
        let elapsed = session.currentElapsedTime
        #expect(elapsed >= 59 && elapsed <= 61)
    }
    
    @Test("WorkoutSession - totalDuration when not in progress")
    func testTotalDurationNotInProgress() {
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 120
        )
        #expect(session.totalDuration == 120)
    }
    
    @Test("WorkoutSession - totalDuration when in progress")
    func testTotalDurationInProgress() async throws {
        let startTime = Date().addingTimeInterval(-30) // 30 seconds ago
        let session = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 60,
            isInProgress: true,
            timerStartTime: startTime
        )
        // Should be approximately 90 seconds (60 + 30)
        let total = session.totalDuration
        #expect(total >= 89 && total <= 91)
    }
    
    @Test("WorkoutSession - isInProgress flag")
    func testIsInProgressFlag() {
        let session1 = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 0,
            isInProgress: true
        )
        #expect(session1.isInProgress == true)
        
        let session2 = WorkoutSession(
            templateID: UUID(),
            name: "Test",
            date: Date(),
            exerciseEntries: [],
            duration: 0,
            isInProgress: false
        )
        #expect(session2.isInProgress == false)
    }
}

