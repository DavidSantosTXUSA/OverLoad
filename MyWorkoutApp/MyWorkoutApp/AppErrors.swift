import Foundation

enum AppError: LocalizedError {
    case persistenceError(String)
    case validationError(String)
    case dataCorruptionError(String)
    case encodingError(String)
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .persistenceError(let message):
            return "Failed to save data: \(message)"
        case .validationError(let message):
            return "Validation error: \(message)"
        case .dataCorruptionError(let message):
            return "Data corruption detected: \(message)"
        case .encodingError(let message):
            return "Failed to encode data: \(message)"
        case .decodingError(let message):
            return "Failed to decode data: \(message)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .persistenceError:
            return "Please try again. If the problem persists, restart the app."
        case .validationError:
            return "Please check your input and try again."
        case .dataCorruptionError:
            return "Your data may need to be reset. Please contact support if this continues."
        case .encodingError, .decodingError:
            return "There was a problem reading or writing data. Please try again."
        }
    }
}

