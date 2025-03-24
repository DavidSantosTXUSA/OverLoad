import Foundation

struct ExerciseEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var exercise: Exercise
    var sets: [SetEntry]

    init(id: UUID = UUID(), exercise: Exercise, sets: [SetEntry]) {
        self.id = id
        self.exercise = exercise
        self.sets = sets
    }
}
