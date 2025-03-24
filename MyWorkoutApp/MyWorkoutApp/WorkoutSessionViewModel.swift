import Foundation

class WorkoutSessionViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []

    init() {
        loadWorkoutSessions()
    }

    func addWorkoutSession(_ session: WorkoutSession) {
        workoutSessions.append(session)
        workoutSessions.sort { $0.date > $1.date }
        saveWorkoutSessions()
    }

    func saveWorkoutSessions() {
        do {
            let encoded = try JSONEncoder().encode(workoutSessions)
            UserDefaults.standard.set(encoded, forKey: "workoutSessions")
        } catch {
            print("❌ Failed to encode workout sessions:", error)
        }
    }

    func loadWorkoutSessions() {
        if let data = UserDefaults.standard.data(forKey: "workoutSessions") {
            do {
                let decoded = try JSONDecoder().decode([WorkoutSession].self, from: data)
                workoutSessions = decoded.sorted { $0.date > $1.date }
            } catch {
                print("❌ Failed to decode workout sessions:", error)
                workoutSessions = []
            }
        } else {
            workoutSessions = []
        }
    }
}
