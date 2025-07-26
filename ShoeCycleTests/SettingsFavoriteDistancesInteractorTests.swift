//  SettingsFavoriteDistancesInteractorTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/25/25.
//  
//

import XCTest
@testable import ShoeCycle

final class SettingsFavoriteDistancesInteractorTests: XCTestCase {
    
    // MARK: - SettingsFavoriteDistancesState Tests
    
    // Given: Default initializer
    // When: Creating SettingsFavoriteDistancesState without parameters
    // Then: Should initialize with empty strings for all favorites
    func testSettingsFavoriteDistancesStateDefaultInitialization() {
        let state = SettingsFavoriteDistancesState()
        
        XCTAssertEqual(state.favorite1Text, "")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "")
        XCTAssertEqual(state.favorite4Text, "")
    }
    
    // Given: Specific values provided
    // When: Creating SettingsFavoriteDistancesState with custom values
    // Then: Should initialize with the provided values
    func testSettingsFavoriteDistancesStateCustomInitialization() {
        let state = SettingsFavoriteDistancesState(
            favorite1Text: "5.0",
            favorite2Text: "10.0",
            favorite3Text: "13.1",
            favorite4Text: "26.2"
        )
        
        XCTAssertEqual(state.favorite1Text, "5.0")
        XCTAssertEqual(state.favorite2Text, "10.0")
        XCTAssertEqual(state.favorite3Text, "13.1")
        XCTAssertEqual(state.favorite4Text, "26.2")
    }
    
    // MARK: - SettingsFavoriteDistancesInteractor Tests
    
    // Convenience functions to create isolated test dependencies
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    func createTestDistanceUtility() -> DistanceUtility {
        return DistanceUtility()
    }
    
    // Given: Interactor initialized with test settings having favorite distances
    // When: Handle viewAppeared action
    // Then: State should sync with current user settings via DistanceUtility
    func testViewAppearedSyncsStateWithUserSettings() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        testUserSettings.favorite1 = 5.0
        testUserSettings.favorite2 = 10.0
        testUserSettings.favorite3 = 13.1
        testUserSettings.favorite4 = 26.2
        
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.favorite1Text, "5")
        XCTAssertEqual(state.favorite2Text, "10")
        XCTAssertEqual(state.favorite3Text, "13.1")
        XCTAssertEqual(state.favorite4Text, "26.2")
    }
    
    // Given: State with empty values and user settings with zero favorites
    // When: Handle viewAppeared action
    // Then: State should remain empty (favoriteDistanceDisplayString returns "" for 0)
    func testViewAppearedWithZeroFavoritesReturnsEmptyStrings() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        testUserSettings.favorite1 = 0.0
        testUserSettings.favorite2 = 0.0
        testUserSettings.favorite3 = 0.0
        testUserSettings.favorite4 = 0.0
        
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.favorite1Text, "")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "")
        XCTAssertEqual(state.favorite4Text, "")
    }
    
    // Given: State with initial values
    // When: Handle favorite1Changed action
    // Then: State should update and save to UserSettings immediately
    func testFavorite1ChangedUpdatesStateAndSavesImmediately() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .favorite1Changed("5.5"))
        
        XCTAssertEqual(state.favorite1Text, "5.5")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "")
        XCTAssertEqual(state.favorite4Text, "")
        XCTAssertEqual(testUserSettings.favorite1, 5.5, accuracy: 0.01)
    }
    
    // Given: State with initial values
    // When: Handle favorite2Changed action
    // Then: State should update and save to UserSettings immediately
    func testFavorite2ChangedUpdatesStateAndSavesImmediately() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .favorite2Changed("10.5"))
        
        XCTAssertEqual(state.favorite1Text, "")
        XCTAssertEqual(state.favorite2Text, "10.5")
        XCTAssertEqual(state.favorite3Text, "")
        XCTAssertEqual(state.favorite4Text, "")
        XCTAssertEqual(testUserSettings.favorite2, 10.5, accuracy: 0.01)
    }
    
    // Given: State with initial values
    // When: Handle favorite3Changed action
    // Then: State should update and save to UserSettings immediately
    func testFavorite3ChangedUpdatesStateAndSavesImmediately() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .favorite3Changed("13.1"))
        
        XCTAssertEqual(state.favorite1Text, "")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "13.1")
        XCTAssertEqual(state.favorite4Text, "")
        XCTAssertEqual(testUserSettings.favorite3, 13.1, accuracy: 0.01)
    }
    
    // Given: State with initial values
    // When: Handle favorite4Changed action
    // Then: State should update and save to UserSettings immediately
    func testFavorite4ChangedUpdatesStateAndSavesImmediately() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .favorite4Changed("26.2"))
        
        XCTAssertEqual(state.favorite1Text, "")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "")
        XCTAssertEqual(state.favorite4Text, "26.2")
        XCTAssertEqual(testUserSettings.favorite4, 26.2, accuracy: 0.01)
    }
    
    // Given: State with invalid text values
    // When: Handle favorite changes with invalid strings
    // Then: Should save zero values for invalid strings immediately
    func testFavoriteChangedWithInvalidStringsStoresZero() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        interactor.handle(state: &state, action: .favorite1Changed("invalid"))
        interactor.handle(state: &state, action: .favorite2Changed("abc"))
        interactor.handle(state: &state, action: .favorite3Changed(""))
        interactor.handle(state: &state, action: .favorite4Changed("not_a_number"))
        
        XCTAssertEqual(testUserSettings.favorite1, 0.0, accuracy: 0.01)
        XCTAssertEqual(testUserSettings.favorite2, 0.0, accuracy: 0.01)
        XCTAssertEqual(testUserSettings.favorite3, 0.0, accuracy: 0.01)
        XCTAssertEqual(testUserSettings.favorite4, 0.0, accuracy: 0.01)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Full workflow from viewAppeared to text changes
    // Then: Should properly sync and save immediately through complete flow
    func testCompleteWorkflow() {
        let testUserSettings = createTestUserSettings()
        let testDistanceUtility = createTestDistanceUtility()
        testUserSettings.favorite1 = 5.0
        testUserSettings.favorite2 = 0.0
        testUserSettings.favorite3 = 13.1
        testUserSettings.favorite4 = 0.0
        
        let interactor = SettingsFavoriteDistancesInteractor(
            userSettings: testUserSettings,
            distanceUtility: testDistanceUtility
        )
        
        var state = SettingsFavoriteDistancesState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertEqual(state.favorite1Text, "5")
        XCTAssertEqual(state.favorite2Text, "")
        XCTAssertEqual(state.favorite3Text, "13.1")
        XCTAssertEqual(state.favorite4Text, "")
        
        // Simulate user changing favorite2 - should save immediately
        interactor.handle(state: &state, action: .favorite2Changed("10.0"))
        XCTAssertEqual(state.favorite2Text, "10.0")
        XCTAssertEqual(testUserSettings.favorite2, 10.0, accuracy: 0.01)
        
        // Verify all settings are correct
        XCTAssertEqual(testUserSettings.favorite1, 5.0, accuracy: 0.01)
        XCTAssertEqual(testUserSettings.favorite3, 13.1, accuracy: 0.01)
        XCTAssertEqual(testUserSettings.favorite4, 0.0, accuracy: 0.01)
    }
}