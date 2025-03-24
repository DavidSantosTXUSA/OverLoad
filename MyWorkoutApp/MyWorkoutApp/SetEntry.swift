import Foundation

struct SetEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var reps: Int
    var weight: Double

    init(id: UUID = UUID(), reps: Int, weight: Double) {
        self.id = id
        self.reps = reps
        self.weight = weight
    }
}
