import SwiftUI

struct PlateChipPicker: View {
    let plates: [Double]
    @Binding var selectedPlates: [Double]
    let isKgMode: Bool
    let onAdd: (Double) -> Void
    let onRemove: (Double) -> Void
    let plateCount: (Double) -> Int
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(plates, id: \.self) { plate in
                    PlateChip(
                        weight: plate,
                        count: plateCount(plate),
                        isKgMode: isKgMode,
                        onAdd: { onAdd(plate) },
                        onRemove: { onRemove(plate) }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Plate Chip Component

struct PlateChip: View {
    let weight: Double
    let count: Int
    let isKgMode: Bool
    let onAdd: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Plate chip - circular button like Bar Is Loaded
            ZStack {
                // Outer circle with plate color
                Circle()
                    .fill(plateColor(for: weight, isKgMode: isKgMode))
                    .frame(width: 75, height: 75)
                    .shadow(color: plateColor(for: weight, isKgMode: isKgMode).opacity(0.4), radius: 6, x: 0, y: 3)
                
                // Inner circle for depth
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                plateColor(for: weight, isKgMode: isKgMode).opacity(0.9),
                                plateColor(for: weight, isKgMode: isKgMode).opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                // Weight label
                VStack(spacing: 2) {
                    Text(formatPlateWeight(weight))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(textColorForPlate(weight, isKgMode: isKgMode))
                    
                    Text(isKgMode ? "kg" : "lb")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(textColorForPlate(weight, isKgMode: isKgMode).opacity(0.9))
                }
                
                // Count badge - top right corner
                if count > 0 {
                    VStack {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 26, height: 26)
                                    .shadow(color: .green.opacity(0.5), radius: 3, x: 0, y: 2)
                                
                                Text("\(count)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .offset(x: 4, y: -4)
                        }
                        Spacer()
                    }
                }
            }
            
            // Control buttons - cleaner layout
            HStack(spacing: 16) {
                if count > 0 {
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                            onRemove()
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundColor(.red)
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 0, y: 2)
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
                        .font(.system(size: 28, weight: .medium))
                        .foregroundColor(.green)
                        .shadow(color: .green.opacity(0.3), radius: 4, x: 0, y: 2)
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
            case 25: return Color(red: 0.85, green: 0.15, blue: 0.15)
            case 20: return Color(red: 0.15, green: 0.35, blue: 0.85)
            case 15: return Color(red: 0.95, green: 0.75, blue: 0.15)
            case 10: return Color(red: 0.15, green: 0.75, blue: 0.35)
            case 5: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case 2.5, 1.25: return Color(red: 0.4, green: 0.4, blue: 0.4)
            default: return Color.gray.opacity(0.6)
            }
        } else {
            switch weight {
            case 45: return Color(red: 0.15, green: 0.35, blue: 0.85)
            case 35: return Color(red: 0.95, green: 0.75, blue: 0.15)
            case 25: return Color(red: 0.15, green: 0.75, blue: 0.35)
            case 10: return Color(red: 0.95, green: 0.95, blue: 0.95)
            case 5, 2.5: return Color(red: 0.25, green: 0.25, blue: 0.25)
            default: return Color.gray.opacity(0.6)
            }
        }
    }
    
    private func textColorForPlate(_ weight: Double, isKgMode: Bool) -> Color {
        if isKgMode {
            if weight == 5 {
                return Color.black.opacity(0.8)
            }
        } else {
            if weight == 10 {
                return Color.black.opacity(0.8)
            }
        }
        return .white
    }
}

