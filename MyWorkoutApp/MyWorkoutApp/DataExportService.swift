import Foundation
import SwiftUI

class DataExportService {
    
    static func exportToJSON(workoutSessions: [WorkoutSession], workoutTemplates: [WorkoutTemplate], exercises: [Exercise]) throws -> Data {
        let exportData: [String: Any] = [
            "workoutSessions": workoutSessions.map { session in
                [
                    "id": session.id.uuidString,
                    "templateID": session.templateID.uuidString,
                    "name": session.name,
                    "date": ISO8601DateFormatter().string(from: session.date),
                    "duration": session.duration,
                    "isCompleted": session.isCompleted,
                    "exerciseEntries": session.exerciseEntries.map { entry in
                        [
                            "id": entry.id.uuidString,
                            "exercise": [
                                "id": entry.exercise.id.uuidString,
                                "name": entry.exercise.name
                            ],
                            "sets": entry.sets.map { set in
                                [
                                    "id": set.id.uuidString,
                                    "reps": set.reps,
                                    "weight": set.weight
                                ]
                            }
                        ]
                    }
                ]
            },
            "workoutTemplates": workoutTemplates.map { template in
                [
                    "id": template.id.uuidString,
                    "name": template.name,
                    "exercises": template.exercises.map { exercise in
                        [
                            "id": exercise.id.uuidString,
                            "name": exercise.name
                        ]
                    }
                ]
            },
            "exercises": exercises.map { exercise in
                [
                    "id": exercise.id.uuidString,
                    "name": exercise.name
                ]
            },
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": "1.0"
        ]
        
        return try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    static func exportToCSV(workoutSessions: [WorkoutSession]) -> String {
        var csv = "Date,Workout Name,Duration (seconds),Exercise,Set,Reps,Weight (lbs),Volume\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for session in workoutSessions.filter({ $0.isCompleted }) {
            let dateString = dateFormatter.string(from: session.date)
            let duration = Int(session.duration)
            
            for exerciseEntry in session.exerciseEntries {
                for (index, set) in exerciseEntry.sets.enumerated() {
                    let volume = set.weight * Double(set.reps)
                    csv += "\"\(dateString)\",\"\(session.name)\",\(duration),\"\(exerciseEntry.exercise.name)\",\(index + 1),\(set.reps),\(set.weight),\(volume)\n"
                }
            }
        }
        
        return csv
    }
    
    static func shareData(data: Data, filename: String, mimeType: String) -> [Any] {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try data.write(to: tempURL)
            return [tempURL]
        } catch {
            return []
        }
    }
}

extension WorkoutSessionViewModel {
    func exportToJSON() throws -> Data {
        // Get all data from ViewModels
        // Note: This would need access to other ViewModels, so we'll pass them as parameters
        return Data()
    }
    
    func exportToCSV() -> String {
        return DataExportService.exportToCSV(workoutSessions: workoutSessions)
    }
}

