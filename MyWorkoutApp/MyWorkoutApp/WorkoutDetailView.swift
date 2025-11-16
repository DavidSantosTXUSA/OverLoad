import SwiftUI

struct WorkoutDetailView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel
    var template: WorkoutTemplate
    @Environment(\.presentationMode) var presentationMode

    @State private var workoutSession: WorkoutSession
    @State private var timer: Timer?
    @State private var timerRunning = false
    @State private var timeElapsed: TimeInterval = 0
    @State private var autoSaveTimer: Timer?
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @StateObject private var restTimer = RestTimer()
    @State private var restTimerDuration: TimeInterval = 90 // Default 90 seconds
    @State private var showRestTimerSettings = false
    @State private var weightTextFields: [String: String] = [:] // Store text field values while typing
    @State private var repsTextFields: [String: String] = [:] // Store text field values while typing
    @State private var autoSaveWork: DispatchWorkItem?

    init(workoutSessionViewModel: WorkoutSessionViewModel, template: WorkoutTemplate) {
        self.workoutSessionViewModel = workoutSessionViewModel
        self.template = template
        
        // Check if there's an active workout for this template
        if let activeWorkout = workoutSessionViewModel.activeWorkout,
           activeWorkout.templateID == template.id && activeWorkout.isInProgress {
            // Resume existing workout
            self._workoutSession = State(initialValue: activeWorkout)
        } else {
            // Create new workout
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
                                        
                                        if workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps > 0 && workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight > 0 {
                                            Button(action: {
                                                restTimer.start(duration: restTimerDuration)
                                            }) {
                                                Text("Complete")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.green.opacity(0.2))
                                                    .cornerRadius(6)
                                            }
                                        }
                                        
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
                                            .frame(width: 60, alignment: .leading)
                                        
                                        Button(action: {
                                            let key = "\(exerciseIndex)-\(setIndex)-reps"
                                            repsTextFields.removeValue(forKey: key)
                                            let currentReps = workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = InputValidators.clampReps(max(0, currentReps - 1))
                                            debouncedAutoSave()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title3)
                                        }
                                        
                                        TextField("Enter reps", text: Binding(
                                            get: {
                                                let key = "\(exerciseIndex)-\(setIndex)-reps"
                                                if let text = repsTextFields[key], !text.isEmpty {
                                                    return text
                                                }
                                                return workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps == 0 ? "" : String(workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps)
                                            },
                                            set: { newValue in
                                                let key = "\(exerciseIndex)-\(setIndex)-reps"
                                                repsTextFields[key] = newValue
                                                // Only update the actual value when user finishes typing
                                                if let reps = Int(newValue), reps >= 0 {
                                                    workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = InputValidators.clampReps(reps)
                                                    debouncedAutoSave()
                                                } else if newValue.isEmpty {
                                                    workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = 0
                                                }
                                            }
                                        ))
                                        .onSubmit {
                                            let key = "\(exerciseIndex)-\(setIndex)-reps"
                                            repsTextFields.removeValue(forKey: key)
                                        }
                                        .keyboardType(.numberPad)
                                        .foregroundColor(.white)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 60)
                                        
                                        Button(action: {
                                            let key = "\(exerciseIndex)-\(setIndex)-reps"
                                            repsTextFields.removeValue(forKey: key)
                                            let currentReps = workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].reps = InputValidators.clampReps(currentReps + 1)
                                            debouncedAutoSave()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title3)
                                        }
                                        
                                        Spacer()
                                    }

                                    HStack {
                                        Text("Weight:")
                                            .foregroundColor(.gray)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        Button(action: {
                                            let key = "\(exerciseIndex)-\(setIndex)-weight"
                                            weightTextFields.removeValue(forKey: key)
                                            let currentWeight = workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = InputValidators.clampWeight(max(0, currentWeight - 2.5))
                                            debouncedAutoSave()
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.title3)
                                        }
                                        
                                        TextField("Enter weight", text: Binding(
                                            get: {
                                                let key = "\(exerciseIndex)-\(setIndex)-weight"
                                                if let text = weightTextFields[key], !text.isEmpty {
                                                    return text
                                                }
                                                let weight = workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight
                                                return weight == 0 ? "" : String(format: "%.1f", weight)
                                            },
                                            set: { newValue in
                                                let key = "\(exerciseIndex)-\(setIndex)-weight"
                                                // Allow typing, including partial decimals like "1." or "1.0"
                                                weightTextFields[key] = newValue
                                                
                                                // Only update the actual value when it's a valid number
                                                if let weight = Double(newValue), weight >= 0 {
                                                    workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = InputValidators.clampWeight(weight)
                                                    debouncedAutoSave()
                                                } else if newValue.isEmpty {
                                                    workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = 0
                                                }
                                            }
                                        ))
                                        .onSubmit {
                                            let key = "\(exerciseIndex)-\(setIndex)-weight"
                                            weightTextFields.removeValue(forKey: key)
                                        }
                                        .keyboardType(.decimalPad)
                                        .foregroundColor(.white)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(width: 80)
                                        
                                        Button(action: {
                                            let key = "\(exerciseIndex)-\(setIndex)-weight"
                                            weightTextFields.removeValue(forKey: key)
                                            let currentWeight = workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight
                                            workoutSession.exerciseEntries[exerciseIndex].sets[setIndex].weight = InputValidators.clampWeight(currentWeight + 2.5)
                                            debouncedAutoSave()
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.title3)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }

                            HStack(spacing: 12) {
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
                                
                                if !workoutSession.exerciseEntries[exerciseIndex].sets.isEmpty {
                                    Button(action: {
                                        copyPreviousSet(to: exerciseIndex)
                                    }) {
                                        Text("Copy Last")
                                            .foregroundColor(.cyan)
                                            .padding(.vertical, 6)
                                            .frame(maxWidth: .infinity)
                                            .background(Color.cyan.opacity(0.2))
                                            .cornerRadius(10)
                                            .shadow(color: .cyan.opacity(0.3), radius: 4)
                                    }
                                }
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

                VStack(spacing: 12) {
                    Text("Time Elapsed: \(formatTime(timeElapsed))")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    // Rest Timer
                    if restTimer.timeRemaining > 0 || restTimer.isRunning {
                        VStack(spacing: 8) {
                            Text("Rest Timer")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text(restTimer.formatTime(restTimer.timeRemaining))
                                .font(.title)
                                .foregroundColor(restTimer.timeRemaining <= 10 ? .red : .green)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                if restTimer.isRunning {
                                    Button("Pause") {
                                        restTimer.pause()
                                    }
                                    .foregroundColor(.orange)
                                } else if restTimer.timeRemaining > 0 {
                                    Button("Resume") {
                                        restTimer.resume()
                                    }
                                    .foregroundColor(.green)
                                }
                                
                                Button("Stop") {
                                    restTimer.stop()
                                }
                                .foregroundColor(.red)
                            }
                            .font(.caption)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                    } else {
                        HStack {
                            Button("Start Rest Timer") {
                                restTimer.start(duration: restTimerDuration)
                            }
                            .foregroundColor(.cyan)
                            .font(.caption)
                            
                            Button(action: {
                                showRestTimerSettings = true
                            }) {
                                Image(systemName: "gear")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding()

                Button(action: {
                    toggleTimer()
                }) {
                    Text(timerRunning ? "Stop Timer" : "Start Timer")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(timerRunning ? Color.red.opacity(0.7) : Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: (timerRunning ? Color.red : Color.blue).opacity(0.5), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal)

                if timerRunning || timeElapsed > 0 || workoutSession.isInProgress {
                    Button(action: {
                        finishWorkout()
                    }) {
                        Text("Finish Workout")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(color: Color.green.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
        }
        .navigationTitle(workoutSession.name)
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
        .onAppear {
            restoreTimerState()
            startAutoSave()
        }
        .onDisappear {
            saveTimerState()
            stopAutoSave()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            saveTimerState()
            autoSaveWorkout()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            restoreTimerState()
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .sheet(isPresented: $showRestTimerSettings) {
            RestTimerSettingsView(restTimerDuration: $restTimerDuration)
        }
    }
    
    // Format time as MM:SS or HH:MM:SS
    func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func restoreTimerState() {
        // If workout was in progress, restore timer state
        if workoutSession.isInProgress, let startTime = workoutSession.timerStartTime {
            let elapsed = Date().timeIntervalSince(startTime)
            timeElapsed = workoutSession.duration + elapsed
            if timerRunning {
                startTimer()
            }
        }
    }
    
    func saveTimerState() {
        if timerRunning {
            // Save current timer state
            workoutSession.timerStartTime = Date().addingTimeInterval(-timeElapsed + workoutSession.duration)
        } else {
            // Timer is stopped, just save accumulated duration
            workoutSession.duration = timeElapsed
            workoutSession.timerStartTime = nil
        }
        workoutSession.lastSavedTime = Date()
        autoSaveWorkout()
    }

    func toggleTimer() {
        timerRunning.toggle()
        if timerRunning {
            startTimer()
            workoutSession.isInProgress = true
            workoutSession.timerStartTime = Date().addingTimeInterval(-workoutSession.duration)
        } else {
            stopTimer()
        }
        autoSaveWorkout()
    }

    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if let startTime = workoutSession.timerStartTime {
                timeElapsed = workoutSession.duration + Date().timeIntervalSince(startTime)
            } else {
                timeElapsed += 1
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        workoutSession.duration = timeElapsed
        workoutSession.timerStartTime = nil
        autoSaveWorkout()
    }
    
    func startAutoSave() {
        // Auto-save every 30 seconds
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            autoSaveWorkout()
        }
        RunLoop.main.add(autoSaveTimer!, forMode: .common)
    }
    
    func stopAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    func debouncedAutoSave() {
        // Cancel previous auto-save work
        autoSaveWork?.cancel()
        
        // Create new work item
        // Note: WorkoutDetailView is a struct, so we don't need [weak self]
        // Structs are value types and don't create retain cycles
        let work = DispatchWorkItem { [self] in
            self.autoSaveWorkout()
        }
        autoSaveWork = work
        
        // Dispatch after 0.5 seconds of no typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: work)
    }
    
    func autoSaveWorkout() {
        // Update duration if timer is running
        if timerRunning, let startTime = workoutSession.timerStartTime {
            workoutSession.duration = Date().timeIntervalSince(startTime)
        } else {
            workoutSession.duration = timeElapsed
        }
        
        workoutSession.isInProgress = timerRunning || timeElapsed > 0
        workoutSession.lastSavedTime = Date()
        do {
            try workoutSessionViewModel.saveActiveWorkout(workoutSession)
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func finishWorkout() {
        stopTimer()
        workoutSession.duration = timeElapsed
        workoutSession.isCompleted = true
        workoutSession.isInProgress = false
        workoutSession.timerStartTime = nil
        do {
            try workoutSessionViewModel.addWorkoutSession(workoutSession)
            workoutSessionViewModel.clearActiveWorkout()
            presentationMode.wrappedValue.dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func addSet(to exerciseIndex: Int) {
        workoutSession.exerciseEntries[exerciseIndex].sets.append(SetEntry(reps: 0, weight: 0.0))
        debouncedAutoSave()
    }

    func deleteSet(at setIndex: Int, from exerciseIndex: Int) {
        // Clear text field caches for this set
        let repsKey = "\(exerciseIndex)-\(setIndex)-reps"
        let weightKey = "\(exerciseIndex)-\(setIndex)-weight"
        repsTextFields.removeValue(forKey: repsKey)
        weightTextFields.removeValue(forKey: weightKey)
        
        workoutSession.exerciseEntries[exerciseIndex].sets.remove(at: setIndex)
        
        // Update keys for remaining sets
        let remainingSets = workoutSession.exerciseEntries[exerciseIndex].sets
        var newRepsFields: [String: String] = [:]
        var newWeightFields: [String: String] = [:]
        
        for (oldIndex, _) in remainingSets.enumerated() {
            let oldRepsKey = "\(exerciseIndex)-\(oldIndex + 1)-reps"
            let oldWeightKey = "\(exerciseIndex)-\(oldIndex + 1)-weight"
            let newRepsKey = "\(exerciseIndex)-\(oldIndex)-reps"
            let newWeightKey = "\(exerciseIndex)-\(oldIndex)-weight"
            
            if let repsValue = repsTextFields[oldRepsKey] {
                newRepsFields[newRepsKey] = repsValue
            }
            if let weightValue = weightTextFields[oldWeightKey] {
                newWeightFields[newWeightKey] = weightValue
            }
        }
        
        repsTextFields = newRepsFields
        weightTextFields = newWeightFields
        
        debouncedAutoSave()
    }
    
    func copyPreviousSet(to exerciseIndex: Int) {
        let sets = workoutSession.exerciseEntries[exerciseIndex].sets
        guard let lastSet = sets.last else { return }
        let newSet = SetEntry(reps: lastSet.reps, weight: lastSet.weight)
        workoutSession.exerciseEntries[exerciseIndex].sets.append(newSet)
        debouncedAutoSave()
    }
}
