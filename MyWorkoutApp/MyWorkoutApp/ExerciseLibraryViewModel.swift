import Foundation

class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []

    init() {
        loadExercises()
    }

    func addExercise(name: String) {
        let newExercise = Exercise(name: name)
        exercises.append(newExercise)
        saveExercises()
    }

    func removeExercise(at offsets: IndexSet) {
        exercises.remove(atOffsets: offsets)
        saveExercises()  // Save the updated exercise list
    }

    func saveExercises() {
        if let encoded = try? JSONEncoder().encode(exercises) {
            UserDefaults.standard.set(encoded, forKey: "exercises")
        }
    }

    func loadExercises() {
        if let data = UserDefaults.standard.data(forKey: "exercises"),
           let decoded = try? JSONDecoder().decode([Exercise].self, from: data) {
            exercises = decoded
        } else {
            exercises = []
        }
    }
}
