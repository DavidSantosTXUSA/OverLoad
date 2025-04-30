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
            VStack(alignment: .leading) {
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
                    
                }
                Text("Barbell Weight: \(calculatedWeight().clean) \(isKgMode ? "KG" : "LB") | \(isKgMode ? (calculatedWeight() * 2.20462).clean : (calculatedWeight() / 2.20462).clean) \(isKgMode ? "LB" : "KG")")
                    .font(.title3)
                    .foregroundColor(.cyan)
                    .padding(.bottom, 50)
                
                let platesToShow = mode == .input ? result : selectedPlates
                BarbellView(plates: platesToShow, isKgMode: isKgMode)

                if mode == .input {
                    inputFields
                } else {
                    PlatePickerGrid(selectedPlates: $selectedPlates, isKgMode: isKgMode)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            Toggle("Use KG mode: ", isOn: Binding(
                get: { isKgMode },
                set: { newValue in
                    if mode == .reverse {
                        convertSelectedPlates(toKg: newValue)
                        convertUnits(toKg: newValue)
                    } else {
                        convertUnits(toKg: newValue)
                    }
                    isKgMode = newValue
                    calculate()
                }
            ))
            .foregroundColor(.white)
            
            modeToggle
        }
        
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .dismissKeyboardOnTap()
        .onChange(of: targetWeight) { _ in calculate() }
        .onChange(of: barWeight) { _ in calculate() }
    }
    private var inputFields: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Target Weight:")
                    .foregroundColor(.white)
                TextField(isKgMode ? "e.g. 100" : "e.g. 225", text: $targetWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .dismissKeyboardOnTap()
            }
            .padding(.top, 40)
            
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
        if toKg {
            // Convert target only in input mode
            if mode == .input, let target = Double(targetWeight) {
                let newTarget = ceil((target / 2.20462) * 10) / 10
                targetWeight = String(format: "%.1f", newTarget)
            }
            barWeight = "20"
        } else {
            if mode == .input, let target = Double(targetWeight) {
                let newTarget = ceil((target * 2.20462) * 10) / 10
                targetWeight = String(format: "%.1f", newTarget)
            }
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

        let plates = isKgMode ? kgPlates : lbPlates
        var perSide = (total - bar) / 2
        var usedPlates: [Double] = []

        for plate in plates {
            let count = Int(perSide / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                perSide -= Double(count) * plate
            }
        }

        // Slight over if needed
        if perSide > 0.01, let smallest = plates.last {
            usedPlates.append(smallest)
        }

        result = usedPlates
    }

    func reducePlateCount(_ platesUsed: [Double], availablePlates: [Double]) -> [Double] {
        var plateCounts = Dictionary(grouping: platesUsed, by: { $0 }).mapValues { $0.count }

        // Try to replace two smaller plates with one larger when possible
        for (i, smaller) in availablePlates.reversed().enumerated() {
            for larger in availablePlates.dropLast(i + 1).reversed() {
                let needed = Int(larger / smaller)
                while plateCounts[smaller, default: 0] >= needed {
                    plateCounts[smaller]! -= needed
                    plateCounts[larger, default: 0] += 1
                }
            }
        }

        // Reconstruct the plate list
        return plateCounts.flatMap { plate, count in Array(repeating: plate, count: count) }
    }
    func convertSelectedPlates(toKg: Bool) {
        let conversionFactor = 2.20462

        let sourcePlates = toKg ? lbPlates : kgPlates
        let targetPlates = toKg ? kgPlates : lbPlates

        let converted = selectedPlates.map { plate in
            let convertedWeight = toKg ? plate / conversionFactor : plate * conversionFactor
            // Snap to closest available plate in target system
            return targetPlates.min(by: { abs($0 - convertedWeight) < abs($1 - convertedWeight) }) ?? convertedWeight
        }

        selectedPlates = converted
    }

    /*
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
         
         if perSide > 0.01 {
             if let smallest = plates.last {
                 usedPlates.append(smallest)
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
     */
}
