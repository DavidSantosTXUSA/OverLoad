import Foundation

class WorkoutTemplateViewModel: ObservableObject {
    @Published var workoutTemplates: [WorkoutTemplate] = []
    @Published var lastError: AppError?
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = UserDefaultsPersistenceService()) {
        self.persistenceService = persistenceService
        do {
            try loadWorkoutTemplates()
        } catch {
            if let appError = error as? AppError {
                lastError = appError
            } else {
                lastError = AppError.persistenceError(error.localizedDescription)
            }
        }
    }

    func addWorkoutTemplate(_ template: WorkoutTemplate) throws {
        workoutTemplates.append(template)
        try saveWorkoutTemplates()
    }

    func saveWorkoutTemplates() throws {
        try persistenceService.save(workoutTemplates, forKey: "workoutTemplates")
    }

    func loadWorkoutTemplates() throws {
        workoutTemplates = try persistenceService.load([WorkoutTemplate].self, forKey: "workoutTemplates")
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = AppError.persistenceError(error.localizedDescription)
        }
    }
}
