//  SelectedShoeStrategyTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/21/25.
//  

import XCTest
@testable import ShoeCycle

final class SelectedShoeStrategyTests: DBInteractiveTestCase {
    
    var shoeStore: ShoeStore!
    var testUserSettings: UserSettings!
    var strategy: SelectedShoeStrategy!
    var testSuiteName: String!
    
    override func setUp() {
        super.setUp()
        
        // Create isolated UserSettings for tests
        testSuiteName = "SelectedShoeStrategyTests-\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: testSuiteName)!
        testUserSettings = UserSettings(userDefaults: testUserDefaults)
        
        // Create ShoeStore with test context and settings
        shoeStore = ShoeStore(context: testContext, userSettings: testUserSettings)
        
        // Create strategy instance
        strategy = SelectedShoeStrategy(store: shoeStore, settings: testUserSettings)
    }
    
    override func tearDown() {
        // Clean up the unique test suite
        if let suiteName = testSuiteName {
            UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        }
        strategy = nil
        testUserSettings = nil
        shoeStore = nil
        testSuiteName = nil
        super.tearDown()
    }
    
    // MARK: - updateSelectedShoe() Tests
    
    // Given: No active shoes exist and a mock selected shoe URL is set
    // When: updateSelectedShoe() is called
    // Then: The selected shoe URL should be cleared
    func testUpdateSelectedShoeWithNoActiveShoes() throws {
        // Start with no active shoes
        XCTAssertEqual(shoeStore.activeShoes.count, 0, "Should start with no active shoes")
        
        // Set a mock selected shoe URL first
        let mockURL = URL(string: "x-coredata://test/Shoe/123")!
        testUserSettings.setSelected(shoeUrl: mockURL)
        XCTAssertNotNil(testUserSettings.selectedShoeURL, "Should have mock selected shoe")
        
        strategy.updateSelectedShoe()
        
        XCTAssertNil(testUserSettings.selectedShoeURL, "Should clear selected shoe when no active shoes")
    }
    
    // Given: Two active shoes exist and shoe2 is selected
    // When: updateSelectedShoe() is called
    // Then: The selection should be maintained since shoe2 is still active
    func testUpdateSelectedShoeWithValidSelection() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "Shoe 1"
        let shoe2 = createTestShoe()
        shoe2.brand = "Shoe 2"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Select shoe2
        let shoe2URL = shoe2.objectID.uriRepresentation()
        testUserSettings.setSelected(shoeUrl: shoe2URL)
        
        strategy.updateSelectedShoe()
        
