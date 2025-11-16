import SwiftUI

struct CreateWorkoutView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutName: String = ""
    @State private var selectedExercises: [Exercise] = []
    @State private var newExerciseName: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDeleteExerciseConfirmation = false
    @State private var exerciseToDelete: IndexSet?

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(spacing: 20) {
                    Group {
                        Text("Workout Details")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
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
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        HStack {
                            TextField("Exercise Name", text: $newExerciseName)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)

                            Button(action: {
                                let trimmedName = newExerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                                if !trimmedName.isEmpty {
                                    // Check for duplicates
                                    if exerciseLibraryViewModel.exercises.contains(where: { $0.name.lowercased() == trimmedName.lowercased() }) {
                                        errorMessage = "An exercise with this name already exists."
                                        showErrorAlert = true
                                        return
                                    }
                                    
                                    do {
                                        try exerciseLibraryViewModel.addExercise(name: trimmedName)
                                        newExerciseName = ""
                                    } catch {
                                        errorMessage = error.localizedDescription
                                        showErrorAlert = true
                                    }
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
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(exerciseLibraryViewModel.exercises) { exercise in
                                    Button(action: {
                                        toggleExerciseSelection(exercise: exercise)
                                    }) {
                                        HStack {
                                            Text(exercise.name)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundColor(.cyan)
                                            Spacer()
                                            if selectedExercises.contains(where: { $0.id == exercise.id }) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                                    .font(.system(size: 20))
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.horizontal, 16)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .frame(height: 250)
                        .background(Color.clear)
                    }

                    Group {
                        Text("Exercises in Workout")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        ForEach(selectedExercises) { exercise in
                            Text(exercise.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
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
                    .font(.system(size: 18, weight: .bold, design: .rounded))
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
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Delete Exercise", isPresented: $showDeleteExerciseConfirmation) {
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let offsets = exerciseToDelete {
                    do {
                        try exerciseLibraryViewModel.removeExercise(at: offsets)
                    } catch {
                        errorMessage = error.localizedDescription
                        showErrorAlert = true
                    }
                }
                exerciseToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this exercise? This will remove it from your exercise library.")
        }
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
        let trimmedName = workoutName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Workout name cannot be empty."
            showErrorAlert = true
            return
        }
        
        guard !selectedExercises.isEmpty else {
            errorMessage = "Please select at least one exercise."
            showErrorAlert = true
            return
        }
        
        let newTemplate = WorkoutTemplate(
            name: trimmedName,
            exercises: selectedExercises
        )
        
        do {
            try workoutTemplateViewModel.addWorkoutTemplate(newTemplate)
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}
