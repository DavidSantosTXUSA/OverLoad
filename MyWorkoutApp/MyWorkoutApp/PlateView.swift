import SwiftUI

struct PlateView: View {
    let weight: Double
    let isKgMode: Bool
    let index: Int?
    static let darkBar = Color(red: 0.15, green: 0.15, blue: 0.15)
    var body: some View {
        VStack(spacing: 2) {
            // Optional index for big plates
            if (weight == 45) || (weight == 25 && isKgMode), let idx = index {
                Text("\(idx)")
                    .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)

            }else{
                Text(" ")
                    .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)

            }

            // Plate rectangle with centered weight
            ZStack {
                RoundedRectangle(cornerRadius: 2)
                    .fill(plateColor(for: weight))
                    .frame(width: plateWidth(for: weight), height: plateHeight(for: weight))

                if plateWidth(for: weight) <= 18 {
                    // Vertical digits for narrow plates
                    VStack(spacing: 0) {
                        ForEach(Array(weight.clean), id: \.self) { char in
                            Text(String(char))
                                .font(.caption)
                                    .bold()
                                    .foregroundColor(.white)
                                    .shadow(color: .black, radius: 1, x: 0, y: 0)

                        }
                    }
                } else {
                    // Normal horizontal label
                    Text(weight.clean)
                        .font(.caption)
                        .bold()
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 1, x: 0, y: 0)

                }

            }

            // Unit label
            Text(isKgMode ? "KG" : "LB")
                .font(.caption)
                    .bold()
                    .foregroundColor(.white)
                    .shadow(color: .black, radius: 1, x: 0, y: 0)

        }
    }

    func plateWidth(for weight: Double) -> CGFloat {
        switch weight {
        case 45, 25.0: return 25
        case 20.0: return 21.5
        case 35, 15.0: return 20
        case 25, 10.0 : return 20
        case 10: return 20
        case 5: return 18
        case 2.5, 1.25: return 16
        default: return 16
        }
    }
    func plateHeight(for weight: Double) -> CGFloat {
        switch weight {
        case 45, 25.0, 20.0: return 250
        case 35 : return 225
        case 25, 15.0: return 200
        case 10: return 170
        case 5: return 140
        case 2.5: return 120
        default: return 100
        }
    }

    func plateColor(for weight: Double) -> Color {
        if isKgMode {
            switch weight {
            case 25: return .red
            case 20: return .blue
            case 15: return .yellow
            case 10: return .green
            case 5: return .white
            case 2.5: return .darkBar
            default: return .gray
            }
        } else {
            switch weight {
            case 45: return .blue
            case 35: return .yellow
            case 25: return .green
            case 10: return .darkBar
            case 5, 2.5:  return .darkBar
            default: return .gray
            }
        }
    }
}


extension Double {
    var clean: String {
        if truncatingRemainder(dividingBy: 1) == 0 {
            return String(Int(self))
        } else if self < 2 {
            return String(format: "%.2f", self) // show full detail for smaller plates
        } else {
            return String(format: "%.1f", self)
        }
    }
}
