import Foundation
import SwiftUI

class CalcViewModel: ObservableObject {
    // MARK: - Plate Calculator State
    @Published var selectedMode: CalculatorMode = .input
    @Published var isKgMode: Bool = false
    
    // Input mode
    @Published var targetWeight: String = "0"
    @Published var barWeight: String = "45"
    @Published var calculatedPlates: [Double] = []
    
    // Reverse mode
    @Published var selectedPlates: [Double] = []
    
    // Mode switching confirmation
    @Published var showModeSwitchConfirmation: Bool = false
    @Published var pendingMode: CalculatorMode?
    @Published var showUnitConversionToast: Bool = false
    @Published var unitConversionMessage: String = ""
    
    // MARK: - RPE Calculator State
    // Last Set (inputs weight, reps, RPE → calculates e1RM)
    @Published var lastSetWeight: String = ""
    @Published var lastSetReps: String = ""
    @Published var lastSetRPE: String = ""
    @Published var estimated1RM: Double? // Calculated from Last Set
    
    // Next Set (inputs reps, RPE → calculates weight from e1RM)
    @Published var nextSetReps: String = ""
    @Published var nextSetRPE: String = ""
    @Published var nextSetWeight: Double? // Calculated from e1RM
    
    // Legacy support (for backward compatibility)
    var rpeWeight: String {
        get { lastSetWeight }
        set { lastSetWeight = newValue }
    }
    var rpeReps: String {
        get { lastSetReps }
        set { lastSetReps = newValue }
    }
    var rpeValue: String {
        get { lastSetRPE }
        set { lastSetRPE = newValue }
    }
    
