import Foundation

struct InputValidators {
    static let minWeight: Double = 0
    static let maxWeight: Double = 1000
    static let minReps: Int = 0
    static let maxReps: Int = 100
    
    static func validateWeight(_ weight: Double) -> Bool {
        return weight >= minWeight && weight <= maxWeight
    }
    
    static func validateReps(_ reps: Int) -> Bool {
        return reps >= minReps && reps <= maxReps
    }
    
    static func clampWeight(_ weight: Double) -> Double {
        return max(minWeight, min(maxWeight, weight))
    }
    
    static func clampReps(_ reps: Int) -> Int {
        return max(minReps, min(maxReps, reps))
    }
}

