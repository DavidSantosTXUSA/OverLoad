import SwiftUI

struct ProgressView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel

    @State private var selectedWorkout: WorkoutSession?
    @State private var showEdit = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)

                if filteredSessions.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "bolt.circle")
                            .resizable()
                            .frame(width: 60, height: 60)
                            .foregroundColor(.gray)
                        Text("No completed workouts yet.")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(filteredSessions.indices, id: \.self) { index in
                            let session = filteredSessions[index]

                            HStack {
                                Spacer()

                                Button(action: {
                                    selectedWorkout = session
                                    showEdit = true
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(session.name)
                                            .font(.title3)
                                            .foregroundColor(.white)

                                        Text(formattedDate(session.date))
                                            .font(.caption)
                                            .foregroundColor(.gray)

                                        ForEach(session.exerciseEntries) { exerciseEntry in
                                            Text(exerciseEntry.exercise.name)
                                                .font(.headline)
                                                .foregroundColor(.cyan)

                                            ForEach(exerciseEntry.sets.indices, id: \.self) { i in
                                                let set = exerciseEntry.sets[i]
                                                Text("Set \(i + 1): \(set.reps) reps at \(set.weight, specifier: "%.2f") lbs")
                                                    .foregroundColor(.white)
                                            }
                                        }

                                        Text("Duration: \(Int(session.duration)) seconds")
                                            .italic()
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .frame(maxWidth: 350)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                    .shadow(color: .cyan.opacity(0.2), radius: 4)
                                }
                                .buttonStyle(PlainButtonStyle())

                                Spacer()
                            }
                            .padding(.vertical, 16)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteWorkout)
                    }
                    .listStyle(PlainListStyle())
                    .toolbar {
                        EditButton().foregroundColor(.green)
                    }
                }

                // Navigation to EditWorkoutView
                NavigationLink(
                    destination: selectedWorkout.map { workout in
                        EditWorkoutView(
                            workoutSessionViewModel: workoutSessionViewModel,
                            workoutSession: workout
                        )
                    },
                    isActive: $showEdit
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Progress")
        }
        .preferredColorScheme(.dark)
    }

    private var filteredSessions: [WorkoutSession] {
        workoutSessionViewModel.workoutSessions.filter { $0.isCompleted }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }

    func deleteWorkout(at offsets: IndexSet) {
        let allSessions = workoutSessionViewModel.workoutSessions
        let completedSessions = filteredSessions

        for offset in offsets {
            if let indexInAll = allSessions.firstIndex(where: { $0.id == completedSessions[offset].id }) {
                workoutSessionViewModel.workoutSessions.remove(at: indexInAll)
            }
        }

        workoutSessionViewModel.saveWorkoutSessions()
    }
}
