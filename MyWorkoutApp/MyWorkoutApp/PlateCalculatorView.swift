import SwiftUI

enum CalculatorMode {
    case input, reverse
}

struct PlateCalculatorView: View {
    @State private var targetWeight: String = "0"
    @State private var barWeight: String = "45"
    @State private var isKgMode: Bool = false
    @State private var result: [Double] = []
    @State private var mode: CalculatorMode = .input
    @State private var selectedPlates: [Double] = []

    let lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]
    let kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Toggle("Use KG", isOn: Binding(
                    get: { isKgMode },
                    set: { newValue in
                        convertUnits(toKg: newValue)
                        isKgMode = newValue
                        calculate()
                    }
                ))
                .foregroundColor(.white)
                
                modeToggle
                
                Text("Barbell Weight: \(calculatedWeight().clean) \(isKgMode ? "KG" : "LB") | \(isKgMode ? (calculatedWeight() * 2.20462).clean : (calculatedWeight() / 2.20462).clean) \(isKgMode ? "LB" : "KG")")
                    .font(.title3)
                    .foregroundColor(.cyan)
                
                if mode == .reverse && !selectedPlates.isEmpty {
                    Button(action: {
                        selectedPlates.removeAll()
                    }) {
                        Text("Clear All Plates")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.bottom, 12)
                }
                
                let platesToShow = mode == .input ? result : selectedPlates
                BarbellView(plates: platesToShow, isKgMode: isKgMode)
                
                if mode == .input {
                    inputFields
                } else {
                    PlatePickerGrid(selectedPlates: $selectedPlates, isKgMode: isKgMode)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .dismissKeyboardOnTap()
        .onChange(of: targetWeight) { _ in calculate() }
        .onChange(of: barWeight) { _ in calculate() }
    }
    private var inputFields: some View {
        VStack {
            HStack {
                Text("Target Weight:")
                    .foregroundColor(.white)
                TextField(isKgMode ? "e.g. 100" : "e.g. 225", text: $targetWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .dismissKeyboardOnTap()
            }
            
            HStack {
                Text("Bar Weight:")
                    .foregroundColor(.white)
                TextField(isKgMode ? "20" : "45", text: $barWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .dismissKeyboardOnTap()
            }
        }
    }
    
    private var modeToggle: some View {
        Picker("Mode", selection: $mode) {
            Text("Input").tag(CalculatorMode.input)
            Text("Reverse").tag(CalculatorMode.reverse)
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding(.vertical, 8)
        .onChange(of: mode) { newMode in
            if newMode == .reverse {
                selectedPlates = []
            }
        }
    }
    func calculatedWeight() -> Double {
        let bar = Double(barWeight) ?? 0
        if mode == .input {
            return result.reduce(0, +) * 2 + bar
        } else {
            return selectedPlates.reduce(0, +) * 2 + bar
        }
    }

    func convertUnits(toKg: Bool) {
        guard let target = Double(targetWeight) else { return }

        if toKg {
            let newTarget = ceil((target / 2.20462) * 10) / 10
            targetWeight = String(format: "%.1f", newTarget)
            barWeight = "20"
        } else {
            let newTarget = ceil((target * 2.20462) * 10) / 10
            targetWeight = String(format: "%.1f", newTarget)
            barWeight = "45"
        }
    }

    func calculate() {
        guard let total = Double(targetWeight),
              let bar = Double(barWeight),
              total > bar else {
            result = []
            return
        }

        var perSide = (total - bar) / 2
        let plates = isKgMode ? kgPlates : lbPlates
        var usedPlates: [Double] = []

        for plate in plates {
            while (perSide - plate) >= -0.01 {
                usedPlates.append(plate)
                perSide -= plate
            }
        }

        let loadedWeight = usedPlates.reduce(0, +) * 2 + bar
        if loadedWeight < total {
            if let smallest = plates.last, (total - loadedWeight) >= smallest {
                usedPlates.append(smallest)
            }
        }

        result = usedPlates
    }
}
