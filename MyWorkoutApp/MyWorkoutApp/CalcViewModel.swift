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
    
    // MARK: - RPE Table
    let rpeTable: [Double: [Int: Double]] = [
        10.0: [1: 1.00, 2: 0.955, 3: 0.922, 4: 0.892, 5: 0.866, 6: 0.84, 7: 0.816, 8: 0.793, 9: 0.771, 10: 0.749],
        9.5: [1: 0.978, 2: 0.939, 3: 0.907, 4: 0.879, 5: 0.853, 6: 0.828, 7: 0.804, 8: 0.782, 9: 0.760, 10: 0.739],
        9.0: [1: 0.955, 2: 0.922, 3: 0.892, 4: 0.866, 5: 0.840, 6: 0.816, 7: 0.793, 8: 0.771, 9: 0.749, 10: 0.728],
        8.5: [1: 0.939, 2: 0.907, 3: 0.879, 4: 0.853, 5: 0.828, 6: 0.804, 7: 0.782, 8: 0.760, 9: 0.739, 10: 0.718],
        8.0: [1: 0.922, 2: 0.892, 3: 0.866, 4: 0.840, 5: 0.816, 6: 0.793, 7: 0.771, 8: 0.749, 9: 0.728, 10: 0.707],
        7.5: [1: 0.907, 2: 0.879, 3: 0.853, 4: 0.828, 5: 0.804, 6: 0.782, 7: 0.760, 8: 0.739, 9: 0.718, 10: 0.698]
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
              let rpeMap = rpeTable[rpe],
              rpeMap[reps] != nil else {
            return false
        }
        return true
    }
    
    var isNextSetValid: Bool {
        guard let reps = Int(nextSetReps), reps >= 1, reps <= 10,
              let rpe = Double(nextSetRPE),
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
        var perSide = (total - bar) / 2
        var usedPlates: [Double] = []
        
        for plate in plates {
            let count = Int(perSide / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                perSide -= Double(count) * plate
            }
        }
        
        // Add smallest plate if there's a remainder
        if perSide > 0.01, let smallest = plates.last {
            usedPlates.append(smallest)
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
        let sourcePlates = isKgMode ? lbPlates : kgPlates
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

