import Foundation

protocol PersistenceService {
    func save<T: Codable>(_ items: [T], forKey key: String) throws
    func load<T: Codable>(_ type: [T].Type, forKey key: String) throws -> [T]
    func save<T: Codable>(_ item: T, forKey key: String) throws
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T?
    func remove(forKey key: String)
}

class UserDefaultsPersistenceService: PersistenceService {
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func save<T: Codable>(_ items: [T], forKey key: String) throws {
        do {
            let encoded = try JSONEncoder().encode(items)
            userDefaults.set(encoded, forKey: key)
        } catch {
            throw AppError.encodingError("\(key): \(error.localizedDescription)")
        }
    }
    
    func load<T: Codable>(_ type: [T].Type, forKey key: String) throws -> [T] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }
        
        do {
            let decoded = try JSONDecoder().decode(type, from: data)
            return decoded
        } catch {
            // Clear corrupted data
            userDefaults.removeObject(forKey: key)
            throw AppError.decodingError("\(key): \(error.localizedDescription)")
        }
    }
    
    func save<T: Codable>(_ item: T, forKey key: String) throws {
        do {
            let encoded = try JSONEncoder().encode(item)
            userDefaults.set(encoded, forKey: key)
        } catch {
            throw AppError.encodingError("\(key): \(error.localizedDescription)")
        }
    }
    
    func load<T: Codable>(_ type: T.Type, forKey key: String) throws -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(type, from: data)
            return decoded
        } catch {
            // Clear corrupted data
            userDefaults.removeObject(forKey: key)
            throw AppError.decodingError("\(key): \(error.localizedDescription)")
        }
    }
    
    func remove(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}

