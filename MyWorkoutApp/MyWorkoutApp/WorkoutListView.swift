import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Charcoal background

                List {
                    ForEach(workoutTemplateViewModel.workoutTemplates) { template in
                        NavigationLink(destination: WorkoutDetailView(
                            workoutSessionViewModel: workoutSessionViewModel,
                            template: template)
                        ) {
                            HStack {
                                Image(systemName: "bolt.fill")
                                    .foregroundColor(.green)
                                Text(template.name)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(10)
                            .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 2)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteWorkoutTemplate)
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Workouts")
            .foregroundColor(.white)
            .navigationBarItems(
                leading: EditButton().foregroundColor(.green),
                trailing: NavigationLink(destination: CreateWorkoutView(
                    workoutTemplateViewModel: workoutTemplateViewModel,
                    exerciseLibraryViewModel: exerciseLibraryViewModel)
                ) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            )
        }
        .preferredColorScheme(.dark) // Force dark mode
    }

    func deleteWorkoutTemplate(at offsets: IndexSet) {
        workoutTemplateViewModel.workoutTemplates.remove(atOffsets: offsets)
        workoutTemplateViewModel.saveWorkoutTemplates()
    }
}
