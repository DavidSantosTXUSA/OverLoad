import SwiftUI

struct WorkoutProgressView: View {
    @ObservedObject var workoutSessionViewModel: WorkoutSessionViewModel

    @State private var selectedWorkout: WorkoutSession?
    @State private var showDeleteConfirmation = false
    @State private var itemsToDelete: IndexSet?
    @State private var showStatistics = false
    @State private var showPRs = false
    @State private var searchText = ""
    @State private var sortOption: SortOption = .dateDescending
    @State private var filterOption: FilterOption = .all
    @State private var showExportSheet = false
    @State private var exportItems: [Any] = []
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case durationDescending = "Duration (Longest)"
        case durationAscending = "Duration (Shortest)"
        case volumeDescending = "Volume (Highest)"
        case volumeAscending = "Volume (Lowest)"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case lastMonth = "Last Month"
    }

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
                        // Search and Filter Section
                        Section {
                            VStack(spacing: 12) {
                                // Search Bar
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.gray)
                                    TextField("Search workouts...", text: $searchText)
                                        .foregroundColor(.white)
                                }
                                .padding(8)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                
                                // Sort and Filter Picker
                                HStack {
                                    Picker("Sort", selection: $sortOption) {
                                        ForEach(SortOption.allCases, id: \.self) { option in
                                            Text(option.rawValue).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .foregroundColor(.cyan)
                                    
                                    Spacer()
                                    
                                    Picker("Filter", selection: $filterOption) {
                                        ForEach(FilterOption.allCases, id: \.self) { option in
                                            Text(option.rawValue).tag(option)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .foregroundColor(.cyan)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Statistics Section
                        Section(header: Text("Statistics")
                            .foregroundColor(.cyan)
                            .font(.headline)) {
                            let stats = workoutSessionViewModel.getStatistics()
                            VStack(alignment: .leading, spacing: 8) {
                                StatRow(label: "Total Workouts", value: "\(stats.totalWorkouts)")
                                StatRow(label: "Total Volume", value: String(format: "%.0f lbs", stats.totalVolume))
                                StatRow(label: "Avg Duration", value: formatDuration(stats.averageWorkoutDuration))
                                StatRow(label: "Exercises Performed", value: "\(stats.exercisesPerformed)")
                            }
                            .padding(.vertical, 8)
                        }
                        
                        // Personal Records Section
                        if !workoutSessionViewModel.getExercisePRs().isEmpty {
                            Section(header: Text("Personal Records")
                                .foregroundColor(.cyan)
                                .font(.headline)) {
                                ForEach(workoutSessionViewModel.getExercisePRs().prefix(5), id: \.exercise.id) { pr in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(pr.exercise.name)
                                            .font(.headline)
                                            .foregroundColor(.green)
                                        HStack {
                                            Text("Max Weight: \(String(format: "%.1f", pr.maxWeight)) lbs")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                            Spacer()
                                            Text("Max Reps: \(pr.maxReps)")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        if let estimated1RM = pr.estimated1RM {
                                            Text("Est. 1RM: \(String(format: "%.1f", estimated1RM)) lbs")
                                                .font(.caption)
                                                .foregroundColor(.cyan)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                        
                        // Workout History Section
                        Section(header: Text("Workout History (\(sortedAndFilteredSessions.count))")
                            .foregroundColor(.cyan)
                            .font(.headline)) {
                            ForEach(sortedAndFilteredSessions.indices, id: \.self) { index in
                                let session = sortedAndFilteredSessions[index]

                                HStack {
                                    Spacer()

                                Button(action: {
                                    selectedWorkout = session
                                }) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(session.name)
                                                .font(.title3)
                                                .foregroundColor(.white)

                                            Text(formattedDate(session.date))
                                                .font(.caption)
                                                .foregroundColor(.gray)

                                            let analytics = session.analytics
                                            
                                            ForEach(session.exerciseEntries) { exerciseEntry in
                                                Text(exerciseEntry.exercise.name)
                                                    .font(.headline)
                                                    .foregroundColor(.cyan)

                                                ForEach(exerciseEntry.sets.indices, id: \.self) { i in
                                                    let set = exerciseEntry.sets[i]
                                                    Text("Set \(i + 1): \(set.reps) reps at \(set.weight, specifier: "%.1f") lbs")
                                                        .foregroundColor(.white)
                                                }
                                            }
                                            
                                            HStack {
                                                Text("Volume: \(String(format: "%.0f", analytics.totalVolume)) lbs")
                                                    .font(.caption)
                                                    .foregroundColor(.cyan)
                                                Spacer()
                                                Text("Duration: \(formatDuration(session.duration))")
                                                    .font(.caption)
                                                    .foregroundColor(.green)
                                            }
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
                            .onDelete(perform: confirmDelete)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            EditButton().foregroundColor(.green)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button(action: {
                                    exportToCSV()
                                }) {
                                    Label("Export to CSV", systemImage: "doc.text")
                                }
                                
                                Button(action: {
                                    exportToJSON()
                                }) {
                                    Label("Export to JSON", systemImage: "doc.text.fill")
                                }
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }

            }
            .navigationTitle("Progress")
        }
        .preferredColorScheme(.dark)
        .dismissKeyboardOnTap()
        .alert("Delete Workout", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                itemsToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let offsets = itemsToDelete {
                    deleteWorkout(at: offsets)
                }
                itemsToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this workout? This action cannot be undone.")
        }
        .sheet(isPresented: $showExportSheet) {
            ShareSheet(items: exportItems)
        }
        .sheet(item: $selectedWorkout) { workout in
            NavigationView {
                EditWorkoutView(
                    workoutSessionViewModel: workoutSessionViewModel,
                    workoutSession: workout
                )
            }
        }
    }
    
    func exportToCSV() {
        let csvString = DataExportService.exportToCSV(workoutSessions: workoutSessionViewModel.workoutSessions)
        let csvData = csvString.data(using: .utf8) ?? Data()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let filename = "workouts_\(dateFormatter.string(from: Date())).csv"
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        
        do {
            try csvData.write(to: tempURL)
            exportItems = [tempURL]
            showExportSheet = true
        } catch {
            // Handle error
        }
    }
    
    func exportToJSON() {
        // For JSON export, we'd need access to templates and exercises
        // For now, just export sessions
        let sessions = workoutSessionViewModel.workoutSessions
        
        let jsonData: [String: Any] = [
            "workoutSessions": sessions.map { session in
                [
                    "id": session.id.uuidString,
                    "name": session.name,
                    "date": ISO8601DateFormatter().string(from: session.date),
                    "duration": session.duration,
                    "isCompleted": session.isCompleted,
                    "exerciseEntries": session.exerciseEntries.map { entry in
                        [
                            "exercise": entry.exercise.name,
                            "sets": entry.sets.map { set in
                                [
                                    "reps": set.reps,
                                    "weight": set.weight
                                ]
                            }
                        ]
                    }
                ]
            },
            "exportDate": ISO8601DateFormatter().string(from: Date())
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let filename = "workouts_\(dateFormatter.string(from: Date())).json"
            
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: tempURL)
            exportItems = [tempURL]
            showExportSheet = true
        } catch {
            // Handle error
        }
    }

    private var filteredSessions: [WorkoutSession] {
        workoutSessionViewModel.workoutSessions.filter { $0.isCompleted }
    }
    
    private var sortedAndFilteredSessions: [WorkoutSession] {
        var sessions = filteredSessions
        
        // Apply search filter
        if !searchText.isEmpty {
            sessions = sessions.filter { session in
                session.name.localizedCaseInsensitiveContains(searchText) ||
                session.exerciseEntries.contains { $0.exercise.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        // Apply date filter
        let calendar = Calendar.current
        let now = Date()
        sessions = sessions.filter { session in
            switch filterOption {
            case .all:
                return true
            case .thisWeek:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(session.date, equalTo: now, toGranularity: .month)
            case .lastMonth:
                if let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) {
                    return calendar.isDate(session.date, equalTo: lastMonth, toGranularity: .month)
                }
                return false
            }
        }
        
        // Apply sorting
        switch sortOption {
        case .dateDescending:
            sessions.sort { $0.date > $1.date }
        case .dateAscending:
            sessions.sort { $0.date < $1.date }
        case .durationDescending:
            sessions.sort { $0.duration > $1.duration }
        case .durationAscending:
            sessions.sort { $0.duration < $1.duration }
        case .volumeDescending:
            sessions.sort { $0.analytics.totalVolume > $1.analytics.totalVolume }
        case .volumeAscending:
            sessions.sort { $0.analytics.totalVolume < $1.analytics.totalVolume }
        }
        
        return sessions
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    func confirmDelete(at offsets: IndexSet) {
        itemsToDelete = offsets
        showDeleteConfirmation = true
    }
    
    func deleteWorkout(at offsets: IndexSet) {
        let allSessions = workoutSessionViewModel.workoutSessions
        let sessionsToDelete = sortedAndFilteredSessions

        for offset in offsets {
            if let indexInAll = allSessions.firstIndex(where: { $0.id == sessionsToDelete[offset].id }) {
                workoutSessionViewModel.workoutSessions.remove(at: indexInAll)
            }
        }
        
        do {
            try workoutSessionViewModel.saveWorkoutSessions()
        } catch {
            workoutSessionViewModel.handleError(error)
        }
    }
}
