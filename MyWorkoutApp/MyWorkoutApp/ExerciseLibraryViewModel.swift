import Foundation

class ExerciseLibraryViewModel: ObservableObject {
    @Published var exercises: [Exercise] = []
    @Published var lastError: AppError?
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = UserDefaultsPersistenceService()) {
        self.persistenceService = persistenceService
        do {
            try loadExercises()
        } catch {
            if let appError = error as? AppError {
                lastError = appError
            } else {
                lastError = AppError.persistenceError(error.localizedDescription)
            }
        }
    }

    func addExercise(name: String) throws {
        let newExercise = Exercise(name: name)
        exercises.append(newExercise)
        try saveExercises()
    }

    func removeExercise(at offsets: IndexSet) throws {
        exercises.remove(atOffsets: offsets)
        try saveExercises()
    }

    func saveExercises() throws {
        try persistenceService.save(exercises, forKey: "exercises")
    }

    func loadExercises() throws {
        if let loaded = try persistenceService.load([Exercise].self, forKey: "exercises") {
            exercises = loaded
        } else {
            // First time setup - add default exercises
            exercises = getDefaultExercises()
            try saveExercises()
        }
    }
    
    private func getDefaultExercises() -> [Exercise] {
        return [
            "Bench Press",
            "Squat",
            "Deadlift",
            "Overhead Press",
            "Barbell Row",
            "Pull-ups",
            "Dips",
            "Barbell Curl",
            "Tricep Extension",
            "Leg Press",
            "Romanian Deadlift",
            "Front Squat",
            "Incline Bench Press",
            "Lat Pulldown",
            "Cable Row",
            "Lateral Raise",
            "Face Pull",
            "Leg Curl",
            "Leg Extension",
            "Calf Raise"
        ].map { Exercise(name: $0) }
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = AppError.persistenceError(error.localizedDescription)
        }
    }
}
