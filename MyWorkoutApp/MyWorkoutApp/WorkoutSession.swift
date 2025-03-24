import Foundation

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var templateID: UUID
    var name: String
    var date: Date
    var exerciseEntries: [ExerciseEntry]
    var duration: TimeInterval
    var isCompleted: Bool = false
    
    init(id: UUID = UUID(), templateID: UUID, name: String, date: Date, exerciseEntries: [ExerciseEntry], duration: TimeInterval) {
        self.id = id
        self.templateID = templateID
        self.name = name
        self.date = date
        self.exerciseEntries = exerciseEntries
        self.duration = duration
    }
}
