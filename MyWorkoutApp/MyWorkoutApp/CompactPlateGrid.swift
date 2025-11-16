import SwiftUI

// Compact grid that fits all plates without scrolling
struct CompactPlateGrid: View {
    let plates: [Double]
    @Binding var selectedPlates: [Double]
    let isKgMode: Bool
    let onAdd: (Double) -> Void
    let onRemove: (Double) -> Void
    let plateCount: (Double) -> Int
    
    // Use 4 columns to fit all plates without scrolling
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(plates, id: \.self) { plate in
                CompactPlateButton(
                    weight: plate,
                    count: plateCount(plate),
                    isKgMode: isKgMode,
                    onAdd: { onAdd(plate) },
                    onRemove: { onRemove(plate) }
                )
            }
        }
    }
}

// MARK: - Compact Plate Button

struct CompactPlateButton: View {
    let weight: Double
    let count: Int
    let isKgMode: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 6) {
            // Plate chip - circular button
            ZStack {
                Circle()
                    .fill(plateColor(for: weight, isKgMode: isKgMode))
                    .frame(width: 60, height: 60)
                    .shadow(color: plateColor(for: weight, isKgMode: isKgMode).opacity(0.3), radius: 4, x: 0, y: 2)
                
                    // Weight label - white text with black stroke for readability
                    VStack(spacing: 1) {
                        ZStack {
                            // Black outline (4 directions)
                            Text(formatPlateWeight(weight))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: -1, y: -1)
                            Text(formatPlateWeight(weight))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 1, y: -1)
                            Text(formatPlateWeight(weight))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: -1, y: 1)
                            Text(formatPlateWeight(weight))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 1, y: 1)
                            // White text on top
                            Text(formatPlateWeight(weight))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        ZStack {
                            // Black outline (4 directions)
                            Text(isKgMode ? "kg" : "lb")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: -0.5, y: -0.5)
                            Text(isKgMode ? "kg" : "lb")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 0.5, y: -0.5)
                            Text(isKgMode ? "kg" : "lb")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: -0.5, y: 0.5)
                            Text(isKgMode ? "kg" : "lb")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                                .offset(x: 0.5, y: 0.5)
                            // White text on top
                            Text(isKgMode ? "kg" : "lb")
                                .font(.system(size: 10, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                
                // Count badge
                if count > 0 {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 20, height: 20)
                                
                                Text("\(count)")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 3, y: -3)
                        }
                        Spacer()
                    }
                }
            }
            
            // Control buttons - compact
            HStack(spacing: 10) {
                if count > 0 {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            onRemove()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        onAdd()
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(.green)
                }
                .buttonStyle(PlainButtonStyle())
            }
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
    
    private func plateColor(for weight: Double, isKgMode: Bool) -> Color {
        if isKgMode {
            switch weight {
            case 25: return Color(red: 0.9, green: 0.1, blue: 0.1)
            case 20: return Color(red: 0.1, green: 0.4, blue: 0.9)
            case 15: return Color(red: 1.0, green: 0.8, blue: 0.1)
            case 10: return Color(red: 0.1, green: 0.8, blue: 0.4)
            case 5: return Color(red: 0.98, green: 0.98, blue: 0.98)
            case 2.5, 1.25: return Color(red: 0.45, green: 0.45, blue: 0.45)
            default: return Color.gray.opacity(0.6)
            }
        } else {
            switch weight {
            case 45: return Color(red: 0.1, green: 0.4, blue: 0.9)
            case 35: return Color(red: 1.0, green: 0.8, blue: 0.1)
            case 25: return Color(red: 0.1, green: 0.8, blue: 0.4)
            case 10: return Color(red: 0.98, green: 0.98, blue: 0.98)
            case 5, 2.5: return Color(red: 0.3, green: 0.3, blue: 0.3)
            default: return Color.gray.opacity(0.6)
            }
        }
    }
    
    private func textColorForPlate(_ weight: Double, isKgMode: Bool) -> Color {
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

