import SwiftUI

struct CreateWorkoutView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutName: String = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var newExerciseName: String = ""

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        Text("Workout Details")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        TextField("Workout Name", text: $workoutName)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }

                    Group {
                        Text("Add New Exercise")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            TextField("Exercise Name", text: $newExerciseName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)

                            Button(action: {
                                if !newExerciseName.isEmpty {
                                    exerciseLibraryViewModel.addExercise(name: newExerciseName)
                                    newExerciseName = ""
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                    .shadow(color: .green.opacity(0.5), radius: 4)
                            }
                        }
                    }

                    Group {
                        Text("Select Exercises")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        List {
                            ForEach(exerciseLibraryViewModel.exercises) { exercise in
                                HStack {
                                    Text(exercise.name)
                                        .foregroundColor(.cyan)
                                    Spacer()
                                    if selectedExercises.contains(where: { $0.id == exercise.id }) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    toggleExerciseSelection(exercise: exercise)
                                }
                            }
                            .onDelete(perform: exerciseLibraryViewModel.removeExercise)
                        }
                        .frame(height: 250)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                    }

                    Group {
                        Text("Exercises in Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(selectedExercises) { exercise in
                            Text(exercise.name)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .onDelete(perform: removeExercise)
                    }

                    Button("Save Workout") {
                        saveWorkoutTemplate()
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(workoutName.isEmpty || selectedExercises.isEmpty ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.5), radius: 6)
                    .disabled(workoutName.isEmpty || selectedExercises.isEmpty)
                }
                .padding()
            }
        }
        .navigationTitle("Create Workout")
        .toolbar {
            EditButton().foregroundColor(.green)
        }
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
    }

    func toggleExerciseSelection(exercise: Exercise) {
        if let index = selectedExercises.firstIndex(where: { $0.id == exercise.id }) {
            selectedExercises.remove(at: index)
        } else {
            selectedExercises.append(exercise)
        }
    }

    func removeExercise(at offsets: IndexSet) {
        selectedExercises.remove(atOffsets: offsets)
    }

    func saveWorkoutTemplate() {
        let newTemplate = WorkoutTemplate(
            name: workoutName,
            exercises: selectedExercises
        )
        workoutTemplateViewModel.addWorkoutTemplate(newTemplate)
        presentationMode.wrappedValue.dismiss()
    }
}
