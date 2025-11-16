import Testing
@testable import MyWorkoutApp
import Foundation

struct RestTimerTests {
    
    @Test("RestTimer - start timer")
    func testStartTimer() {
        let timer = RestTimer()
        timer.start(duration: 60)
        
        #expect(timer.isRunning == true)
        #expect(timer.timeRemaining <= 60)
        #expect(timer.timeRemaining >= 59) // Allow 1 second tolerance
        #expect(timer.totalRestTime == 60)
    }
    
    @Test("RestTimer - stop timer")
    func testStopTimer() {
        let timer = RestTimer()
        timer.start(duration: 60)
        #expect(timer.isRunning == true)
        
        timer.stop()
        #expect(timer.isRunning == false)
        #expect(timer.timeRemaining == 0)
    }
    
    @Test("RestTimer - pause and resume")
    func testPauseAndResume() async throws {
        let timer = RestTimer()
        timer.start(duration: 60)
        #expect(timer.isRunning == true)
        
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        timer.pause()
        #expect(timer.isRunning == false)
        let timeWhenPaused = timer.timeRemaining
        
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        // Time should not have changed while paused
        #expect(timer.timeRemaining == timeWhenPaused)
        
        timer.resume()
        #expect(timer.isRunning == true)
    }
    
    @Test("RestTimer - format time")
    func testFormatTime() {
        let timer = RestTimer()
        
        #expect(timer.formatTime(0) == "0:00")
        #expect(timer.formatTime(30) == "0:30")
        #expect(timer.formatTime(60) == "1:00")
        #expect(timer.formatTime(90) == "1:30")
        #expect(timer.formatTime(125) == "2:05")
    }
    
    @Test("RestTimer - reset")
    func testReset() {
        let timer = RestTimer()
        timer.start(duration: 60)
        timer.reset()
        
        #expect(timer.isRunning == false)
        #expect(timer.timeRemaining == 0)
        #expect(timer.totalRestTime == 0)
    }
}