    // MARK: - Plate Arrays
    let lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]
    let kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25]
    
    // MARK: - RPE Table (Extended to 1.0-10.0)
    let rpeTable: [Double: [Int: Double]] = [
        10.0: [1: 1.00, 2: 0.955, 3: 0.922, 4: 0.892, 5: 0.866, 6: 0.84, 7: 0.816, 8: 0.793, 9: 0.771, 10: 0.749],
        9.5: [1: 0.978, 2: 0.939, 3: 0.907, 4: 0.879, 5: 0.853, 6: 0.828, 7: 0.804, 8: 0.782, 9: 0.760, 10: 0.739],
        9.0: [1: 0.955, 2: 0.922, 3: 0.892, 4: 0.866, 5: 0.840, 6: 0.816, 7: 0.793, 8: 0.771, 9: 0.749, 10: 0.728],
        8.5: [1: 0.939, 2: 0.907, 3: 0.879, 4: 0.853, 5: 0.828, 6: 0.804, 7: 0.782, 8: 0.760, 9: 0.739, 10: 0.718],
        8.0: [1: 0.922, 2: 0.892, 3: 0.866, 4: 0.840, 5: 0.816, 6: 0.793, 7: 0.771, 8: 0.749, 9: 0.728, 10: 0.707],
        7.5: [1: 0.907, 2: 0.879, 3: 0.853, 4: 0.828, 5: 0.804, 6: 0.782, 7: 0.760, 8: 0.739, 9: 0.718, 10: 0.698],
        7.0: [1: 0.892, 2: 0.866, 3: 0.840, 4: 0.816, 5: 0.793, 6: 0.771, 7: 0.749, 8: 0.728, 9: 0.707, 10: 0.687],
        6.5: [1: 0.879, 2: 0.853, 3: 0.828, 4: 0.804, 5: 0.782, 6: 0.760, 7: 0.739, 8: 0.718, 9: 0.698, 10: 0.678],
        6.0: [1: 0.866, 2: 0.840, 3: 0.816, 4: 0.793, 5: 0.771, 6: 0.749, 7: 0.728, 8: 0.707, 9: 0.687, 10: 0.667],
        5.5: [1: 0.853, 2: 0.828, 3: 0.804, 4: 0.782, 5: 0.760, 6: 0.739, 7: 0.718, 8: 0.698, 9: 0.678, 10: 0.658],
        5.0: [1: 0.840, 2: 0.816, 3: 0.793, 4: 0.771, 5: 0.749, 6: 0.728, 7: 0.707, 8: 0.687, 9: 0.667, 10: 0.648],
        4.5: [1: 0.828, 2: 0.804, 3: 0.782, 4: 0.760, 5: 0.739, 6: 0.718, 7: 0.698, 8: 0.678, 9: 0.658, 10: 0.639],
        4.0: [1: 0.816, 2: 0.793, 3: 0.771, 4: 0.749, 5: 0.728, 6: 0.707, 7: 0.687, 8: 0.667, 9: 0.648, 10: 0.629],
        3.5: [1: 0.804, 2: 0.782, 3: 0.760, 4: 0.739, 5: 0.718, 6: 0.698, 7: 0.678, 8: 0.658, 9: 0.639, 10: 0.620],
        3.0: [1: 0.793, 2: 0.771, 3: 0.749, 4: 0.728, 5: 0.707, 6: 0.687, 7: 0.667, 8: 0.648, 9: 0.629, 10: 0.611],
        2.5: [1: 0.782, 2: 0.760, 3: 0.739, 4: 0.718, 5: 0.698, 6: 0.678, 7: 0.658, 8: 0.639, 9: 0.620, 10: 0.602],
        2.0: [1: 0.771, 2: 0.749, 3: 0.728, 4: 0.707, 5: 0.687, 6: 0.667, 7: 0.648, 8: 0.629, 9: 0.611, 10: 0.593],
        1.5: [1: 0.760, 2: 0.739, 3: 0.718, 4: 0.698, 5: 0.678, 6: 0.658, 7: 0.639, 8: 0.620, 9: 0.602, 10: 0.584],
        1.0: [1: 0.749, 2: 0.728, 3: 0.707, 4: 0.687, 5: 0.667, 6: 0.648, 7: 0.629, 8: 0.611, 9: 0.593, 10: 0.575]
    ]
    
    // MARK: - Computed Properties
    
    var availablePlates: [Double] {
        isKgMode ? kgPlates : lbPlates
    }
    
    var totalWeight: Double {
        let bar = Double(barWeight) ?? 0
        let plates = selectedMode == .input ? calculatedPlates : selectedPlates
        return plates.reduce(0, +) * 2 + bar
    }
    
    var totalWeightSecondary: Double {
        if isKgMode {
            return totalWeight * 2.20462 // Convert to LB
        } else {
            return totalWeight / 2.20462 // Convert to KG
        }
    }
    
    var isRPEValid: Bool {
        guard let weight = Double(lastSetWeight), weight > 0,
              let reps = Int(lastSetReps), reps >= 1, reps <= 10,
              let rpe = Double(lastSetRPE),
              rpe >= 1.0, rpe <= 10.0,
              let rpeMap = rpeTable[rpe],
              rpeMap[reps] != nil else {
            return false
        }
        return true
    }
    
    var isNextSetValid: Bool {
        guard let reps = Int(nextSetReps), reps >= 1, reps <= 10,
              let rpe = Double(nextSetRPE),
              rpe >= 1.0, rpe <= 10.0,
              let rpeMap = rpeTable[rpe],
              rpeMap[reps] != nil,
              estimated1RM != nil else {
            return false
        }
        return true
    }
    
    // MARK: - Plate Calculator Methods
    
    func calculatePlates() {
        guard let total = Double(targetWeight),
              let bar = Double(barWeight),
              total > bar else {
            calculatedPlates = []
            return
        }
        
        let plates = availablePlates
        let perSide = (total - bar) / 2
        var usedPlates: [Double] = []
        var remaining = perSide
        
        // Greedy algorithm: use largest plates first
        for plate in plates {
            let count = Int(remaining / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                remaining -= Double(count) * plate
            }
        }
        
        // Round to nearest loadable weight using smallest plate
        if let smallest = plates.last, remaining > 0 {
            // Check if we should round up or down
            let roundUp = remaining >= (smallest / 2)
            if roundUp {
                usedPlates.append(smallest)
            }
        }
        
        calculatedPlates = usedPlates
    }
    
    func toggleUnit() {
        let hasWeightOnBar = !calculatedPlates.isEmpty || !selectedPlates.isEmpty
        
        isKgMode.toggle()
        
        // Convert bar weight
        if isKgMode {
            barWeight = "20"
        } else {
            barWeight = "45"
        }
        
        // Convert target weight in input mode
        if selectedMode == .input, let target = Double(targetWeight), target > 0 {
            if isKgMode {
                let newTarget = ceil((target / 2.20462) * 10) / 10
                targetWeight = String(format: "%.1f", newTarget)
            } else {
                let newTarget = ceil((target * 2.20462) * 10) / 10
                targetWeight = String(format: "%.1f", newTarget)
            }
            calculatePlates()
        }
        
        // Convert selected plates in reverse mode
        if selectedMode == .reverse {
            convertSelectedPlates()
        }
        
        // Show toast if weight was on bar
        if hasWeightOnBar {
            unitConversionMessage = "Converted to \(isKgMode ? "KG" : "LB")"
            showUnitConversionToast = true
            // Auto-hide after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showUnitConversionToast = false
            }
        }
    }
    
    // MARK: - Mode Switching
    
    func requestModeSwitch(to newMode: CalculatorMode) {
        let hasWeightOnBar = !calculatedPlates.isEmpty || !selectedPlates.isEmpty
        
        if hasWeightOnBar {
            // Show confirmation
            pendingMode = newMode
            showModeSwitchConfirmation = true
        } else {
            // Switch immediately
            selectedMode = newMode
        }
    }
    
    func confirmModeSwitch() {
        guard let newMode = pendingMode else { return }
        
        if newMode == .reverse && selectedMode == .input {
            // Convert calculated plates to selected plates
            selectedPlates = calculatedPlates
            calculatedPlates = []
            targetWeight = "0"
        } else if newMode == .input && selectedMode == .reverse {
            // Convert selected plates to target weight
            let total = totalWeight
            targetWeight = String(format: "%.1f", total)
            calculatePlates()
            selectedPlates = []
        }
        
        selectedMode = newMode
        pendingMode = nil
        showModeSwitchConfirmation = false
    }
    
    func cancelModeSwitch() {
        pendingMode = nil
        showModeSwitchConfirmation = false
    }
    
    func convertSelectedPlates() {
        let conversionFactor = 2.20462
        let targetPlates = availablePlates
        
        let converted = selectedPlates.map { plate in
            let convertedWeight = isKgMode ? plate / conversionFactor : plate * conversionFactor
            // Snap to closest available plate
            return targetPlates.min(by: { abs($0 - convertedWeight) < abs($1 - convertedWeight) }) ?? convertedWeight
        }
        
        selectedPlates = converted
    }
    
    func addPlate(_ plate: Double) {
        selectedPlates.append(plate)
    }
    
    func removePlate(_ plate: Double) {
        if let index = selectedPlates.firstIndex(of: plate) {
            selectedPlates.remove(at: index)
        }
    }
    
    func clearAllPlates() {
        selectedPlates.removeAll()
    }
    
    func plateCount(_ plate: Double) -> Int {
        selectedPlates.filter { $0 == plate }.count
    }
    
    // MARK: - RPE Calculator Methods
    
    // Calculate e1RM from Last Set (weight, reps, RPE)
    func calculate1RM() {
        guard let rawWeight = Double(lastSetWeight),
              let reps = Int(lastSetReps),
              let rpeValue = Double(lastSetRPE),
              reps >= 1, reps <= 10,
              let rpeMap = rpeTable[rpeValue],
              let percent = rpeMap[reps] else {
            estimated1RM = nil
            nextSetWeight = nil
            return
        }
        
        // Convert KG to LB if needed
        let weightInLb = isKgMode ? rawWeight * 2.2046226218 : rawWeight
        let estimated1RMLb = weightInLb / percent
        
        // Convert back to KG if needed
        estimated1RM = isKgMode ? estimated1RMLb / 2.2046226218 : estimated1RMLb
        
        // Recalculate Next Set weight if inputs are valid
        calculateNextSetWeight()
    }
    
    // Calculate weight for Next Set from e1RM, reps, RPE
    func calculateNextSetWeight() {
        guard let e1RM = estimated1RM,
              let reps = Int(nextSetReps),
              let rpeValue = Double(nextSetRPE),
              reps >= 1, reps <= 10,
              let rpeMap = rpeTable[rpeValue],
              let percent = rpeMap[reps] else {
            nextSetWeight = nil
            return
        }
        
        // Convert e1RM to LB for calculation
        let e1RMLb = isKgMode ? e1RM * 2.2046226218 : e1RM
        let weightLb = e1RMLb * percent
        
        // Convert back to KG if needed
        nextSetWeight = isKgMode ? weightLb / 2.2046226218 : weightLb
    }
    
    func clearRPE() {
        lastSetWeight = ""
        lastSetReps = ""
        lastSetRPE = ""
        nextSetReps = ""
        nextSetRPE = ""
        estimated1RM = nil
        nextSetWeight = nil
    }
}

