import Testing
@testable import MyWorkoutApp
import Foundation

struct PersistenceServiceTests {
    
    @Test("PersistenceService - save and load array")
    func testSaveAndLoadArray() throws {
        let service = UserDefaultsPersistenceService()
        let testKey = "testArray_\(UUID().uuidString)"
        
        let testItems = [
            Exercise(name: "Exercise 1"),
            Exercise(name: "Exercise 2")
        ]
        
        try service.save(testItems, forKey: testKey)
        let loaded = try service.load([Exercise].self, forKey: testKey)
        
        #expect(loaded.count == 2)
        #expect(loaded[0].name == "Exercise 1")
        #expect(loaded[1].name == "Exercise 2")
        
        // Cleanup
        service.remove(forKey: testKey)
    }
    
    @Test("PersistenceService - save and load single item")
    func testSaveAndLoadSingleItem() throws {
        let service = UserDefaultsPersistenceService()
        let testKey = "testItem_\(UUID().uuidString)"
        
        let testItem = Exercise(name: "Test Exercise")
        try service.save(testItem, forKey: testKey)
        
        let loaded = try service.load(Exercise.self, forKey: testKey)
        #expect(loaded?.name == "Test Exercise")
        
        // Cleanup
        service.remove(forKey: testKey)
    }
    
    @Test("PersistenceService - load non-existent key returns empty array")
    func testLoadNonExistentKeyArray() throws {
        let service = UserDefaultsPersistenceService()
        let testKey = "nonExistent_\(UUID().uuidString)"
        
        let loaded = try service.load([Exercise].self, forKey: testKey)
        #expect(loaded.isEmpty == true)
    }
    
    @Test("PersistenceService - load non-existent key returns nil")
    func testLoadNonExistentKeySingle() throws {
        let service = UserDefaultsPersistenceService()
        let testKey = "nonExistent_\(UUID().uuidString)"
        
        let loaded = try service.load(Exercise.self, forKey: testKey)
        #expect(loaded == nil)
    }
    
    @Test("PersistenceService - remove key")
    func testRemoveKey() throws {
        let service = UserDefaultsPersistenceService()
        let testKey = "testRemove_\(UUID().uuidString)"
        
        let testItem = Exercise(name: "Test")
        try service.save(testItem, forKey: testKey)
        
        var loaded = try service.load(Exercise.self, forKey: testKey)
        #expect(loaded != nil)
        
        service.remove(forKey: testKey)
        loaded = try service.load(Exercise.self, forKey: testKey)
        #expect(loaded == nil)
    }
}

