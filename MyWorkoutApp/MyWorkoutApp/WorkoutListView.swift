import SwiftUI

struct WorkoutListView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @State private var showDeleteConfirmation = false
    @State private var itemsToDelete: IndexSet?
    @State private var selectedTemplateForEdit: WorkoutTemplate?
    @State private var showEditTemplate = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all) // Charcoal background

                List {
                    // Resume Active Workout Section
                    if let activeWorkout = workoutSessionViewModel.activeWorkout,
                       activeWorkout.isInProgress,
                       let template = workoutTemplateViewModel.workoutTemplates.first(where: { $0.id == activeWorkout.templateID }) {
                        Section(header: Text("Active Workout")
                            .foregroundColor(.cyan)
                            .font(.system(size: 16, weight: .bold, design: .rounded))) {
                            NavigationLink(destination: WorkoutDetailView(
                                workoutSessionViewModel: workoutSessionViewModel,
                                template: template)
                            ) {
                                HStack {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title2)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(activeWorkout.name)
                                            .foregroundColor(.white)
                                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                                        Text("Tap to resume")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(10)
                                .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 2)
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    
                    // Workout Templates Section
                    Section(header: Text("Workout Templates")
                        .foregroundColor(.cyan)
                        .font(.system(size: 16, weight: .bold, design: .rounded))) {
                        ForEach(workoutTemplateViewModel.workoutTemplates) { template in
                            HStack(spacing: 12) {
                                // Workout button - starts workout
                                Button(action: {
                                    // Navigate to workout detail
                                }) {
                                    NavigationLink(destination: WorkoutDetailView(
                                        workoutSessionViewModel: workoutSessionViewModel,
                                        template: template)
                                    ) {
                                        HStack {
                                            Image(systemName: "bolt.fill")
                                                .foregroundColor(.green)
                                            Text(template.name)
                                                .foregroundColor(.white)
                                                .font(.system(size: 19, weight: .heavy, design: .rounded))
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.gray.opacity(0.3))
                                        .cornerRadius(10)
                                        .shadow(color: .green.opacity(0.4), radius: 4, x: 0, y: 2)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Edit button - only for editing
                                Button(action: {
                                    selectedTemplateForEdit = template
                                    showEditTemplate = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.cyan)
                                        .font(.system(size: 18, weight: .semibold))
                                        .padding(12)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: confirmDelete)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Workouts")
            .font(.system(size: 36, weight: .heavy, design: .rounded))
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
        .alert("Delete Workout Template", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                itemsToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let offsets = itemsToDelete {
                    deleteWorkoutTemplate(at: offsets)
                }
                itemsToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this workout template? This action cannot be undone.")
        }
        .sheet(item: $selectedTemplateForEdit) { template in
            NavigationView {
                EditWorkoutTemplateView(
                    workoutTemplateViewModel: workoutTemplateViewModel,
                    exerciseLibraryViewModel: exerciseLibraryViewModel,
                    template: template
                )
            }
        }
    }

    func deleteWorkoutTemplate(at offsets: IndexSet) {
        workoutTemplateViewModel.workoutTemplates.remove(atOffsets: offsets)
        do {
            try workoutTemplateViewModel.saveWorkoutTemplates()
        } catch {
            workoutTemplateViewModel.handleError(error)
        }
    }
    
    func confirmDelete(at offsets: IndexSet) {
        itemsToDelete = offsets
        showDeleteConfirmation = true
    }
}
