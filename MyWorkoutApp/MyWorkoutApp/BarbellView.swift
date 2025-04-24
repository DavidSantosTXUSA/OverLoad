import SwiftUI

struct BarbellView: View {
    let plates: [Double]
    let isKgMode: Bool

    var body: some View {
        ZStack(alignment: .leading) {
            // Bar base layer
            HStack(spacing: 0) {
                Rectangle() // Shaft
                    .fill(Color.darkBar)
                    .frame(width: 90, height: 12)

                Rectangle() // Grip zone
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 20, height: 32)

                Rectangle() // Sleeve where plates go (length for 10 plates)
                    .fill(Color.gray)
                    .frame(width: 200 , height: 16)

            }

            // Plate stack on top
            HStack(spacing: 2) {
                ForEach(Array(plates.enumerated()), id: \.offset) { index, plate in
                    PlateView(weight: plate, isKgMode: isKgMode, index: index + 1)
                }
            }
            .frame(height: 120)
            .padding(.leading, 110)
        }
        .frame(height: 140)
        .padding(.vertical, 35)
    }
}

extension Color {
    static let darkBar = Color(red: 0.15, green: 0.15, blue: 0.15)
}
