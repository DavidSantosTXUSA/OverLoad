import SwiftUI

struct RPECalcSection: View {
    @ObservedObject var viewModel: CalcViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Unit Toggle Header
                HStack {
                    Spacer()
                    unitToggleButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // Last Set Card
                lastSetCard
                    .padding(.horizontal, 20)
                
                // Next Set Card
                nextSetCard
                    .padding(.horizontal, 20)
                
                // Info Text
                infoText
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
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
    
    // MARK: - Last Set Card
    
    private var lastSetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Last Set")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            // Weight Input
            rpeInputField(
                label: "Weight",
                text: $viewModel.lastSetWeight,
                placeholder: viewModel.isKgMode ? "100" : "225",
                keyboardType: .decimalPad,
                range: nil
            )
            
            // Reps Input
            rpeInputField(
                label: "Reps",
                text: $viewModel.lastSetReps,
                placeholder: "5",
                keyboardType: .numberPad,
                range: "1 - 15"
            )
            
            // RPE Input
            rpeInputField(
                label: "RPE",
                text: $viewModel.lastSetRPE,
                placeholder: "9.5",
                keyboardType: .decimalPad,
                range: "7.5 - 10.0"
            )
            
            // e1RM Output
            HStack {
                Text("e1RM*")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let e1RM = viewModel.estimated1RM {
                    HStack(spacing: 6) {
                        Text(formatWeight(e1RM))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                        Text(viewModel.isKgMode ? "KG" : "LB")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.red.opacity(0.8))
                    }
                } else {
                    Text("-")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
            
            // Note
            Text("*e1RM = estimated 1 rep max")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
        )
        .onChange(of: viewModel.lastSetWeight) { _ in
            viewModel.calculate1RM()
        }
        .onChange(of: viewModel.lastSetReps) { _ in
            viewModel.calculate1RM()
        }
        .onChange(of: viewModel.lastSetRPE) { _ in
            viewModel.calculate1RM()
        }
    }
    
    // MARK: - Next Set Card
    
    private var nextSetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Next Set")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            
            // Reps Input
            rpeInputField(
                label: "Reps",
                text: $viewModel.nextSetReps,
                placeholder: "5",
                keyboardType: .numberPad,
                range: "1 - 15"
            )
            
            // RPE Input
            rpeInputField(
                label: "RPE",
                text: $viewModel.nextSetRPE,
                placeholder: "9.5",
                keyboardType: .decimalPad,
                range: "7.5 - 10.0"
            )
            
            // Weight Output
            HStack {
                Text("Weight")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let weight = viewModel.nextSetWeight {
                    HStack(spacing: 6) {
                        Text(formatWeight(weight))
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                        Text(viewModel.isKgMode ? "KG" : "LB")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.red.opacity(0.8))
                    }
                } else {
                    Text("-")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
        )
        .onChange(of: viewModel.nextSetReps) { _ in
            viewModel.calculateNextSetWeight()
        }
        .onChange(of: viewModel.nextSetRPE) { _ in
            viewModel.calculateNextSetWeight()
        }
        .onChange(of: viewModel.estimated1RM) { _ in
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                if let range = range {
                    Text(range)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            
            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    !text.wrappedValue.isEmpty ?
                                    Color.red.opacity(0.6) :
                                    Color.gray.opacity(0.3),
                                    lineWidth: 1.5
                                )
                        )
                )
        }
    }
    
    // MARK: - Info Text
    
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("RPE & RIR are two forms of autoregulation training tools")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.gray.opacity(0.8))
            
            HStack(spacing: 4) {
                Text("Rate of Perceived Exertion")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
                Text("(RPE)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
            }
            
            HStack(spacing: 4) {
                Text("Reps In Reserve")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.gray.opacity(0.8))
                Text("(RIR)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.red)
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
