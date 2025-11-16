import Testing
@testable import MyWorkoutApp

struct PlateCalculatorTests {
    
    // Test plate calculation logic
    @Test("Plate calculation - 225 lbs with 45 lb bar")
    func testPlateCalculation225lbs() {
        let targetWeight = 225.0
        let barWeight = 45.0
        let platesPerSide = (targetWeight - barWeight) / 2.0 // 90 lbs per side
        
        let lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]
        var usedPlates: [Double] = []
        var remaining = platesPerSide
        
        for plate in lbPlates {
            let count = Int(remaining / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                remaining -= Double(count) * plate
            }
        }
        
        // Should use 2x 45lb plates per side
        let plateCount = usedPlates.filter { $0 == 45.0 }.count
        #expect(plateCount == 2)
        
        // Total weight should be approximately 225
        let totalWeight = usedPlates.reduce(0, +) * 2 + barWeight
        #expect(totalWeight >= 225 && totalWeight <= 230)
    }
    
    @Test("Plate calculation - 135 lbs with 45 lb bar")
    func testPlateCalculation135lbs() {
        let targetWeight = 135.0
        let barWeight = 45.0
        let platesPerSide = (targetWeight - barWeight) / 2.0 // 45 lbs per side
        
        let lbPlates = [45.0, 35.0, 25.0, 10.0, 5.0, 2.5]
        var usedPlates: [Double] = []
        var remaining = platesPerSide
        
        for plate in lbPlates {
            let count = Int(remaining / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                remaining -= Double(count) * plate
            }
        }
        
        // Should use 1x 45lb plate per side
        let plateCount = usedPlates.filter { $0 == 45.0 }.count
        #expect(plateCount == 1)
        
        // Total weight should be approximately 135
        let totalWeight = usedPlates.reduce(0, +) * 2 + barWeight
        #expect(totalWeight >= 135 && totalWeight <= 140)
    }
    
    @Test("Plate calculation - 100 kg with 20 kg bar")
    func testPlateCalculation100kg() {
        let targetWeight = 100.0
        let barWeight = 20.0
        let platesPerSide = (targetWeight - barWeight) / 2.0 // 40 kg per side
        
        let kgPlates = [25.0, 20.0, 15.0, 10.0, 5.0, 2.5, 1.25]
        var usedPlates: [Double] = []
        var remaining = platesPerSide
        
        for plate in kgPlates {
            let count = Int(remaining / plate)
            if count > 0 {
                usedPlates += Array(repeating: plate, count: count)
                remaining -= Double(count) * plate
            }
        }
        
        // Should use 1x 20kg and 1x 15kg per side (or similar combination)
        let totalWeight = usedPlates.reduce(0, +) * 2 + barWeight
        #expect(totalWeight >= 100 && totalWeight <= 105)
    }
}