        // Should maintain the selection since shoe2 is still active
        XCTAssertEqual(testUserSettings.selectedShoeURL, shoe2URL, "Should maintain valid selection")
    }
    
    // Given: One active shoe exists and an invalid shoe URL is selected
    // When: updateSelectedShoe() is called
    // Then: Should fallback to first active shoe
    func testUpdateSelectedShoeWithInvalidSelection() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "Active Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Set invalid selected shoe URL (shoe that doesn't exist)
        let invalidURL = URL(string: "x-coredata://test/Shoe/nonexistent")!
        testUserSettings.setSelected(shoeUrl: invalidURL)
        
        strategy.updateSelectedShoe()
        
        // Should fallback to first active shoe
        let expectedURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(testUserSettings.selectedShoeURL, expectedURL, "Should select first active shoe when current selection is invalid")
    }
    
    // Given: Two active shoes exist and no shoe is selected
    // When: updateSelectedShoe() is called
    // Then: Should select first active shoe
    func testUpdateSelectedShoeWithNoSelection() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "First Shoe"
        let shoe2 = createTestShoe()
        shoe2.brand = "Second Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Ensure no shoe is selected
        XCTAssertNil(testUserSettings.selectedShoeURL, "Should start with no selection")
        
        strategy.updateSelectedShoe()
        
        // Should select first active shoe
        let expectedURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(testUserSettings.selectedShoeURL, expectedURL, "Should select first active shoe when none selected")
    }
    
    // Given: Two active shoes exist, shoe2 is selected, then shoe2 is retired
    // When: updateSelectedShoe() is called after shoe retirement
    // Then: Should fallback to shoe1 since shoe2 is no longer active
    func testUpdateSelectedShoeAfterShoeRemoval() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "First Shoe"
        let shoe2 = createTestShoe()
        shoe2.brand = "Second Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Select shoe2
        let shoe2URL = shoe2.objectID.uriRepresentation()
        testUserSettings.setSelected(shoeUrl: shoe2URL)
        
        // Remove shoe2 from active shoes (simulate retirement)
        shoe2.hallOfFame = true
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        strategy.updateSelectedShoe()
        
        // Should fallback to shoe1 since shoe2 is no longer active
        let expectedURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(testUserSettings.selectedShoeURL, expectedURL, "Should fallback to first active shoe when selected shoe becomes inactive")
    }
    
    // MARK: - updateSelectedSelectedShoeStorageFromLegacyIfNeeded() Tests
    
    // Given: Legacy system has valid shoe index (1) and multiple shoes exist
    // When: updateSelectedSelectedShoeStorageFromLegacyIfNeeded() is called
    // Then: Should migrate to shoe at legacy index 1
    func testLegacyMigrationWithValidIndex() throws {
        // Set up legacy selected shoe index
        let legacyTestSuiteName = "LegacyTest-\(UUID().uuidString)"
        let legacyUserDefaults = UserDefaults(suiteName: legacyTestSuiteName)!
        legacyUserDefaults.set(1, forKey: UserSettings.StorageKey.legacySelectedShoe) // Select index 1
        
        let legacyUserSettings = UserSettings(userDefaults: legacyUserDefaults)
        let legacyShoeStore = ShoeStore(context: testContext, userSettings: legacyUserSettings)
        let legacyStrategy = SelectedShoeStrategy(store: legacyShoeStore, settings: legacyUserSettings)
        
        // Create multiple shoes
        let shoe1 = createTestShoe()
        shoe1.brand = "Shoe at Index 0"
        let shoe2 = createTestShoe()
        shoe2.brand = "Shoe at Index 1"
        let shoe3 = createTestShoe()
        shoe3.brand = "Shoe at Index 2"
        
        legacyShoeStore.saveContext()
        legacyShoeStore.updateAllShoes()
        
        // Verify no modern selection exists
        XCTAssertNil(legacyUserSettings.selectedShoeURL, "Should have no modern selection initially")
        XCTAssertEqual(legacyUserSettings.legacySelectedShoe, 1, "Should have legacy index 1")
        
        legacyStrategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        
        // Should migrate to shoe at index 1 (shoe2)
        let expectedURL = shoe2.objectID.uriRepresentation()
        XCTAssertEqual(legacyUserSettings.selectedShoeURL, expectedURL, "Should migrate to shoe at legacy index 1")
        
        // Clean up
        legacyUserDefaults.removePersistentDomain(forName: legacyTestSuiteName)
    }
    
    // Given: Legacy system has invalid shoe index (5) and only 2 shoes exist
    // When: updateSelectedSelectedShoeStorageFromLegacyIfNeeded() is called
    // Then: Should fallback to first shoe when legacy index is invalid
    func testLegacyMigrationWithInvalidIndex() throws {
        // Set up legacy selected shoe index that's out of bounds
        let legacyTestSuiteName = "LegacyTest-\(UUID().uuidString)"
        let legacyUserDefaults = UserDefaults(suiteName: legacyTestSuiteName)!
        legacyUserDefaults.set(5, forKey: UserSettings.StorageKey.legacySelectedShoe) // Invalid index
        
        let legacyUserSettings = UserSettings(userDefaults: legacyUserDefaults)
        let legacyShoeStore = ShoeStore(context: testContext, userSettings: legacyUserSettings)
        let legacyStrategy = SelectedShoeStrategy(store: legacyShoeStore, settings: legacyUserSettings)
        
        // Create only 2 shoes (indices 0 and 1)
        let shoe1 = createTestShoe()
        shoe1.brand = "First Shoe"
        let shoe2 = createTestShoe()
        shoe2.brand = "Second Shoe"
        
        legacyShoeStore.saveContext()
        legacyShoeStore.updateAllShoes()
        
        XCTAssertEqual(legacyUserSettings.legacySelectedShoe, 5, "Should have invalid legacy index 5")
        
        legacyStrategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        
        // Should fallback to first shoe when legacy index is invalid
        let expectedURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(legacyUserSettings.selectedShoeURL, expectedURL, "Should fallback to first shoe when legacy index is invalid")
        
        // Clean up
        legacyUserDefaults.removePersistentDomain(forName: legacyTestSuiteName)
    }
    
    // Given: Both legacy selection and modern selection exist
    // When: updateSelectedSelectedShoeStorageFromLegacyIfNeeded() is called
    // Then: Should preserve existing modern selection and ignore legacy
    func testLegacyMigrationWithExistingModernSelection() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "Modern Selected Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Set both legacy and modern selection
        let modernURL = shoe1.objectID.uriRepresentation()
        testUserSettings.setSelected(shoeUrl: modernURL)
        
        // Also set legacy value (should be ignored)
        let legacyTestSuiteName = "LegacyTest-\(UUID().uuidString)"
        let legacyUserDefaults = UserDefaults(suiteName: legacyTestSuiteName)!
        legacyUserDefaults.set(0, forKey: UserSettings.StorageKey.legacySelectedShoe)
        
        XCTAssertNotNil(testUserSettings.selectedShoeURL, "Should have modern selection")
        
        strategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        
        // Should not change modern selection
        XCTAssertEqual(testUserSettings.selectedShoeURL, modernURL, "Should preserve existing modern selection")
        
        // Clean up
        legacyUserDefaults.removePersistentDomain(forName: legacyTestSuiteName)
    }
    
    // Given: Legacy selection exists but no active shoes exist
    // When: updateSelectedSelectedShoeStorageFromLegacyIfNeeded() is called
    // Then: Should not set any selection when no active shoes exist
    func testLegacyMigrationWithNoActiveShoes() throws {
        // Ensure no active shoes
        XCTAssertEqual(shoeStore.activeShoes.count, 0, "Should have no active shoes")
        
        // Set legacy value
        let legacyTestSuiteName = "LegacyTest-\(UUID().uuidString)"
        let legacyUserDefaults = UserDefaults(suiteName: legacyTestSuiteName)!
        legacyUserDefaults.set(0, forKey: UserSettings.StorageKey.legacySelectedShoe)
        
        strategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        
        // Should not set any selection when no shoes exist
        XCTAssertNil(testUserSettings.selectedShoeURL, "Should not set selection when no active shoes")
        
        // Clean up
        legacyUserDefaults.removePersistentDomain(forName: legacyTestSuiteName)
    }
    
    // MARK: - selectFirstActiveShoe() Integration Tests
    
    // Given: Multiple shoes with explicit ordering values and no selection
    // When: updateSelectedShoe() is called
    // Then: Should select the first shoe based on ordering value
    func testSelectFirstActiveShoeOrdering() throws {
        // Create multiple shoes with explicit ordering
        let shoe1 = createTestShoe()
        shoe1.brand = "Should Be First"
        shoe1.orderingValue = NSNumber(value: 1.0)
        
        let shoe2 = createTestShoe()
        shoe2.brand = "Should Be Second"
        shoe2.orderingValue = NSNumber(value: 2.0)
        
        let shoe3 = createTestShoe()
        shoe3.brand = "Should Be Third"
        shoe3.orderingValue = NSNumber(value: 3.0)
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Ensure no selection
        testUserSettings.setSelected(shoeUrl: nil)
        
        strategy.updateSelectedShoe()
        
        // Should select the first shoe based on ShoeStore's activeShoes ordering
        let selectedShoe = shoeStore.getShoe(from: testUserSettings.selectedShoeURL)
        XCTAssertNotNil(selectedShoe, "Should have selected a shoe")
        XCTAssertEqual(selectedShoe?.brand, "Should Be First", "Should select first shoe in ordering")
    }
    
    // MARK: - Complex Scenario Tests
    
    // Given: Legacy system with index 1, multiple shoes, then retirement scenario
    // When: Legacy migration, selection update, shoe retirement, and selection update occur
    // Then: Should migrate correctly, maintain selection, then fallback after retirement
    func testCompleteWorkflowFromLegacyToModern() throws {
        // Set up legacy environment
        let workflowTestSuiteName = "WorkflowTest-\(UUID().uuidString)"
        let workflowUserDefaults = UserDefaults(suiteName: workflowTestSuiteName)!
        workflowUserDefaults.set(1, forKey: UserSettings.StorageKey.legacySelectedShoe)
        
        let workflowUserSettings = UserSettings(userDefaults: workflowUserDefaults)
        let workflowShoeStore = ShoeStore(context: testContext, userSettings: workflowUserSettings)
        let workflowStrategy = SelectedShoeStrategy(store: workflowShoeStore, settings: workflowUserSettings)
        
        // Create shoes
        let shoe1 = createTestShoe()
        shoe1.brand = "Legacy Index 0"
        let shoe2 = createTestShoe()
        shoe2.brand = "Legacy Index 1"
        let shoe3 = createTestShoe()
        shoe3.brand = "Legacy Index 2"
        
        workflowShoeStore.saveContext()
        workflowShoeStore.updateAllShoes()
        
        // Step 1: Migrate from legacy
        workflowStrategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        let migratedURL = shoe2.objectID.uriRepresentation()
        XCTAssertEqual(workflowUserSettings.selectedShoeURL, migratedURL, "Should migrate to shoe at index 1")
        
        // Step 2: Update selection (should maintain current valid selection)
        workflowStrategy.updateSelectedShoe()
        XCTAssertEqual(workflowUserSettings.selectedShoeURL, migratedURL, "Should maintain migrated selection")
        
        // Step 3: Retire the selected shoe
        shoe2.hallOfFame = true
        workflowShoeStore.saveContext()
        workflowShoeStore.updateAllShoes()
        
        // Step 4: Update selection after retirement
        workflowStrategy.updateSelectedShoe()
        let fallbackURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(workflowUserSettings.selectedShoeURL, fallbackURL, "Should fallback to first active shoe")
        
        // Clean up
        workflowUserDefaults.removePersistentDomain(forName: workflowTestSuiteName)
    }
    
    // Given: Initial shoe selection, then shoes are added and removed
    // When: Selection updates occur after each change
    // Then: Should maintain selection during additions, clear when all removed
    func testStrategyWithDynamicShoeChanges() throws {
        let shoe1 = createTestShoe()
        shoe1.brand = "Original Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Initial selection
        strategy.updateSelectedShoe()
        let originalURL = shoe1.objectID.uriRepresentation()
        XCTAssertEqual(testUserSettings.selectedShoeURL, originalURL, "Should select initial shoe")
        
        // Add more shoes
        let shoe2 = createTestShoe()
        shoe2.brand = "Added Shoe"
        
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Update should maintain original selection
        strategy.updateSelectedShoe()
        XCTAssertEqual(testUserSettings.selectedShoeURL, originalURL, "Should maintain selection when shoes are added")
        
        // Remove all shoes
        shoe1.hallOfFame = true
        shoe2.hallOfFame = true
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Should clear selection
        strategy.updateSelectedShoe()
        XCTAssertNil(testUserSettings.selectedShoeURL, "Should clear selection when all shoes are removed")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    // Given: One active shoe exists and a corrupted URL is set as selection
    // When: updateSelectedShoe() is called
    // Then: Should handle corrupted URLs gracefully and fallback to first active shoe
    func testStrategyWithCorruptedURLs() throws {
        let shoe = createTestShoe()
        shoeStore.saveContext()
        shoeStore.updateAllShoes()
        
        // Set corrupted URL that doesn't match any shoe
        let corruptedURL = URL(string: "x-coredata://corrupted/Shoe/invalid")!
        testUserSettings.setSelected(shoeUrl: corruptedURL)
        
        strategy.updateSelectedShoe()
        
        // Should fallback to first active shoe
        let expectedURL = shoe.objectID.uriRepresentation()
        XCTAssertEqual(testUserSettings.selectedShoeURL, expectedURL, "Should handle corrupted URLs gracefully")
    }
    
    // Given: Legacy system has negative index (-1) and one shoe exists
    // When: updateSelectedSelectedShoeStorageFromLegacyIfNeeded() is called
    // Then: Should handle negative legacy indices and fallback to first shoe
    func testStrategyWithNegativeLegacyIndex() throws {
        let legacyTestSuiteName = "NegativeLegacyTest-\(UUID().uuidString)"
        let legacyUserDefaults = UserDefaults(suiteName: legacyTestSuiteName)!
        legacyUserDefaults.set(-1, forKey: UserSettings.StorageKey.legacySelectedShoe)
        
        let legacyUserSettings = UserSettings(userDefaults: legacyUserDefaults)
        let legacyShoeStore = ShoeStore(context: testContext, userSettings: legacyUserSettings)
        let legacyStrategy = SelectedShoeStrategy(store: legacyShoeStore, settings: legacyUserSettings)
        
        let shoe = createTestShoe()
        legacyShoeStore.saveContext()
        legacyShoeStore.updateAllShoes()
        
        legacyStrategy.updateSelectedSelectedShoeStorageFromLegacyIfNeeded()
        
        // Should fallback to first shoe for negative index
        let expectedURL = shoe.objectID.uriRepresentation()
        XCTAssertEqual(legacyUserSettings.selectedShoeURL, expectedURL, "Should handle negative legacy indices")
        
        // Clean up
        legacyUserDefaults.removePersistentDomain(forName: legacyTestSuiteName)
    }
}
