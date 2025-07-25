//  SettingsFirstDayOfWeekInteractorTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/25/25.
//  
//

import XCTest
@testable import ShoeCycle

final class SettingsFirstDayOfWeekInteractorTests: XCTestCase {
    
    // MARK: - SettingsFirstDayOfWeekState Tests
    
    // Given: Default initializer
    // When: Creating SettingsFirstDayOfWeekState without parameters
    // Then: Should initialize with sunday as default
    func testSettingsFirstDayOfWeekStateDefaultInitialization() {
        let state = SettingsFirstDayOfWeekState()
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .sunday)
    }
    
    // Given: Specific first day provided
    // When: Creating SettingsFirstDayOfWeekState with monday
    // Then: Should initialize with the provided first day
    func testSettingsFirstDayOfWeekStateCustomInitialization() {
        let state = SettingsFirstDayOfWeekState(selectedFirstDayOfWeek: .monday)
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .monday)
    }
    
    // MARK: - SettingsFirstDayOfWeekInteractor Tests
    
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
        testUserSettings.set(firstDayOfWeek: .monday)
        let interactor = SettingsFirstDayOfWeekInteractor(userSettings: testUserSettings)
        
        var state = SettingsFirstDayOfWeekState(selectedFirstDayOfWeek: .sunday)
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .monday)
    }
    
    // Given: State with sunday and user settings with sunday
    // When: Handle firstDayOfWeekChanged action with monday
    // Then: State should update and settings should be saved
    func testFirstDayOfWeekChangedUpdatesStateAndSavesToSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(firstDayOfWeek: .sunday)
        let interactor = SettingsFirstDayOfWeekInteractor(userSettings: testUserSettings)
        
        var state = SettingsFirstDayOfWeekState(selectedFirstDayOfWeek: .sunday)
        
        interactor.handle(state: &state, action: .firstDayOfWeekChanged(.monday))
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .monday)
        XCTAssertEqual(testUserSettings.firstDayOfWeek, .monday)
    }
    
    // Given: State with monday
    // When: Handle firstDayOfWeekChanged action with sunday
    // Then: Should update state and save to settings
    func testFirstDayOfWeekChangedFromMondayToSunday() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(firstDayOfWeek: .monday)
        let interactor = SettingsFirstDayOfWeekInteractor(userSettings: testUserSettings)
        
        var state = SettingsFirstDayOfWeekState(selectedFirstDayOfWeek: .monday)
        
        interactor.handle(state: &state, action: .firstDayOfWeekChanged(.sunday))
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .sunday)
        XCTAssertEqual(testUserSettings.firstDayOfWeek, .sunday)
    }
    
    // Given: State already has the target first day
    // When: Handle firstDayOfWeekChanged action with same first day
    // Then: Should update state and call settings save
    func testFirstDayOfWeekChangedWithSameFirstDayStillUpdatesSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(firstDayOfWeek: .monday)
        let interactor = SettingsFirstDayOfWeekInteractor(userSettings: testUserSettings)
        
        var state = SettingsFirstDayOfWeekState(selectedFirstDayOfWeek: .monday)
        
        interactor.handle(state: &state, action: .firstDayOfWeekChanged(.monday))
        
        XCTAssertEqual(state.selectedFirstDayOfWeek, .monday)
        XCTAssertEqual(testUserSettings.firstDayOfWeek, .monday)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Full workflow from viewAppeared to firstDayOfWeekChanged
    // Then: Should properly sync and update through complete flow
    func testCompleteWorkflow() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(firstDayOfWeek: .sunday)
        let interactor = SettingsFirstDayOfWeekInteractor(userSettings: testUserSettings)
        
        var state = SettingsFirstDayOfWeekState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertEqual(state.selectedFirstDayOfWeek, .sunday)
        
        // Simulate user changing first day
        interactor.handle(state: &state, action: .firstDayOfWeekChanged(.monday))
        XCTAssertEqual(state.selectedFirstDayOfWeek, .monday)
        XCTAssertEqual(testUserSettings.firstDayOfWeek, .monday)
    }
    
}