import Foundation

class WorkoutSessionViewModel: ObservableObject {
    @Published var workoutSessions: [WorkoutSession] = []
    @Published var activeWorkout: WorkoutSession?
    @Published var lastError: AppError?
    
    private let persistenceService: PersistenceService
    
    init(persistenceService: PersistenceService = UserDefaultsPersistenceService()) {
        self.persistenceService = persistenceService
        do {
            try loadWorkoutSessions()
            try loadActiveWorkout()
        } catch {
            if let appError = error as? AppError {
                lastError = appError
            } else {
                lastError = AppError.persistenceError(error.localizedDescription)
            }
        }
    }

    func addWorkoutSession(_ session: WorkoutSession) throws {
        workoutSessions.append(session)
        workoutSessions.sort { $0.date > $1.date }
        try saveWorkoutSessions()
    }
    
    func updateWorkoutSession(_ session: WorkoutSession) throws {
        if let index = workoutSessions.firstIndex(where: { $0.id == session.id }) {
            workoutSessions[index] = session
            workoutSessions.sort { $0.date > $1.date }
            try saveWorkoutSessions()
        }
    }
    
    func saveActiveWorkout(_ session: WorkoutSession) throws {
        activeWorkout = session
        try persistenceService.save(session, forKey: "activeWorkout")
    }
    
    func loadActiveWorkout() throws {
        activeWorkout = try persistenceService.load(WorkoutSession.self, forKey: "activeWorkout")
    }
    
    func clearActiveWorkout() {
        activeWorkout = nil
        persistenceService.remove(forKey: "activeWorkout")
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = AppError.persistenceError(error.localizedDescription)
        }
    }
    
    func resumeWorkout() -> WorkoutSession? {
        guard let workout = activeWorkout, workout.isInProgress else { return nil }
        return workout
    }

    func saveWorkoutSessions() throws {
        try persistenceService.save(workoutSessions, forKey: "workoutSessions")
    }

    func loadWorkoutSessions() throws {
        workoutSessions = try persistenceService.load([WorkoutSession].self, forKey: "workoutSessions")
        workoutSessions.sort { $0.date > $1.date }
    }
}
