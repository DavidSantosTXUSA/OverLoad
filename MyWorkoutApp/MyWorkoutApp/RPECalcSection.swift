import SwiftUI

struct RPECalcSection: View {
    @ObservedObject var viewModel: CalcViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header: Unit Toggle
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                
                // Input Fields
                inputFields
                    .padding(.horizontal, 20)
                
                // Calculate Button
                calculateButton
                    .padding(.horizontal, 20)
                
                // Result Card
                if let result = viewModel.estimated1RM {
                    resultCard(result: result)
                        .padding(.horizontal, 20)
                    
                    // Clear Button
                    clearButton
                        .padding(.horizontal, 20)
                } else {
                    // Empty state
                    emptyState
                        .padding(.horizontal, 20)
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color.black)
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            Spacer()
            
            // Unit Toggle Button
            Button(action: {
                viewModel.isKgMode.toggle()
                // Recalculate if inputs are valid
                if viewModel.isRPEValid {
                    viewModel.calculate1RM()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                    Text(viewModel.isKgMode ? "KG" : "LB")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1.5)
                        )
                )
            }
        }
    }
    
    // MARK: - Input Fields
    
    private var inputFields: some View {
        VStack(spacing: 20) {
            // Weight Input
            inputField(
                label: "Weight",
                icon: "scalemass.fill",
                text: $viewModel.rpeWeight,
                placeholder: viewModel.isKgMode ? "100" : "225",
                keyboardType: .decimalPad,
                isValid: {
                    guard let weight = Double(viewModel.rpeWeight) else { return false }
                    return weight > 0
                }()
            )
            
            // Reps Input
            inputField(
                label: "Reps",
                icon: "number.circle.fill",
                text: $viewModel.rpeReps,
                placeholder: "5",
                keyboardType: .numberPad,
                isValid: {
                    guard let reps = Int(viewModel.rpeReps) else { return false }
                    return reps >= 1 && reps <= 10
                }()
            )
            
            // RPE Input
            inputField(
                label: "RPE",
                icon: "gauge.high",
                text: $viewModel.rpeValue,
                placeholder: "9.5",
                keyboardType: .decimalPad,
                isValid: {
                    guard let rpe = Double(viewModel.rpeValue) else { return false }
                    return rpe >= 7.5 && rpe <= 10.0
                }(),
                helperText: "7.5 - 10.0"
            )
        }
    }
    
    private func inputField(
        label: String,
        icon: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType,
        isValid: Bool,
        helperText: String? = nil
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.cyan)
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if !text.wrappedValue.isEmpty {
                    Image(systemName: isValid ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(isValid ? .green : .red)
                }
            }
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    isValid && !text.wrappedValue.isEmpty ?
                                    Color.green.opacity(0.5) :
                                    Color.gray.opacity(0.3),
                                    lineWidth: isValid && !text.wrappedValue.isEmpty ? 2 : 1
                                )
                        )
                )
            
            if let helper = helperText {
                Text(helper)
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundColor(.gray.opacity(0.7))
                    .padding(.leading, 4)
            }
        }
    }
    
    // MARK: - Calculate Button
    
    private var calculateButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            viewModel.calculate1RM()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "function")
                    .font(.system(size: 20, weight: .semibold))
                Text("Calculate 1RM")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        viewModel.isRPEValid ?
                        LinearGradient(
                            colors: [Color.green.opacity(0.8), Color.green.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: viewModel.isRPEValid ? Color.green.opacity(0.4) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .disabled(!viewModel.isRPEValid)
    }
    
    // MARK: - Result Card
    
    private func resultCard(result: Double) -> some View {
        VStack(spacing: 16) {
            Text("Estimated 1RM")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
            
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formatWeight(result))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
                
                Text(viewModel.isKgMode ? "kg" : "lbs")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.cyan.opacity(0.8))
            }
            
            // Converted value
            let converted = viewModel.isKgMode ? result * 2.20462 : result / 2.20462
            Text("\(formatWeight(converted)) \(viewModel.isKgMode ? "lbs" : "kg")")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.cyan.opacity(0.15), Color.cyan.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.cyan.opacity(0.4), lineWidth: 2)
                )
        )
    }
    
    // MARK: - Clear Button
    
    private var clearButton: some View {
        Button(action: {
            withAnimation {
                viewModel.clearRPE()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise")
                Text("Clear")
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.gray)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "function")
                .font(.system(size: 56, weight: .light))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("Enter values above to calculate 1RM")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.gray.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Helpers
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}
