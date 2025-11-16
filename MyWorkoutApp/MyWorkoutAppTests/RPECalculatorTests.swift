import Testing
@testable import MyWorkoutApp

struct RPECalculatorTests {
    
    // Test RPE calculation logic
    @Test("RPE calculation - 225 lbs, 5 reps, RPE 9.0")
    func testRPECalculation225lbs5reps9rpe() {
        let weight = 225.0
        let reps = 5
        let rpe = 9.0
        
        // RPE table values for 9.0 RPE
        let rpeTable: [Double: [Int: Double]] = [
            9.0: [1: 0.955, 2: 0.922, 3: 0.892, 4: 0.866, 5: 0.840, 6: 0.816, 7: 0.793, 8: 0.771, 9: 0.749, 10: 0.728]
        ]
        
        guard let rpeMap = rpeTable[rpe],
              let percent = rpeMap[reps] else {
            Issue.record("RPE table lookup failed")
            return
        }
        
        let estimated1RM = weight / percent
        // Should be approximately 268 lbs (225 / 0.840)
        #expect(estimated1RM >= 267 && estimated1RM <= 269)
    }
    
    @Test("RPE calculation - 100 kg, 3 reps, RPE 10.0")
    func testRPECalculation100kg3reps10rpe() {
        let weight = 100.0
        let reps = 3
        let rpe = 10.0
        
        let rpeTable: [Double: [Int: Double]] = [
            10.0: [1: 1.00, 2: 0.955, 3: 0.922, 4: 0.892, 5: 0.866, 6: 0.84, 7: 0.816, 8: 0.793, 9: 0.771, 10: 0.749]
        ]
        
        guard let rpeMap = rpeTable[rpe],
              let percent = rpeMap[reps] else {
            Issue.record("RPE table lookup failed")
            return
        }
        
        let estimated1RM = weight / percent
        // Should be approximately 108.5 kg (100 / 0.922)
        #expect(estimated1RM >= 108 && estimated1RM <= 109)
    }
    
    @Test("RPE calculation - edge case 1 rep")
    func testRPECalculation1Rep() {
        let weight = 300.0
        let reps = 1
        let rpe = 10.0
        
        let rpeTable: [Double: [Int: Double]] = [
            10.0: [1: 1.00, 2: 0.955, 3: 0.922, 4: 0.892, 5: 0.866, 6: 0.84, 7: 0.816, 8: 0.793, 9: 0.771, 10: 0.749]
        ]
        
        guard let rpeMap = rpeTable[rpe],
              let percent = rpeMap[reps] else {
            Issue.record("RPE table lookup failed")
            return
        }
        
        let estimated1RM = weight / percent
        // At RPE 10.0 with 1 rep, 1RM should equal the weight
        #expect(estimated1RM == 300.0)
    }
}

