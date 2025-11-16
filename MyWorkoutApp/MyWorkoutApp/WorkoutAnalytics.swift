import Foundation

struct WorkoutAnalytics {
    let totalVolume: Double
    let averageWeight: Double
    let maxWeight: Double
    let totalSets: Int
    let totalReps: Int
    let averageReps: Double
}

struct ExercisePR {
    let exercise: Exercise
    let maxWeight: Double
    let maxReps: Int
    let maxVolume: Double
    let estimated1RM: Double?
    let date: Date
}

struct WorkoutStatistics {
    let totalWorkouts: Int
    let totalVolume: Double
    let averageWorkoutDuration: TimeInterval
    let totalDuration: TimeInterval
    let exercisesPerformed: Int
    let uniqueExercises: [Exercise]
}

extension WorkoutSession {
    var analytics: WorkoutAnalytics {
        var totalVolume: Double = 0
        var totalWeight: Double = 0
        var totalSets: Int = 0
        var totalReps: Int = 0
        var maxWeight: Double = 0
        
        for exerciseEntry in exerciseEntries {
            for set in exerciseEntry.sets {
                let volume = set.weight * Double(set.reps)
                totalVolume += volume
                totalWeight += set.weight
                totalSets += 1
                totalReps += set.reps
                if set.weight > maxWeight {
                    maxWeight = set.weight
                }
            }
        }
        
        let averageWeight = totalSets > 0 ? totalWeight / Double(totalSets) : 0
        let averageReps = totalSets > 0 ? Double(totalReps) / Double(totalSets) : 0
        
        return WorkoutAnalytics(
            totalVolume: totalVolume,
            averageWeight: averageWeight,
            maxWeight: maxWeight,
            totalSets: totalSets,
            totalReps: totalReps,
            averageReps: averageReps
        )
    }
}

extension WorkoutSessionViewModel {
    func getExercisePRs() -> [ExercisePR] {
        var prs: [UUID: ExercisePR] = [:]
        
        for session in workoutSessions.filter({ $0.isCompleted }) {
            for exerciseEntry in session.exerciseEntries {
                let exerciseId = exerciseEntry.exercise.id
                
                var maxWeight: Double = 0
                var maxReps: Int = 0
                var maxVolume: Double = 0
                var maxWeightDate = session.date
                
                for set in exerciseEntry.sets {
                    let volume = set.weight * Double(set.reps)
                    if set.weight > maxWeight {
                        maxWeight = set.weight
                        maxWeightDate = session.date
                    }
                    if set.reps > maxReps {
                        maxReps = set.reps
                    }
                    if volume > maxVolume {
                        maxVolume = volume
                    }
                }
                
                // Calculate estimated 1RM (simple Epley formula: weight * (1 + reps/30))
                let estimated1RM = maxWeight > 0 ? maxWeight * (1.0 + Double(maxReps) / 30.0) : nil
                
                if let existingPR = prs[exerciseId] {
                    // Update if this session has better PRs
                    if maxWeight > existingPR.maxWeight || maxReps > existingPR.maxReps || maxVolume > existingPR.maxVolume {
                        prs[exerciseId] = ExercisePR(
                            exercise: exerciseEntry.exercise,
                            maxWeight: max(maxWeight, existingPR.maxWeight),
                            maxReps: max(maxReps, existingPR.maxReps),
                            maxVolume: max(maxVolume, existingPR.maxVolume),
                            estimated1RM: estimated1RM,
                            date: maxWeightDate
                        )
                    }
                } else if maxWeight > 0 || maxReps > 0 {
                    prs[exerciseId] = ExercisePR(
                        exercise: exerciseEntry.exercise,
                        maxWeight: maxWeight,
                        maxReps: maxReps,
                        maxVolume: maxVolume,
                        estimated1RM: estimated1RM,
                        date: maxWeightDate
                    )
                }
            }
        }
        
        return Array(prs.values).sorted { $0.exercise.name < $1.exercise.name }
    }
    
    func getStatistics() -> WorkoutStatistics {
        let completedWorkouts = workoutSessions.filter { $0.isCompleted }
        let totalWorkouts = completedWorkouts.count
        
        var totalVolume: Double = 0
        var totalDuration: TimeInterval = 0
        var exerciseSet = Set<UUID>()
        
        for workout in completedWorkouts {
            totalVolume += workout.analytics.totalVolume
            totalDuration += workout.duration
            for exerciseEntry in workout.exerciseEntries {
                exerciseSet.insert(exerciseEntry.exercise.id)
            }
        }
        
        let averageWorkoutDuration = totalWorkouts > 0 ? totalDuration / Double(totalWorkouts) : 0
        
        let uniqueExercises = Array(exerciseSet.compactMap { exerciseId in
            completedWorkouts.flatMap { $0.exerciseEntries }
                .first { $0.exercise.id == exerciseId }?.exercise
        })
        
        return WorkoutStatistics(
            totalWorkouts: totalWorkouts,
            totalVolume: totalVolume,
            averageWorkoutDuration: averageWorkoutDuration,
            totalDuration: totalDuration,
            exercisesPerformed: uniqueExercises.count,
            uniqueExercises: uniqueExercises
        )
    }
    
    func getExerciseHistory(for exercise: Exercise) -> [WorkoutSession] {
        return workoutSessions.filter { session in
            session.isCompleted && session.exerciseEntries.contains { $0.exercise.id == exercise.id }
        }.sorted { $0.date > $1.date }
    }
}

