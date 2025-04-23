import SwiftUI

struct PlateCalculatorView: View {
    @State private var targetWeight: String = "0"
    @State private var barWeight: String = "45"
    @State private var isKgMode: Bool = false
    @State private var result: [Double] = []

    let lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]
    let kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5, 0.25]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Toggle("Use KG", isOn: Binding(
                get: { isKgMode },
                set: { newValue in
                    convertUnits(toKg: newValue)
                    isKgMode = newValue
                    calculate()
                }
            ))
            .foregroundColor(.white)

            HStack {
                Text("Target Weight:")
                    .foregroundColor(.white)
                TextField(isKgMode ? "e.g. 100" : "e.g. 225", text: $targetWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            HStack {
                Text("Bar Weight:")
                    .foregroundColor(.white)
                TextField(isKgMode ? "20" : "45", text: $barWeight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Button("Calculate Plates") {
                calculate()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.green.opacity(0.7))
            .foregroundColor(.black)
            .cornerRadius(10)

            
                Text("Barbell View:")
                    .font(.title3)
                    .foregroundColor(.cyan)

                     BarbellView(plates: result, isKgMode: isKgMode)
                    .padding(.top, 48)
            

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onChange(of: targetWeight) { _ in
            calculate()
        }
        .onChange(of: barWeight) { _ in
            calculate()
        }
    }

    func convertUnits(toKg: Bool) {
        guard let target = Double(targetWeight),
              let bar = Double(barWeight) else { return }

        if toKg {
            let newTarget = (target / 2.2046226218)
            targetWeight = String(format: "%.1f", newTarget)
            barWeight = "20"
        } else {
            let newTarget = (target * 2.2046226218)
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
            while (perSide - plate) >= -0.01 { // allow small overage to never underload
                usedPlates.append(plate)
                perSide -= plate
            }
        }

        // Final safeguard: if total loaded < target, add smallest plate possible
        let loadedWeight = usedPlates.reduce(0, +) * 2 + bar
        if loadedWeight < total {
            if let smallest = plates.last, (total - loadedWeight) >= smallest {
                usedPlates.append(smallest)
            }
        }

        result = usedPlates
    }

}
