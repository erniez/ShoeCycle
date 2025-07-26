//  FavoriteDistancesInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import XCTest
@testable import ShoeCycle

final class FavoriteDistancesInteractionsTests: XCTestCase {
    
    // MARK: - FavoriteDistancesState Tests
    
    // Given: Default initializer
    // When: Creating FavoriteDistancesState without parameters
    // Then: Should initialize with default values
    func testFavoriteDistancesStateDefaultInitialization() {
        let state = FavoriteDistancesState()
        
        XCTAssertEqual(state.distanceToAdd, 0.0)
        XCTAssertNil(state.favorite1DisplayString)
        XCTAssertNil(state.favorite2DisplayString)
        XCTAssertNil(state.favorite3DisplayString)
        XCTAssertNil(state.favorite4DisplayString)
    }
    
    // MARK: - FavoriteDistancesInteractor Tests
    
    // Convenience function to create isolated test UserSettings
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    // Given: UserSettings with configured favorite distances
    // When: Handle viewAppeared action
    // Then: State should populate display strings for all favorites
    func testViewAppearedPopulatesDisplayStrings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.favorite1 = 3.1
        testUserSettings.favorite2 = 5.0
        testUserSettings.favorite3 = 10.0
        testUserSettings.favorite4 = 13.1
        
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertNotNil(state.favorite1DisplayString)
        XCTAssertNotNil(state.favorite2DisplayString)
        XCTAssertNotNil(state.favorite3DisplayString)
        XCTAssertNotNil(state.favorite4DisplayString)
        
        // Verify content of display strings
        XCTAssertTrue(state.favorite1DisplayString?.contains("3.1") == true)
        XCTAssertTrue(state.favorite2DisplayString?.contains("5") == true)
        XCTAssertTrue(state.favorite3DisplayString?.contains("10") == true)
        XCTAssertTrue(state.favorite4DisplayString?.contains("13.1") == true)
    }
    
    // Given: UserSettings with zero/empty favorite distances
    // When: Handle viewAppeared action
    // Then: State should have nil display strings for empty favorites
    func testViewAppearedWithEmptyFavoritesShowsNilDisplayStrings() {
        let testUserSettings = createTestUserSettings()
        // Default favorites are 0, which should result in nil display strings
        
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertNil(state.favorite1DisplayString)
        XCTAssertNil(state.favorite2DisplayString)
        XCTAssertNil(state.favorite3DisplayString)
        XCTAssertNil(state.favorite4DisplayString)
    }
    
    // Given: State with distanceToAdd = 0
    // When: Handle distanceSelected action with specific distance
    // Then: State distanceToAdd should be updated
    func testDistanceSelectedUpdatesState() {
        let testUserSettings = createTestUserSettings()
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        let selectedDistance = 5.5
        
        interactor.handle(state: &state, action: .distanceSelected(selectedDistance))
        
        XCTAssertEqual(state.distanceToAdd, selectedDistance)
    }
    
    // Given: State with distanceToAdd = 5.0
    // When: Handle cancelPressed action
    // Then: State distanceToAdd should be reset to 0
    func testCancelPressedResetsDistanceToAdd() {
        let testUserSettings = createTestUserSettings()
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        state.distanceToAdd = 5.0
        
        interactor.handle(state: &state, action: .cancelPressed)
        
        XCTAssertEqual(state.distanceToAdd, 0.0)
    }
    
    // Given: UserSettings with mixed favorite distances (some set, some zero)
    // When: Handle viewAppeared action
    // Then: Only non-zero favorites should have display strings
    func testViewAppearedWithMixedFavoritesShowsCorrectDisplayStrings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.favorite1 = 3.1  // Set
        testUserSettings.favorite2 = 0.0  // Empty
        testUserSettings.favorite3 = 10.0 // Set
        testUserSettings.favorite4 = 0.0  // Empty
        
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertNotNil(state.favorite1DisplayString)
        XCTAssertNil(state.favorite2DisplayString)
        XCTAssertNotNil(state.favorite3DisplayString)
        XCTAssertNil(state.favorite4DisplayString)
    }
    
    // Given: Multiple distance selections
    // When: Handle distanceSelected actions with different values
    // Then: State should always reflect the most recent selection
    func testMultipleDistanceSelectionsUpdateCorrectly() {
        let testUserSettings = createTestUserSettings()
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        // First selection
        interactor.handle(state: &state, action: .distanceSelected(3.1))
        XCTAssertEqual(state.distanceToAdd, 3.1)
        
        // Second selection
        interactor.handle(state: &state, action: .distanceSelected(5.0))
        XCTAssertEqual(state.distanceToAdd, 5.0)
        
        // Third selection
        interactor.handle(state: &state, action: .distanceSelected(10.0))
        XCTAssertEqual(state.distanceToAdd, 10.0)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Complete workflow from viewAppeared to distance selection
    // Then: Should properly handle the complete flow
    func testCompleteWorkflow() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.favorite1 = 3.1
        testUserSettings.favorite2 = 5.0
        
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertNotNil(state.favorite1DisplayString)
        XCTAssertNotNil(state.favorite2DisplayString)
        XCTAssertEqual(state.distanceToAdd, 0.0)
        
        // Simulate user selecting a distance
        interactor.handle(state: &state, action: .distanceSelected(3.1))
        XCTAssertEqual(state.distanceToAdd, 3.1)
        
        // Simulate user canceling
        interactor.handle(state: &state, action: .cancelPressed)
        XCTAssertEqual(state.distanceToAdd, 0.0)
        
        // Simulate user selecting again
        interactor.handle(state: &state, action: .distanceSelected(5.0))
        XCTAssertEqual(state.distanceToAdd, 5.0)
    }
    
    // MARK: - Edge Cases
    
    // Given: UserSettings with extremely large favorite distance values
    // When: Handle viewAppeared action
    // Then: Should handle large values gracefully
    func testViewAppearedWithLargeFavoriteValues() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.favorite1 = 999999.99
        
        let interactor = FavoriteDistancesInteractor(userSettings: testUserSettings)
        var state = FavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertNotNil(state.favorite1DisplayString)
        // Should not crash and should produce some display string
        XCTAssertTrue(state.favorite1DisplayString!.count > 0)
    }
}