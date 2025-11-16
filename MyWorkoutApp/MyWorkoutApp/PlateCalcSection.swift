import SwiftUI

struct PlateCalcSection: View {
    @ObservedObject var viewModel: CalcViewModel
    @State private var debounceWorkItem: DispatchWorkItem?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Top section: Controls (very compact)
                VStack(spacing: 8) {
                    // Header Bar: Mode Toggle + Unit Button (single row)
                    headerBar
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                    
                    // Weight Display - Very Compact
                    HStack {
                        HStack(alignment: .firstTextBaseline, spacing: 6) {
                            Text(formatWeight(viewModel.totalWeight))
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text(viewModel.isKgMode ? "KG" : "LB")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.cyan)
                        }
                        
                        Spacer()
                        
                        // Converted weight
                        Text("\(formatWeight(viewModel.totalWeightSecondary)) \(viewModel.isKgMode ? "LB" : "KG")")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    
                    // Mode-Specific Input (compact, only in input mode)
                    if viewModel.selectedMode == .input {
                        inputModeContentCompact
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                    }
                }
                .background(Color.black)
                
                // Main Content: Barbell Visualization
                RealisticBarbellView(
                    plates: viewModel.selectedMode == .input ? viewModel.calculatedPlates : viewModel.selectedPlates,
                    isKgMode: viewModel.isKgMode
                )
                .frame(height: geometry.size.height * 0.30) // Reduced to 30% to make room for formula
                .padding(.horizontal, 20)
                .background(Color.black)
                
                // Bottom section: Controls and Breakdown
                VStack(spacing: 10) {
                    // Reverse mode plate picker (if in reverse mode)
                    if viewModel.selectedMode == .reverse {
                        reverseModeContent
                            .padding(.horizontal, 20)
                    }
                    
                    // Plate Breakdown (always show when plates exist) - MUST be visible
                    if !(viewModel.selectedMode == .input ? viewModel.calculatedPlates : viewModel.selectedPlates).isEmpty {
                        plateBreakdownView
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20) // Reduced padding since Clear All is moved
                .background(Color.black)
            }
        }
        .background(Color.black)
        .alert("Switch Mode", isPresented: $viewModel.showModeSwitchConfirmation) {
            Button("Cancel", role: .cancel) {
                viewModel.cancelModeSwitch()
            }
            Button("Switch") {
                viewModel.confirmModeSwitch()
            }
        } message: {
            if viewModel.pendingMode == .reverse {
                Text("Switch to Reverse mode? Current weight will be converted to plate selection.")
            } else {
                Text("Switch to Input mode? Current plates will be converted to target weight.")
            }
        }
        .overlay(
            // Unit conversion toast
            Group {
                if viewModel.showUnitConversionToast {
                    VStack {
                        Text(viewModel.unitConversionMessage)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.9))
                            )
                        Spacer()
                    }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.showUnitConversionToast)
                }
            }
        )
    }
    
    // MARK: - Header Bar
    
    private var headerBar: some View {
        HStack {
            // Mode Toggle - Always accessible
            Picker("Mode", selection: Binding(
                get: { viewModel.selectedMode },
                set: { newMode in
                    viewModel.requestModeSwitch(to: newMode)
                }
            )) {
                Text("Input").tag(CalculatorMode.input)
                Text("Reverse").tag(CalculatorMode.reverse)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
            
            // Unit Toggle Button - Always accessible
            Button(action: {
                viewModel.toggleUnit()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 13, weight: .semibold))
                    Text(viewModel.isKgMode ? "KG" : "LB")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.cyan.opacity(0.5), lineWidth: 1.5)
                        )
                )
            }
        }
    }
    
    // MARK: - Input Mode Content (Compact)
    
    private var inputModeContentCompact: some View {
        HStack(spacing: 16) {
            // Target Weight Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Target")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                TextField(
                    viewModel.isKgMode ? "100" : "225",
                    text: $viewModel.targetWeight
                )
                .keyboardType(.decimalPad)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .onChange(of: viewModel.targetWeight) { _ in
                    // Debounce calculation
                    debounceWorkItem?.cancel()
                    let workItem = DispatchWorkItem {
                        viewModel.calculatePlates()
                    }
                    debounceWorkItem = workItem
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
                }
            }
            
            // Bar Weight Field
            VStack(alignment: .leading, spacing: 6) {
                Text("Bar")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                TextField(
                    viewModel.isKgMode ? "20" : "45",
                    text: $viewModel.barWeight
                )
                .keyboardType(.decimalPad)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                )
                .onChange(of: viewModel.barWeight) { _ in
                    viewModel.calculatePlates()
                }
            }
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        if weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        } else {
            return String(format: "%.1f", weight)
        }
    }
    
    // MARK: - Reverse Mode Content
    
    private var reverseModeContent: some View {
        VStack(spacing: 10) {
            // Header with label and Clear All button
            HStack {
                Text("Tap plates to add")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Clear All Button (moved to header)
                if !viewModel.selectedPlates.isEmpty {
                    Button(action: {
                        withAnimation {
                            viewModel.clearAllPlates()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Clear")
                        }
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                    }
                }
            }
            
            // Plate Chip Picker - All plates visible, no scrolling
            CompactPlateGrid(
                plates: viewModel.availablePlates,
                selectedPlates: $viewModel.selectedPlates,
                isKgMode: viewModel.isKgMode,
                onAdd: { plate in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        viewModel.addPlate(plate)
                    }
                },
                onRemove: { plate in
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        viewModel.removePlate(plate)
                    }
                },
                plateCount: { plate in
                    viewModel.plateCount(plate)
                }
            )
        }
    }
    
    // MARK: - Plate Breakdown
    
    private var plateBreakdownView: some View {
        let plates = viewModel.selectedMode == .input ? viewModel.calculatedPlates : viewModel.selectedPlates
        let plateCounts = Dictionary(grouping: plates, by: { $0 })
            .mapValues { $0.count }
            .sorted { $0.key > $1.key }
        
        // Format as "Each side: 2 × 45, 1 × 25, 1 × 10"
        let breakdownText = plateCounts.map { weight, count in
            "\(count) × \(formatPlateWeight(weight))"
        }.joined(separator: ", ")
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Each side: \(breakdownText)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(3) // Allow more lines to prevent clipping
                .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func plateColorForBreakdown(_ weight: Double, isKgMode: Bool) -> Color {
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
}
