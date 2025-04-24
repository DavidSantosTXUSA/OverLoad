import SwiftUI

struct RPECalculatorView: View {
    @State private var weight: String = ""
    @State private var reps: String = ""
    @State private var rpe: String = ""
    @State private var isKgMode: Bool = false
    @State private var estimated1RM: Double?

    let rpeTable: [Double: [Int: Double]] = [
        10.0: [1: 1.00, 2: 0.955, 3: 0.922, 4: 0.892, 5: 0.866, 6: 0.84, 7: 0.816, 8: 0.793, 9: 0.771, 10: 0.749],
        9.5: [1: 0.978, 2: 0.939, 3: 0.907, 4: 0.879, 5: 0.853, 6: 0.828, 7: 0.804, 8: 0.782, 9: 0.760, 10: 0.739],
        9.0: [1: 0.955, 2: 0.922, 3: 0.892, 4: 0.866, 5: 0.840, 6: 0.816, 7: 0.793, 8: 0.771, 9: 0.749, 10: 0.728],
        8.5: [1: 0.939, 2: 0.907, 3: 0.879, 4: 0.853, 5: 0.828, 6: 0.804, 7: 0.782, 8: 0.760, 9: 0.739, 10: 0.718],
        8.0: [1: 0.922, 2: 0.892, 3: 0.866, 4: 0.840, 5: 0.816, 6: 0.793, 7: 0.771, 8: 0.749, 9: 0.728, 10: 0.707],
        7.5: [1: 0.907, 2: 0.879, 3: 0.853, 4: 0.828, 5: 0.804, 6: 0.782, 7: 0.760, 8: 0.739, 9: 0.718, 10: 0.698]
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Toggle("Use KG", isOn: $isKgMode)
                .foregroundColor(.white)

            Group {
                HStack {
                    Text("Weight:")
                        .foregroundColor(.white)
                    TextField(isKgMode ? "e.g. 100" : "e.g. 225", text: $weight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Text("Reps:")
                        .foregroundColor(.white)
                    TextField("e.g. 5", text: $reps)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                HStack {
                    Text("RPE:")
                        .foregroundColor(.white)
                    TextField("e.g. 9.5", text: $rpe)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button("Calculate 1RM") {
                    calculate()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.7))
                .foregroundColor(.black)
                .cornerRadius(10)
            }

            if let result = estimated1RM {
                let unit = isKgMode ? "kg" : "lbs"
                Text("Estimated 1RM: \(String(format: "%.1f", result)) \(unit)")
                    .font(.title2)
                    .foregroundColor(.cyan)
            }

            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .dismissKeyboardOnTap()
    }

    func calculate() {
        guard let rawWeight = Double(weight),
              let reps = Int(reps),
              let rpeValue = Double(rpe),
              reps >= 1, reps <= 10,
              let rpeMap = rpeTable[rpeValue],
              let percent = rpeMap[reps] else {
            estimated1RM = nil
            return
        }

        // Convert KG to LB if needed
        let weightInLb = isKgMode ? rawWeight * 2.2046226218 : rawWeight
        let estimated1RMLb = weightInLb / percent

        // Convert back to KG if needed
        estimated1RM = isKgMode ? estimated1RMLb / 2.2046226218 : estimated1RMLb
    }
}
