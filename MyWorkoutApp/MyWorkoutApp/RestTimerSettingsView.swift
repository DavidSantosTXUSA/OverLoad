import SwiftUI

struct RestTimerSettingsView: View {
    @Binding var restTimerDuration: TimeInterval
    @Environment(\.presentationMode) var presentationMode
    
    @State private var minutes: Int = 1
    @State private var seconds: Int = 30
    
    let presetDurations: [TimeInterval] = [30, 60, 90, 120, 180]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    Text("Rest Timer Duration")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    // Preset buttons
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Presets")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        HStack(spacing: 12) {
                            ForEach(presetDurations, id: \.self) { duration in
                                Button(action: {
                                    restTimerDuration = duration
                                    updateMinutesSeconds()
                                }) {
                                    Text(formatPreset(duration))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(restTimerDuration == duration ? Color.green : Color.gray.opacity(0.3))
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    // Custom duration
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom Duration")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("Minutes")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Picker("Minutes", selection: $minutes) {
                                    ForEach(0..<10) { minute in
                                        Text("\(minute)").tag(minute)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 100)
                                .onChange(of: minutes) { _ in
                                    updateDuration()
                                }
                            }
                            
                            VStack {
                                Text("Seconds")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                Picker("Seconds", selection: $seconds) {
                                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { second in
                                        Text("\(second)").tag(second)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 80, height: 100)
                                .onChange(of: seconds) { _ in
                                    updateDuration()
                                }
                            }
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .navigationTitle("Rest Timer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                updateMinutesSeconds()
            }
        }
    }
    
    func formatPreset(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        if seconds == 0 {
            return "\(minutes)m"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
    
    func updateDuration() {
        restTimerDuration = TimeInterval(minutes * 60 + seconds)
    }
    
    func updateMinutesSeconds() {
        minutes = Int(restTimerDuration) / 60
        seconds = Int(restTimerDuration) % 60
    }
}

