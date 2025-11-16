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
        if let loaded = try persistenceService.load([WorkoutTemplate].self, forKey: "workoutTemplates") {
            workoutTemplates = loaded
        } else {
            // First time setup - add example workouts
            workoutTemplates = getExampleWorkouts()
            try saveWorkoutTemplates()
        }
    }
    
    private func getExampleWorkouts() -> [WorkoutTemplate] {
        // Create exercises that match the default exercises (by name)
        // These will be matched to actual exercises in the library when templates are used
        let benchPress = Exercise(name: "Bench Press")
        let squat = Exercise(name: "Squat")
        let deadlift = Exercise(name: "Deadlift")
        let overheadPress = Exercise(name: "Overhead Press")
        let barbellRow = Exercise(name: "Barbell Row")
        let pullUps = Exercise(name: "Pull-ups")
        let dips = Exercise(name: "Dips")
        let barbellCurl = Exercise(name: "Barbell Curl")
        let tricepExtension = Exercise(name: "Tricep Extension")
        let legPress = Exercise(name: "Leg Press")
        let romanianDeadlift = Exercise(name: "Romanian Deadlift")
        let frontSquat = Exercise(name: "Front Squat")
        let inclineBench = Exercise(name: "Incline Bench Press")
        let latPulldown = Exercise(name: "Lat Pulldown")
        let cableRow = Exercise(name: "Cable Row")
        let lateralRaise = Exercise(name: "Lateral Raise")
        let facePull = Exercise(name: "Face Pull")
        let legCurl = Exercise(name: "Leg Curl")
        let legExtension = Exercise(name: "Leg Extension")
        let calfRaise = Exercise(name: "Calf Raise")
        
        return [
            WorkoutTemplate(
                name: "Push Day",
                exercises: [benchPress, overheadPress, inclineBench, dips, tricepExtension, lateralRaise]
            ),
            WorkoutTemplate(
                name: "Pull Day",
                exercises: [deadlift, barbellRow, pullUps, latPulldown, cableRow, facePull, barbellCurl]
            ),
            WorkoutTemplate(
                name: "Leg Day",
                exercises: [squat, frontSquat, romanianDeadlift, legPress, legCurl, legExtension, calfRaise]
            ),
            WorkoutTemplate(
                name: "Full Body",
                exercises: [squat, benchPress, deadlift, overheadPress, barbellRow, pullUps]
            ),
            WorkoutTemplate(
                name: "Upper Body",
                exercises: [benchPress, overheadPress, barbellRow, pullUps, dips, barbellCurl]
            )
        ]
    }
    
    func handleError(_ error: Error) {
        if let appError = error as? AppError {
            lastError = appError
        } else {
            lastError = AppError.persistenceError(error.localizedDescription)
        }
    }
}
