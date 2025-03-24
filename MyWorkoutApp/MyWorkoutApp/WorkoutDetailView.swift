import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    var template: WorkoutTemplate
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutSession: WorkoutSession
    @State private var timer: Timer?
    @State private var timerRunning = false
    @State private var timeElapsed: TimeInterval = 0

    init(workoutSessionViewModel: WorkoutSessionViewModel, template: WorkoutTemplate) {
        self.workoutSessionViewModel = workoutSessionViewModel
        self.template = template
        let exerciseEntries = template.exercises.map { exercise in
            ExerciseEntry(exercise: exercise, sets: [])
        }
        self._workoutSession = State(initialValue: WorkoutSession(
            templateID: template.id,
            name: template.name,
            date: Date(),
            exerciseEntries: exerciseEntries,
            duration: 0
        ))
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack {
                ScrollView {
                    ForEach(workoutSession.exerciseEntries.indices, id: \.self) { exerciseIndex in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(workoutSession.exerciseEntries[exerciseIndex].exercise.name)
                                .font(.headline)
                                .foregroundColor(.cyan)

                            ForEach(workoutSession.exerciseEntries[exerciseIndex].sets.indices, id: \.self) { setIndex in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("Set \(setIndex + 1)")
                                            .foregroundColor(.white)
                                        Spacer()
                                        Button(action: {
                                            deleteSet(at: setIndex, from: exerciseIndex)
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }

                                    HStack {
                                        Text("Reps:")
                                            .foregroundColor(.gray)
                                        TextField("Enter reps", text: Binding(
                                            get: {
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps == 0 ? "" : String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps)
                                            },
                                            set: { newValue in
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = Int(newValue) ?? 0
                                            }
                                        ))
                                        .keyboardType(.numberPad)
                                        .foregroundColor(.white)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }

                                    HStack {
                                        Text("Weight:")
                                            .foregroundColor(.gray)
                                        TextField("Enter weight", text: Binding(
                                            get: {
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight == 0 ? "" : String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight)
                                            },
                                            set: { newValue in
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = Double(newValue) ?? 0
                                            }
                                        ))
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(.white)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    }
                                }
                            }

                            Button(action: {
                                addSet(to: exerciseIndex)
                            }) {
                                Text("Add Set")
                                    .foregroundColor(.green)
                                    .padding(.vertical, 6)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(10)
                                    .shadow(color: .green.opacity(0.3), radius: 4)
                            }
                            .disabled(!timerRunning)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color: .cyan.opacity(0.3), radius: 5)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }

                Text("Time Elapsed: \(Int(timeElapsed))s")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()

                Button(action: {
                    toggleTimer()
                }) {
                    Text(timerRunning ? "Stop Workout" : "Start Workout")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(timerRunning ? Color.red.opacity(0.7) : Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: (timerRunning ? Color.red : Color.blue).opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .navigationTitle(workoutSession.name)
        .onDisappear {
            if timerRunning {
                stopTimer()
            }
            saveWorkout()
        }
        .preferredColorScheme(.dark)
    }

    // Timer & Save Logic
    func toggleTimer() {
        timerRunning.toggle()
        if timerRunning { startTimer() } else { stopTimer() }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            timeElapsed += 1
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        workoutSession.duration += timeElapsed
        workoutSession.isCompleted = true
        timeElapsed = 0
    }

    func saveWorkout() {
        workoutSession.duration += timeElapsed
        workoutSessionViewModel.addWorkoutSession(workoutSession)
        workoutSession.isCompleted = true
        presentationMode.wrappedValue.dismiss()
    }

    func addSet(to exerciseIndex: Int) {
        workoutSession.exerciseEntries[exerciseIndex].sets.append(SetEntry(reps: 0, weight: 0.0))
    }

    func deleteSet(at setIndex: Int, from exerciseIndex: Int) {
        workoutSession.exerciseEntries[exerciseIndex].sets.remove(at: setIndex)
    }
}
