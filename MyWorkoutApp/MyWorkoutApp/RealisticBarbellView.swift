import SwiftUI

struct RealisticBarbellView: View {
    let plates: [Double]
    let isKgMode: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Bar base layer - horizontal bar structure
            HStack(spacing: 0) {
                // Left: Shaft (smooth section)
                Rectangle()
                    .fill(Color(red: 0.18, green: 0.18, blue: 0.18))
                    .frame(width: 80, height: 14)
                
                // Center: Grip zone (knurled area) - wider and more prominent
                ZStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(red: 0.22, green: 0.22, blue: 0.22))
                        .frame(width: 60, height: 20)
                    
                    // Knurling pattern
                    HStack(spacing: 3) {
                        ForEach(0..<8) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 2, height: 20)
                        }
                    }
                }
                
                // Right: Sleeve where plates go (long enough for many plates)
                Rectangle()
                    .fill(Color(red: 0.26, green: 0.26, blue: 0.26))
                    .frame(width: 250, height: 18)
            }
            
            // Plate stack on top - ONE SIDE ONLY (right side)
            HStack(spacing: 2) {
                ForEach(Array(plates.sorted(by: >).enumerated()), id: \.offset) { index, plate in
                    PlateBarView(weight: plate, isKgMode: isKgMode)
                }
            }
            .frame(height: 200) // Accommodate taller plates
            .padding(.leading, 140) // Start after shaft + grip
        }
        .frame(height: 220) // Increased to accommodate taller plates
        .padding(.vertical, 20)
    }
}

// MARK: - Plate Bar View (Tall, Skinny Vertical Rectangles)

struct PlateBarView: View {
    let weight: Double
    let isKgMode: Bool
    
    var body: some View {
        // Plate rectangle - tall and skinny
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(plateColor(for: weight, isKgMode: isKgMode))
                .frame(
                    width: plateWidth(for: weight),
                    height: plateHeight(for: weight)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(Color.black.opacity(0.3), lineWidth: 0.5)
                )
            
            // Weight label ON the plate - number at top, unit below
            VStack(spacing: 2) {
                Text(formatPlateWeight(weight))
                    .font(.system(size: plateFontSize(for: weight), weight: .bold, design: .rounded))
                    .foregroundColor(textColorForPlate(weight, isKgMode: isKgMode))
                    .shadow(color: Color.black.opacity(0.7), radius: 2, x: 0, y: 1)
                
                Text(isKgMode ? "KG" : "LB")
                    .font(.system(size: plateUnitFontSize(for: weight), weight: .medium, design: .rounded))
                    .foregroundColor(textColorForPlate(weight, isKgMode: isKgMode).opacity(0.9))
                    .shadow(color: Color.black.opacity(0.7), radius: 1, x: 0, y: 1)
            }
            .padding(.top, 6) // Position at top of plate
        }
    }
    
    private func formatPlateWeight(_ weight: Double) -> String {
        if weight == 2.5 {
            return "2.5"
        } else if weight == 1.25 {
            return "1.25"
        } else if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
    
    // Width - same thickness for all plates
    private func plateWidth(for weight: Double) -> CGFloat {
        // All plates same width (thickness)
        return 18
    }
    
    // Height - realistic proportions: 25kg/45lb and 20kg/35lb same height (taller), then decreasing
    private func plateHeight(for weight: Double) -> CGFloat {
        if isKgMode {
            switch weight {
            case 25, 20: return 200 // 25kg and 20kg same height - taller
            case 15: return 150 // Smaller
            case 10: return 130 // Smaller
            case 5: return 110 // Smaller
            case 2.5: return 65 // Much smaller
            case 1.25: return 55 // Much smaller
            default: return 100
            }
        } else {
            switch weight {
            case 45: return 200 // 45lb - tallest
            case 35: return 150 // 35lb same height as 15kg
            case 25: return 130 // 25lb same height as 10kg
            case 10: return 110 // Smaller
            case 5: return 75 // Taller than 2.5lb (like 2.5kg vs 1.25kg)
            case 2.5: return 65 // Smaller
            default: return 100
            }
        }
    }
    
    private func plateFontSize(for weight: Double) -> CGFloat {
        if isKgMode {
            if weight >= 20 {
                return 16
            } else if weight >= 10 {
                return 14
            } else if weight >= 5 {
                return 12
            } else {
                return 10
            }
        } else {
            if weight >= 35 {
                return 16
            } else if weight >= 25 {
                return 14
            } else if weight >= 10 {
                return 12
            } else {
                return 10
            }
        }
    }
    
    private func plateUnitFontSize(for weight: Double) -> CGFloat {
        if isKgMode {
            if weight >= 20 {
                return 11
            } else if weight >= 10 {
                return 10
            } else if weight >= 5 {
                return 9
            } else {
                return 8
            }
        } else {
            if weight >= 35 {
                return 11
            } else if weight >= 25 {
                return 10
            } else if weight >= 10 {
                return 9
            } else {
                return 8
            }
        }
    }
    
    private func plateColor(for weight: Double, isKgMode: Bool) -> Color {
        // Competition standard colors
        if isKgMode {
            switch weight {
            case 25: return Color(red: 0.9, green: 0.1, blue: 0.1) // Red
            case 20: return Color(red: 0.1, green: 0.4, blue: 0.9) // Blue
            case 15: return Color(red: 1.0, green: 0.8, blue: 0.1) // Yellow
            case 10: return Color(red: 0.1, green: 0.8, blue: 0.4) // Green
            case 5: return Color(red: 0.98, green: 0.98, blue: 0.98) // White
            case 2.5, 1.25: return Color(red: 0.45, green: 0.45, blue: 0.45) // Gray
            default: return Color.gray.opacity(0.6)
            }
        } else {
            switch weight {
            case 45: return Color(red: 0.1, green: 0.4, blue: 0.9) // Blue
            case 35: return Color(red: 1.0, green: 0.8, blue: 0.1) // Yellow
            case 25: return Color(red: 0.1, green: 0.8, blue: 0.4) // Green
            case 10: return Color(red: 0.98, green: 0.98, blue: 0.98) // White
            case 5, 2.5: return Color(red: 0.3, green: 0.3, blue: 0.3) // Dark gray
            default: return Color.gray.opacity(0.6)
            }
        }
    }
    
    private func textColorForPlate(_ weight: Double, isKgMode: Bool) -> Color {
        // White plates need dark text
        if isKgMode {
            if weight == 5 {
                return Color.black.opacity(0.85)
            }
        } else {
            if weight == 10 {
                return Color.black.opacity(0.85)
            }
        }
        return .white
    }
}
