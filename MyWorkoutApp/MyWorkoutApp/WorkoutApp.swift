import SwiftUI

@main
struct WorkoutApp: App {
    @StateObject var workoutTemplateViewModel = WorkoutTemplateViewModel()
    @StateObject var exerciseLibraryViewModel = ExerciseLibraryViewModel()
    @StateObject var workoutSessionViewModel = WorkoutSessionViewModel()

    var body: some Scene {
        WindowGroup {
            TabView {
                WorkoutListView(
                    workoutTemplateViewModel: workoutTemplateViewModel,
                    exerciseLibraryViewModel: exerciseLibraryViewModel,
                    workoutSessionViewModel: workoutSessionViewModel
                )
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.fill")
                    Text("Workouts")
                }

                ProgressView(workoutSessionViewModel: workoutSessionViewModel)
                    .tabItem {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Progress")
                    }
            }
            .accentColor(.green) // Neon accent for selected tab
            .preferredColorScheme(.dark)
        }
    }
}
