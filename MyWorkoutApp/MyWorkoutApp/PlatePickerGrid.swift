import SwiftUI

struct PlatePickerGrid: View {
    @Binding var selectedPlates: [Double]
    let isKgMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Load Plates!")
                .font(.headline)
                .foregroundColor(.white)

            let plates = isKgMode ? [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25, 0.5, 0.25] :
                                    [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(plates, id: \.self) { plate in
                    VStack {
                        Text(plate.clean)
                            .font(.caption)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 25, height: 25)
                                .shadow(color: .black, radius: 1, x: 0, y: 0)
                            .padding(8)
                            .background(plateColor(for: plate, isKgMode: isKgMode))
                            .clipShape(Circle())

                        HStack(spacing: 12) {
                            Button(action: {
                                if let i = selectedPlates.firstIndex(of: plate) {
                                    selectedPlates.remove(at: i)
                                }
                            }) {
                                Image(systemName: "minus.circle")
                                    .foregroundColor(.red)
                            }

                            Text("\(selectedPlates.filter { $0 == plate }.count)")

                            Button(action: {
                                selectedPlates.append(plate)
                            }) {
                                Image(systemName: "plus.circle")
                                    .foregroundColor(.green)
                            }
                        }
                        .font(.caption)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(color: .black, radius: 1, x: 0, y: 0)
                    }
                }
            }
        }
        .padding(.top, 8)
    }

    func plateColor(for weight: Double, isKgMode: Bool) -> Color {
        if isKgMode {
            switch weight {
            case 25: return .red
            case 20: return .blue
            case 15: return .yellow
            case 10: return .green
            case 5: return .white
            case 2.5, 1.25, 0.5, 0.25: return .gray
            default: return .black
            }
        } else {
            switch weight {
            case 45: return .blue
            case 35: return .yellow
            case 25: return .green
            case 10: return .white
            case 5, 2.5: return .darkBar
            default: return .black
            }
        }
    }
}
