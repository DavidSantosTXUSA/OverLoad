import SwiftUI

struct RPECalcSection: View {
    @ObservedObject var viewModel: CalcViewModel
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Unit Toggle Header - very compact
                HStack {
                    Spacer()
                    unitToggleButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 2)
                .padding(.bottom, 6)
                
                // Last Set Card
                lastSetCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                
                // Next Set Card
                nextSetCard
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)
                
                // Info Text (very compact)
                infoText
                    .padding(.horizontal, 20)
                    .padding(.bottom, 4)
                
                Spacer(minLength: 0)
            }
        }
        .background(Color.black)
    }
    
    // MARK: - Unit Toggle
    
    private var unitToggleButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            viewModel.isKgMode.toggle()
            // Recalculate if we have valid inputs
            if viewModel.isRPEValid {
                viewModel.calculate1RM()
            }
        }) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 12, weight: .semibold))
                Text(viewModel.isKgMode ? "KG" : "LB")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
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
    
    // MARK: - Last Set Card
    
    private var lastSetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text("Last Set")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Weight and Reps side by side
            HStack(spacing: 10) {
                rpeInputField(
                    label: "Weight",
                    text: $viewModel.lastSetWeight,
                    placeholder: viewModel.isKgMode ? "100" : "225",
                    keyboardType: .decimalPad,
                    range: nil
                )
                
                rpeInputField(
                    label: "Reps",
                    text: $viewModel.lastSetReps,
                    placeholder: "5",
                    keyboardType: .numberPad,
                    range: "1-15"
                )
            }
            
            // RPE Input (full width)
            rpeInputField(
                label: "RPE",
                text: $viewModel.lastSetRPE,
                placeholder: "9.5",
                keyboardType: .decimalPad,
                range: "1-10"
            )
            
            // e1RM Output - compact
            HStack {
                Text("e1RM*")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let e1RM = viewModel.estimated1RM {
                    HStack(spacing: 4) {
                        Text(formatWeight(e1RM))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                        Text(viewModel.isKgMode ? "KG" : "LB")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.green.opacity(0.8))
                    }
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.top, 2)
            
            // Note - very small
            Text("*e1RM = estimated 1 rep max")
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
        )
        .onChange(of: viewModel.lastSetWeight) {
            viewModel.calculate1RM()
        }
        .onChange(of: viewModel.lastSetReps) {
            viewModel.calculate1RM()
        }
        .onChange(of: viewModel.lastSetRPE) {
            viewModel.calculate1RM()
        }
    }
    
    // MARK: - Next Set Card
    
    private var nextSetCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Title
            Text("Next Set")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            // Reps and RPE side by side
            HStack(spacing: 10) {
                rpeInputField(
                    label: "Reps",
                    text: $viewModel.nextSetReps,
                    placeholder: "5",
                    keyboardType: .numberPad,
                    range: "1-15"
                )
                
                rpeInputField(
                    label: "RPE",
                    text: $viewModel.nextSetRPE,
                    placeholder: "9.5",
                    keyboardType: .decimalPad,
                    range: "1-10"
                )
            }
            
            // Weight Output - compact
            HStack {
                Text("Weight")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let weight = viewModel.nextSetWeight {
                    HStack(spacing: 4) {
                        Text(formatWeight(weight))
                            .font(.system(size: 20, weight: .heavy, design: .rounded))
                            .foregroundColor(.green)
                        Text(viewModel.isKgMode ? "KG" : "LB")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(.green.opacity(0.8))
                    }
                } else {
                    Text("-")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.15))
        )
        .onChange(of: viewModel.nextSetReps) {
            viewModel.calculateNextSetWeight()
        }
        .onChange(of: viewModel.nextSetRPE) {
            viewModel.calculateNextSetWeight()
        }
        .onChange(of: viewModel.estimated1RM) {
            viewModel.calculateNextSetWeight()
        }
    }
    
    // MARK: - RPE Input Field
    
    private func rpeInputField(
        label: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType,
        range: String?
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let range = range {
                    Text(range)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    !text.wrappedValue.isEmpty ?
                                    Color.green.opacity(0.6) :
                                    Color.gray.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                )
        }
    }
    
    // MARK: - Info Text
    
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("RPE & RIR are two forms of autoregulation training tools")
                .font(.system(size: 9, weight: .regular, design: .rounded))
                .foregroundColor(.gray.opacity(0.6))
            
            HStack(spacing: 3) {
                Text("Rate of Perceived Exertion")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundColor(.gray.opacity(0.6))
                Text("(RPE)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
            
            HStack(spacing: 3) {
                Text("Reps In Reserve")
                    .font(.system(size: 9, weight: .regular, design: .rounded))
                    .foregroundColor(.gray.opacity(0.6))
                Text("(RIR)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
            }
        }
    }
    
    // MARK: - Helpers
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.2f", weight)
        }
    }
}
