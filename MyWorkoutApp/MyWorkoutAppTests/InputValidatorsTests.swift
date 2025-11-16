import Testing
@testable import MyWorkoutApp

struct InputValidatorsTests {
    
    @Test("Weight validation - valid range")
    func testWeightValidationValidRange() {
        #expect(InputValidators.validateWeight(0) == true)
        #expect(InputValidators.validateWeight(100) == true)
        #expect(InputValidators.validateWeight(500) == true)
        #expect(InputValidators.validateWeight(1000) == true)
    }
    
    @Test("Weight validation - invalid range")
    func testWeightValidationInvalidRange() {
        #expect(InputValidators.validateWeight(-1) == false)
        #expect(InputValidators.validateWeight(1001) == false)
    }
    
    @Test("Weight clamping - within range")
    func testWeightClampingWithinRange() {
        #expect(InputValidators.clampWeight(100) == 100)
        #expect(InputValidators.clampWeight(0) == 0)
        #expect(InputValidators.clampWeight(1000) == 1000)
    }
    
    @Test("Weight clamping - below minimum")
    func testWeightClampingBelowMinimum() {
        #expect(InputValidators.clampWeight(-10) == 0)
        #expect(InputValidators.clampWeight(-100) == 0)
    }
    
    @Test("Weight clamping - above maximum")
    func testWeightClampingAboveMaximum() {
        #expect(InputValidators.clampWeight(1500) == 1000)
        #expect(InputValidators.clampWeight(2000) == 1000)
    }
    
    @Test("Reps validation - valid range")
    func testRepsValidationValidRange() {
        #expect(InputValidators.validateReps(0) == true)
        #expect(InputValidators.validateReps(10) == true)
        #expect(InputValidators.validateReps(50) == true)
        #expect(InputValidators.validateReps(100) == true)
    }
    
    @Test("Reps validation - invalid range")
    func testRepsValidationInvalidRange() {
        #expect(InputValidators.validateReps(-1) == false)
        #expect(InputValidators.validateReps(101) == false)
    }
    
    @Test("Reps clamping - within range")
    func testRepsClampingWithinRange() {
        #expect(InputValidators.clampReps(10) == 10)
        #expect(InputValidators.clampReps(0) == 0)
        #expect(InputValidators.clampReps(100) == 100)
    }
    
    @Test("Reps clamping - below minimum")
    func testRepsClampingBelowMinimum() {
        #expect(InputValidators.clampReps(-5) == 0)
        #expect(InputValidators.clampReps(-100) == 0)
    }
    
    @Test("Reps clamping - above maximum")
    func testRepsClampingAboveMaximum() {
        #expect(InputValidators.clampReps(150) == 100)
        #expect(InputValidators.clampReps(200) == 100)
    }
}

