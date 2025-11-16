import SwiftUI

struct EditWorkoutTemplateView: View {
    @ObservedObject var workoutTemplateViewModel: WorkoutTemplateViewModel
    @ObservedObject var exerciseLibraryViewModel: ExerciseLibraryViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State var template: WorkoutTemplate
    @State private var workoutName: String
    @State private var selectedExercises: [Exercise]
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDeleteExerciseConfirmation = false
    @State private var exerciseToDelete: IndexSet?
    
    init(workoutTemplateViewModel: WorkoutTemplateViewModel, exerciseLibraryViewModel: ExerciseLibraryViewModel, template: WorkoutTemplate) {
        self.workoutTemplateViewModel = workoutTemplateViewModel
        self.exerciseLibraryViewModel = exerciseLibraryViewModel
        self._template = State(initialValue: template)
        self._workoutName = State(initialValue: template.name)
        self._selectedExercises = State(initialValue: template.exercises)
    }
    
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
                            .onDelete { offsets in
                                exerciseToDelete = offsets
                                showDeleteExerciseConfirmation = true
                            }
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
                    
                    Button("Save Changes") {
                        saveTemplate()
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
        .navigationTitle("Edit Workout")
        .toolbar {
            EditButton().foregroundColor(.green)
        }
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
    
    func saveTemplate() {
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
        
        // Update the template
        template.name = trimmedName
        template.exercises = selectedExercises
        
        // Update in ViewModel
        if let index = workoutTemplateViewModel.workoutTemplates.firstIndex(where: { $0.id == template.id }) {
            workoutTemplateViewModel.workoutTemplates[index] = template
            do {
                try workoutTemplateViewModel.saveWorkoutTemplates()
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}

