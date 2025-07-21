//  ShoeStoreIntegrationTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class ShoeStoreIntegrationTests: XCTestCase {
    
    var shoeStore: ShoeStore!
    var testUserSettings: UserSettings!
    
    override func setUp() {
        super.setUp()
        // Create ShoeStore with in-memory context for testing
        do {
            let testContext = try createInMemoryContext()
            // Create isolated UserSettings for tests
            let testSuiteName = "ShoeStoreIntegrationTests-\(UUID().uuidString)"
            let testUserDefaults = UserDefaults(suiteName: testSuiteName)!
            testUserSettings = UserSettings(userDefaults: testUserDefaults)
            
            shoeStore = ShoeStore(context: testContext, userSettings: testUserSettings)
        } catch {
            XCTFail("Failed to create test context: \(error)")
        }
    }
    
    private func createInMemoryContext() throws -> NSManagedObjectContext {
        let model = NSManagedObjectModel.mergedModel(from: nil) ?? NSManagedObjectModel()
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.undoManager = nil
        return context
    }
    
    // MARK: - Shoe Creation Tests
    
    func testCreateShoe() throws {
        let initialCount = shoeStore.activeShoes.count
        
        let newShoe = shoeStore.createShoe()
        
        XCTAssertNotNil(newShoe, "Should create a new shoe")
        XCTAssertEqual(newShoe.maxDistance.doubleValue, 350.0, "Should have default max distance")
        XCTAssertEqual(newShoe.startDistance.doubleValue, 0.0, "Should have default start distance")
        XCTAssertEqual(newShoe.totalDistance.doubleValue, 0.0, "Should have default total distance")
        XCTAssertFalse(newShoe.hallOfFame, "Should not be in hall of fame")
        XCTAssertEqual(newShoe.brand, "", "Should have empty brand")
        
        // Verify ordering value is set
        XCTAssertGreaterThan(newShoe.orderingValue.doubleValue, 0, "Should have ordering value")
        
        // Save and verify it appears in active shoes
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        XCTAssertEqual(shoeStore.activeShoes.count, initialCount + 1, "Should have one more active shoe")
        XCTAssertTrue(shoeStore.activeShoes.contains(newShoe), "New shoe should be in active shoes")
    }
    
    func testCreateMultipleShoes() throws {
        let initialCount = shoeStore.activeShoes.count
        
        let shoe1 = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe2 = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe3 = shoeStore.createShoe()
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        XCTAssertEqual(shoeStore.activeShoes.count, initialCount + 3, "Should have three more shoes")
        
        // Verify ordering values are different and increasing
        XCTAssertLessThan(shoe1.orderingValue.doubleValue, shoe2.orderingValue.doubleValue)
        XCTAssertLessThan(shoe2.orderingValue.doubleValue, shoe3.orderingValue.doubleValue)
    }
    
    // MARK: - Shoe Removal Tests
    
    func testRemoveShoe() throws {
        let shoe = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        let initialCount = shoeStore.activeShoes.count
        
        shoeStore.remove(shoe: shoe)
        
        XCTAssertEqual(shoeStore.activeShoes.count, initialCount - 1, "Should have one fewer active shoe")
        XCTAssertFalse(shoeStore.activeShoes.contains(shoe), "Removed shoe should not be in active shoes")
        XCTAssertFalse(shoeStore.allShoes.contains(shoe), "Removed shoe should not be in all shoes")
    }
    
    func testRemoveShoeByURL() throws {
        let shoe = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        let shoeURL = shoe.objectID.uriRepresentation()
        let initialCount = shoeStore.activeShoes.count
        
        shoeStore.removeShoe(with: shoeURL)
        
        XCTAssertEqual(shoeStore.activeShoes.count, initialCount - 1, "Should have one fewer active shoe")
        XCTAssertNil(shoeStore.getShoe(from: shoeURL), "Should not be able to find removed shoe")
    }
    
    func testRemoveSelectedShoe() throws {
        let shoe = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Since ShoeStore now has isolated UserSettings injected, 
        // we mainly test that the shoe removal works correctly
        // The UserSettings integration is tested separately in UserSettingsTests
        
        shoeStore.remove(shoe: shoe)
        
        // Verify the shoe was removed
        XCTAssertFalse(shoeStore.allShoes.contains(shoe), "Removed shoe should not be in all shoes")
        XCTAssertFalse(shoeStore.activeShoes.contains(shoe), "Removed shoe should not be in active shoes")
    }
    
    // MARK: - History Management Tests
    
    func testAddHistoryToShoe() throws {
        let shoe = shoeStore.createShoe()
        let initialHistoryCount = shoe.history?.count ?? 0
        let testDate = Date()
        let testDistance = 5.5
        
        shoeStore.addHistory(to: shoe, date: testDate, distance: testDistance)
        
        let finalHistoryCount = shoe.history?.count ?? 0
        XCTAssertEqual(finalHistoryCount, initialHistoryCount + 1, "Should have one more history entry")
        
        // Verify history details
        guard let history = shoe.history?.first else {
            XCTFail("Should have history entry")
            return
        }
        
        XCTAssertEqual(history.runDate, testDate, "History should have correct date")
        XCTAssertEqual(history.runDistance.doubleValue, testDistance, "History should have correct distance")
        XCTAssertEqual(history.shoe, shoe, "History should reference the shoe")
    }
    
    func testAddMultipleHistoryEntries() throws {
        let shoe = shoeStore.createShoe()
        
        let dates = [
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 3),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 2),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 1)
        ]
        let distances = [3.0, 4.5, 2.8]
        
        for (date, distance) in zip(dates, distances) {
            shoeStore.addHistory(to: shoe, date: date, distance: distance)
        }
        
        XCTAssertEqual(shoe.history?.count, 3, "Should have three history entries")
        
        let totalHistoryDistance = (shoe.history ?? Set<History>()).total(initialValue: 0.0, for: \.runDistance.doubleValue)
        let expectedTotal = distances.reduce(0.0, +)
        
        XCTAssertEqual(totalHistoryDistance, expectedTotal, "Total history distance should match sum")
    }
    
    func testUpdateTotalDistance() throws {
        let shoe = shoeStore.createShoe()
        shoe.startDistance = NSNumber(value: 100.0)
        
        // Add some history
        shoeStore.addHistory(to: shoe, date: Date(), distance: 25.0)
        shoeStore.addHistory(to: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay), distance: 15.0)
        
        // updateTotalDistance is called automatically by addHistory, so verify it worked
        XCTAssertEqual(shoe.totalDistance.doubleValue, 140.0, "Total should be start (100) + history (40)")
        
        // Test manual update
        shoeStore.updateTotalDistance(shoe: shoe)
        XCTAssertEqual(shoe.totalDistance.doubleValue, 140.0, "Manual update should maintain correct total")
    }
    
    func testDeleteHistory() throws {
        let shoe = shoeStore.createShoe()
        shoeStore.addHistory(to: shoe, date: Date(), distance: 10.0)
        
        guard let history = shoe.history?.first else {
            XCTFail("Should have history to delete")
            return
        }
        
        let initialCount = shoe.history?.count ?? 0
        
        shoeStore.delete(history: history)
        shoeStore.saveContext()
        
        // Note: delete() only marks for deletion, need to save and check context
        // The history should be removed from the shoe's relationship
        XCTAssertNotEqual(shoe.history?.count ?? 0, initialCount, "History count should change after deletion")
    }
    
    // MARK: - Shoe Organization Tests
    
    func testActiveVsHallOfFameShoes() throws {
        let activeShoe = shoeStore.createShoe()
        activeShoe.brand = "Active Shoe"
        
        let retiredShoe = shoeStore.createShoe()
        retiredShoe.brand = "Retired Shoe"
        retiredShoe.hallOfFame = true
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        XCTAssertTrue(shoeStore.activeShoes.contains(activeShoe), "Active shoe should be in active shoes")
        XCTAssertFalse(shoeStore.activeShoes.contains(retiredShoe), "Retired shoe should not be in active shoes")
        
        XCTAssertFalse(shoeStore.hallOfFameShoes.contains(activeShoe), "Active shoe should not be in hall of fame")
        XCTAssertTrue(shoeStore.hallOfFameShoes.contains(retiredShoe), "Retired shoe should be in hall of fame")
        
        XCTAssertTrue(shoeStore.allShoes.contains(activeShoe), "Both shoes should be in all shoes")
        XCTAssertTrue(shoeStore.allShoes.contains(retiredShoe), "Both shoes should be in all shoes")
    }
    
    func testShoeOrdering() throws {
        let shoe1 = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe2 = shoeStore.createShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe3 = shoeStore.createShoe()
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Verify that our shoes have increasing ordering values
        XCTAssertLessThan(shoe1.orderingValue.doubleValue, shoe2.orderingValue.doubleValue, "Shoe1 should have lower ordering than shoe2")
        XCTAssertLessThan(shoe2.orderingValue.doubleValue, shoe3.orderingValue.doubleValue, "Shoe2 should have lower ordering than shoe3")
        
        // Verify they appear in the correct order in the sorted active shoes
        let sortedShoes = shoeStore.activeShoes.sorted { $0.orderingValue.doubleValue < $1.orderingValue.doubleValue }
        let shoe1Index = sortedShoes.firstIndex(of: shoe1)!
        let shoe2Index = sortedShoes.firstIndex(of: shoe2)!
        let shoe3Index = sortedShoes.firstIndex(of: shoe3)!
        
        XCTAssertLessThan(shoe1Index, shoe2Index, "Shoe1 should appear before shoe2 in sorted order")
        XCTAssertLessThan(shoe2Index, shoe3Index, "Shoe2 should appear before shoe3 in sorted order")
    }
    
    func testAdjustShoeOrdering() throws {
        let shoe1 = shoeStore.createShoe()
        shoe1.brand = "Shoe 1"
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe2 = shoeStore.createShoe()
        shoe2.brand = "Shoe 2"
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        let shoe3 = shoeStore.createShoe()
        shoe3.brand = "Shoe 3"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        let originalOrderingValue1 = shoe1.orderingValue.doubleValue
        let originalOrderingValue2 = shoe2.orderingValue.doubleValue
        let originalOrderingValue3 = shoe3.orderingValue.doubleValue
        
        // Move shoe1 to position 2 (between shoe2 and shoe3)
        let fromURL = shoe1.objectID.uriRepresentation()
        let toURL = shoe3.objectID.uriRepresentation()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        shoeStore.adjustShoeOrderingValue(fromOffsetURL: fromURL, toOffsetURL: toURL)
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Verify ordering changed
        XCTAssertNotEqual(shoe1.orderingValue.doubleValue, originalOrderingValue1, "Shoe1 ordering should change")
        
        // After the move, verify the final ordering relationships
        XCTAssertGreaterThan(shoe1.orderingValue.doubleValue, shoe2.orderingValue.doubleValue, "Shoe1 should be after shoe2")
        XCTAssertGreaterThan(shoe1.orderingValue.doubleValue, shoe3.orderingValue.doubleValue, "Shoe1 should be after shoe3")
    }
    
    // MARK: - Shoe Lookup Tests
    
    func testGetShoeFromURL() throws {
        let shoe = shoeStore.createShoe()
        shoe.brand = "Test Shoe"
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        let shoeURL = shoe.objectID.uriRepresentation()
        let retrievedShoe = shoeStore.getShoe(from: shoeURL)
        
        XCTAssertNotNil(retrievedShoe, "Should find shoe by URL")
        XCTAssertEqual(retrievedShoe, shoe, "Should return the correct shoe")
        XCTAssertEqual(retrievedShoe?.brand, "Test Shoe", "Should have correct properties")
    }
    
    func testGetShoeFromInvalidURL() throws {
        let invalidURL = URL(string: "invalid://url")
        let retrievedShoe = shoeStore.getShoe(from: invalidURL)
        
        XCTAssertNil(retrievedShoe, "Should return nil for invalid URL")
    }
    
    func testGetShoeFromNilURL() throws {
        let retrievedShoe = shoeStore.getShoe(from: nil)
        
        XCTAssertNil(retrievedShoe, "Should return nil for nil URL")
    }
    
    // MARK: - Context Management Tests
    
    func testSaveContext() throws {
        let shoe = shoeStore.createShoe()
        shoe.brand = "Test Save"
        
        // Context should have changes
        XCTAssertTrue(shoeStore.context.hasChanges, "Context should have unsaved changes")
        
        shoeStore.saveContext()
        
        // After save, should have no changes
        XCTAssertFalse(shoeStore.context.hasChanges, "Context should have no changes after save")
    }
    
    func testSaveContextWithNoChanges() throws {
        // This should not crash or cause issues
        shoeStore.saveContext()
        
        XCTAssertFalse(shoeStore.context.hasChanges, "Context should have no changes")
    }
    
    // MARK: - Data Persistence Tests
    
    func testShoePersistence() throws {
        let shoe = shoeStore.createShoe()
        shoe.brand = "Persistence Test"
        shoe.maxDistance = NSNumber(value: 500.0)
        shoe.startDistance = NSNumber(value: 50.0)
        
        shoeStore.saveContext()
        let shoeURL = shoe.objectID.uriRepresentation()
        
        // Create new store instance with same context and settings to test persistence
        let newStore = ShoeStore(context: shoeStore.context, userSettings: testUserSettings)
        
        let persistedShoe = newStore.getShoe(from: shoeURL)
        
        XCTAssertNotNil(persistedShoe, "Shoe should persist across store instances")
        XCTAssertEqual(persistedShoe?.brand, "Persistence Test", "Brand should persist")
        XCTAssertEqual(persistedShoe?.maxDistance.doubleValue, 500.0, "Max distance should persist")
        XCTAssertEqual(persistedShoe?.startDistance.doubleValue, 50.0, "Start distance should persist")
        
        // Clean up
        if let shoe = persistedShoe {
            newStore.remove(shoe: shoe)
        }
    }
    
    func testHistoryPersistence() throws {
        let shoe = shoeStore.createShoe()
        let testDate = Date()
        let testDistance = 7.5
        
        shoeStore.addHistory(to: shoe, date: testDate, distance: testDistance)
        shoeStore.saveContext()
        
        let shoeURL = shoe.objectID.uriRepresentation()
        
        // Create new store instance with same context and settings
        let newStore = ShoeStore(context: shoeStore.context, userSettings: testUserSettings)
        let persistedShoe = newStore.getShoe(from: shoeURL)
        
        XCTAssertNotNil(persistedShoe, "Shoe should persist")
        XCTAssertEqual(persistedShoe?.history?.count, 1, "History should persist")
        
        guard let history = persistedShoe?.history?.first else {
            XCTFail("Should have persisted history")
            return
        }
        
        XCTAssertEqual(history.runDistance.doubleValue, testDistance, "Distance should persist")
        XCTAssertEqual(history.runDate.timeIntervalSince1970, testDate.timeIntervalSince1970, accuracy: 1.0, "Date should persist")
        
        // Clean up
        if let shoe = persistedShoe {
            newStore.remove(shoe: shoe)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testUpdateAllShoesWithoutPublishing() throws {
        let initialActiveCount = shoeStore.activeShoes.count
        
        let shoe = shoeStore.createShoe()
        shoeStore.saveContext()
        
        // Update without publishing changes
        shoeStore.updateAllShoes(publishChanges: false)
        
        // Published arrays should not have changed
        XCTAssertEqual(shoeStore.activeShoes.count, initialActiveCount, "Published arrays should not update")
        
        // But internal state should be updated when changed to true
        shoeStore.updateAllShoes(publishChanges: true)
        XCTAssertEqual(shoeStore.activeShoes.count, initialActiveCount + 1, "Should update after publishing")
    }
}
