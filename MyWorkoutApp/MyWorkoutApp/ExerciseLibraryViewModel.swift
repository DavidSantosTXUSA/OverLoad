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
        exercises = try persistenceService.load([Exercise].self, forKey: "exercises")
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = AppError.persistenceError(error.localizedDescription)
        }
    }
}
