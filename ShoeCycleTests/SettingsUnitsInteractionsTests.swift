//  SettingsUnitsInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/23/25.
//  
//

import XCTest
@testable import ShoeCycle

final class SettingsUnitsInteractionsTests: XCTestCase {
    
    // MARK: - SettingsUnitsState Tests
    
    // Given: Default initializer
    // When: Creating SettingsUnitsState without parameters
    // Then: Should initialize with miles as default unit
    func testSettingsUnitsStateDefaultInitialization() {
        let state = SettingsUnitsState()
        
        XCTAssertEqual(state.selectedUnit, .miles)
    }
    
    // Given: Specific unit provided
    // When: Creating SettingsUnitsState with km unit
    // Then: Should initialize with the provided unit
    func testSettingsUnitsStateCustomInitialization() {
        let state = SettingsUnitsState(selectedUnit: .km)
        
        XCTAssertEqual(state.selectedUnit, .km)
    }
    
    // MARK: - SettingsUnitsInteractor Tests
    
    // Convenience function to create isolated test UserSettings
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    // Given: Interactor initialized with test settings
    // When: Handle viewAppeared action
    // Then: State should sync with current user settings
    func testViewAppearedSyncsStateWithUserSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(distanceUnit: .km)
        let interactor = SettingsUnitsInteractor(userSettings: testUserSettings)
        
        var state = SettingsUnitsState(selectedUnit: .miles)
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.selectedUnit, .km)
    }
    
    // Given: State with miles unit and user settings with miles
    // When: Handle unitChanged action with km
    // Then: State should update and settings should be saved
    func testUnitChangedUpdatesStateAndSavesToSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(distanceUnit: .miles)
        let interactor = SettingsUnitsInteractor(userSettings: testUserSettings)
        
        var state = SettingsUnitsState(selectedUnit: .miles)
        
        interactor.handle(state: &state, action: .unitChanged(.km))
        
        XCTAssertEqual(state.selectedUnit, .km)
        XCTAssertEqual(testUserSettings.distanceUnit, .km)
    }
    
    // Given: State already has the target unit
    // When: Handle unitChanged action with same unit
    // Then: Should early return without calling settings save
    func testUnitChangedWithSameUnitDoesNotSaveSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(distanceUnit: .km)
        let initialValue = testUserSettings.distanceUnit
        let interactor = SettingsUnitsInteractor(userSettings: testUserSettings)
        
        var state = SettingsUnitsState(selectedUnit: .km)
        
        interactor.handle(state: &state, action: .unitChanged(.km))
        
        XCTAssertEqual(state.selectedUnit, .km)
        XCTAssertEqual(testUserSettings.distanceUnit, initialValue)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Full workflow from viewAppeared to unitChanged
    // Then: Should properly sync and update through complete flow
    func testCompleteWorkflow() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(distanceUnit: .miles)
        let interactor = SettingsUnitsInteractor(userSettings: testUserSettings)
        
        var state = SettingsUnitsState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertEqual(state.selectedUnit, .miles)
        
        // Simulate user changing unit
        interactor.handle(state: &state, action: .unitChanged(.km))
        XCTAssertEqual(state.selectedUnit, .km)
        XCTAssertEqual(testUserSettings.distanceUnit, .km)
    }
}
