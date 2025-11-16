import Foundation
import SwiftUI

class RestTimer: ObservableObject {
    @Published var isRunning = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalRestTime: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    var duration: TimeInterval {
        return totalRestTime
    }
    
    func start(duration: TimeInterval) {
        totalRestTime = duration
        timeRemaining = duration
        isRunning = true
        startTime = Date()
        pausedTime = 0
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            let elapsed = Date().timeIntervalSince(startTime) + self.pausedTime
            self.timeRemaining = max(0, self.totalRestTime - elapsed)
            
            if self.timeRemaining <= 0 {
                self.stop()
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func pause() {
        if isRunning {
            pausedTime += Date().timeIntervalSince(startTime ?? Date())
            timer?.invalidate()
            timer = nil
            isRunning = false
        }
    }
    
    func resume() {
        if !isRunning && timeRemaining > 0 {
            startTime = Date()
            isRunning = true
            
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self = self, let startTime = self.startTime else { return }
                let elapsed = Date().timeIntervalSince(startTime) + self.pausedTime
                self.timeRemaining = max(0, self.totalRestTime - elapsed)
                
                if self.timeRemaining <= 0 {
                    self.stop()
                }
            }
            RunLoop.main.add(timer!, forMode: .common)
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        timeRemaining = 0
        startTime = nil
        pausedTime = 0
    }
    
    func reset() {
        stop()
        totalRestTime = 0
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

