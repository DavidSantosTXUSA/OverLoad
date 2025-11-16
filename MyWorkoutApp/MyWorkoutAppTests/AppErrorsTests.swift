import Testing
@testable import MyWorkoutApp

struct AppErrorsTests {
    
    @Test("PersistenceError - error description")
    func testPersistenceErrorDescription() {
        let error = AppError.persistenceError("Failed to save")
        #expect(error.errorDescription == "Failed to save data: Failed to save")
    }
    
    @Test("ValidationError - error description")
    func testValidationErrorDescription() {
        let error = AppError.validationError("Invalid input")
        #expect(error.errorDescription == "Validation error: Invalid input")
    }
    
    @Test("EncodingError - error description")
    func testEncodingErrorDescription() {
        let error = AppError.encodingError("Encode failed")
        #expect(error.errorDescription == "Failed to encode data: Encode failed")
    }
    
    @Test("DecodingError - error description")
    func testDecodingErrorDescription() {
        let error = AppError.decodingError("Decode failed")
        #expect(error.errorDescription == "Failed to decode data: Decode failed")
    }
    
    @Test("PersistenceError - recovery suggestion")
    func testPersistenceErrorRecovery() {
        let error = AppError.persistenceError("Test")
        #expect(error.recoverySuggestion?.contains("try again") == true)
    }
    
    @Test("ValidationError - recovery suggestion")
    func testValidationErrorRecovery() {
        let error = AppError.validationError("Test")
        #expect(error.recoverySuggestion?.contains("check your input") == true)
    }
}

