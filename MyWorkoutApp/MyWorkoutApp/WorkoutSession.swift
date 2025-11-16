import Foundation

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var templateID: UUID
    var name: String
    var date: Date
    var exerciseEntries: [ExerciseEntry]
    var duration: TimeInterval
    var isCompleted: Bool = false
    var isInProgress: Bool = false
    var timerStartTime: Date?
    var lastSavedTime: Date?
    
    init(id: UUID = UUID(), templateID: UUID, name: String, date: Date, exerciseEntries: [ExerciseEntry], duration: TimeInterval, isInProgress: Bool = false, timerStartTime: Date? = nil, lastSavedTime: Date? = nil) {
        self.id = id
        self.templateID = templateID
        self.name = name
        self.date = date
        self.exerciseEntries = exerciseEntries
        self.duration = duration
        self.isInProgress = isInProgress
        self.timerStartTime = timerStartTime
        self.lastSavedTime = lastSavedTime
    }
    
    // Calculate elapsed time if timer is running
    var currentElapsedTime: TimeInterval {
        guard let startTime = timerStartTime else { return 0 }
        return Date().timeIntervalSince(startTime)
    }
    
    // Total duration including current elapsed time
    var totalDuration: TimeInterval {
        if isInProgress, let startTime = timerStartTime {
            return duration + Date().timeIntervalSince(startTime)
        }
        return duration
    }
}
