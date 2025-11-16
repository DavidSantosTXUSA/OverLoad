import SwiftUI

struct WeightDisplayCard: View {
    let totalWeight: Double
    let secondaryWeight: Double
    let isKgMode: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Primary weight - Large, bold (like Bar Is Loaded)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(formatWeight(totalWeight))
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(isKgMode ? "KG" : "LB")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(.cyan)
            }
            
            // Secondary weight - Converted value
            Text("\(formatWeight(secondaryWeight)) \(isKgMode ? "LB" : "KG")")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.gray.opacity(0.25),
                            Color.gray.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.4),
                                    Color.cyan.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
}

