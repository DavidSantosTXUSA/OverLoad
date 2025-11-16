//
//  EditWorkoutView.swift
//  MyWorkoutApp
//
//  Created by David Santos on 3/21/25.
//


import SwiftUI

struct EditWorkoutView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    @State var workoutSession: WorkoutSession
    @Environment(\.presentationMode) var presentationMode
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

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
                                                String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps)
                                            },
                                            set: { newValue in
                                                let reps = Int(newValue) ?? 0
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = InputValidators.clampReps(reps)
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
                                                String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight)
                                            },
                                            set: { newValue in
                                                let weight = Double(newValue) ?? 0.0
                                                workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = InputValidators.clampWeight(weight)
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
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color: .cyan.opacity(0.3), radius: 5)
                        .padding(.horizontal)
                        .padding(.bottom, 12)
                    }
                }

                Button("Save Changes") {
                    saveEdits()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.5), radius: 6)
                .padding()
                .dismissKeyboardOnTap()
            }
        }
        .navigationTitle("Edit \(workoutSession.name)")
        .preferredColorScheme(.dark)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    func addSet(to exerciseIndex: Int) {
        workoutSession.exerciseEntries[exerciseIndex].sets.append(SetEntry(reps: 0, weight: 0.0))
    }

    func deleteSet(at setIndex: Int, from exerciseIndex: Int) {
        workoutSession.exerciseEntries[exerciseIndex].sets.remove(at: setIndex)
    }

    func saveEdits() {
        if let index = workoutSessionViewModel.workoutSessions.firstIndex(where: { $0.id == workoutSession.id }) {
            workoutSessionViewModel.workoutSessions[index] = workoutSession
            do {
                try workoutSessionViewModel.saveWorkoutSessions()
                presentationMode.wrappedValue.dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
}
