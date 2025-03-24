import Foundation


class WorkoutTemplateViewModel: ObservableObject {
    @Published var workoutTemplates: [WorkoutTemplate] = []

    init() {
        loadWorkoutTemplates()
    }

    func addWorkoutTemplate(_ template: WorkoutTemplate) {
        workoutTemplates.append(template)
        saveWorkoutTemplates()
    }

    func saveWorkoutTemplates() {
        if let encoded = try? JSONEncoder().encode(workoutTemplates) {
            UserDefaults.standard.set(encoded, forKey: "workoutTemplates")
        }
    }

    func loadWorkoutTemplates() {
        if let data = UserDefaults.standard.data(forKey: "workoutTemplates"),
           let decoded = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) {
            workoutTemplates = decoded
        }
    }
}
