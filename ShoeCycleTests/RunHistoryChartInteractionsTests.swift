//  RunHistoryChartInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import XCTest
@testable import ShoeCycle

final class RunHistoryChartInteractionsTests: XCTestCase {
    
    // MARK: - RunHistoryChartState Tests
    
    // Given: Default initializer
    // When: Creating RunHistoryChartState without parameters
    // Then: Should initialize with default values
    func testRunHistoryChartStateDefaultInitialization() {
        let state = RunHistoryChartState()
        
        XCTAssertEqual(state.graphAllShoes, false)
        XCTAssertEqual(state.maxDistance, 0.0)
        XCTAssertEqual(state.xValues, [])
        XCTAssertEqual(state.chartData, [])
    }
    
    // MARK: - RunHistoryChartInteractor Tests
    
    // Convenience function to create isolated test UserSettings
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    // Convenience function to create test weekly collated data
    func createTestWeeklyCollatedData() -> [WeeklyCollatedNew] {
        let date1 = Date(timeIntervalSinceNow: -604800) // 1 week ago
        let date2 = Date(timeIntervalSinceNow: -1209600) // 2 weeks ago
        
        return [
            WeeklyCollatedNew(date: date1, runDistance: 5.0),
            WeeklyCollatedNew(date: date2, runDistance: 3.2)
        ]
    }
    
    // Given: UserSettings with graphAllShoes = true
    // When: Handle viewAppeared action
    // Then: State should sync with user settings
    func testViewAppearedSyncsWithUserSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: true)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.graphAllShoes, true)
    }
    
    // Given: UserSettings with graphAllShoes = false
    // When: Handle viewAppeared action
    // Then: State should sync with user settings
    func testViewAppearedSyncsWithUserSettingsFalse() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: false)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        XCTAssertEqual(state.graphAllShoes, false)
    }
    
    // Given: Empty state and test data
    // When: Handle dataUpdated action with weekly collated data
    // Then: State should update with data, xValues, and maxDistance
    func testDataUpdatedPopulatesStateCorrectly() {
        let testUserSettings = createTestUserSettings()
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        let testData = createTestWeeklyCollatedData()
        
        interactor.handle(state: &state, action: .dataUpdated(testData))
        
        XCTAssertEqual(state.chartData.count, testData.count)
        XCTAssertEqual(state.xValues.count, testData.count)
        XCTAssertEqual(state.maxDistance, 5.0) // Max of 5.0 and 3.2
        
        // Verify xValues contain the correct dates
        XCTAssertEqual(state.xValues[0], testData[0].date)
        XCTAssertEqual(state.xValues[1], testData[1].date)
    }
    
    // Given: Empty weekly collated data
    // When: Handle dataUpdated action with empty array
    // Then: State should be updated with empty arrays and zero maxDistance
    func testDataUpdatedWithEmptyDataClearsState() {
        let testUserSettings = createTestUserSettings()
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        // First populate with data
        let testData = createTestWeeklyCollatedData()
        interactor.handle(state: &state, action: .dataUpdated(testData))
        
        // Then clear with empty data
        interactor.handle(state: &state, action: .dataUpdated([]))
        
        XCTAssertEqual(state.chartData.count, 0)
        XCTAssertEqual(state.xValues.count, 0)
        XCTAssertEqual(state.maxDistance, 0.0)
    }
    
    // Given: Data with various distances
    // When: Handle dataUpdated action with mixed distance values
    // Then: maxDistance should be correctly calculated as the maximum
    func testDataUpdatedCalculatesMaxDistanceCorrectly() {
        let testUserSettings = createTestUserSettings()
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        let testData = [
            WeeklyCollatedNew(date: Date(), runDistance: 3.1),
            WeeklyCollatedNew(date: Date(), runDistance: 10.5),
            WeeklyCollatedNew(date: Date(), runDistance: 2.0),
            WeeklyCollatedNew(date: Date(), runDistance: 7.3)
        ]
        
        interactor.handle(state: &state, action: .dataUpdated(testData))
        
        XCTAssertEqual(state.maxDistance, 10.5)
    }
    
    // Given: State with graphAllShoes = false and UserSettings synced
    // When: Handle toggleGraphAllShoes action
    // Then: State should toggle and UserSettings should be updated
    func testToggleGraphAllShoesUpdatesStateAndSettings() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: false)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        state.graphAllShoes = false
        
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        
        XCTAssertEqual(state.graphAllShoes, true)
        XCTAssertEqual(testUserSettings.graphAllShoes, true)
    }
    
    // Given: State with graphAllShoes = true and UserSettings synced
    // When: Handle toggleGraphAllShoes action
    // Then: State should toggle to false and UserSettings should be updated
    func testToggleGraphAllShoesFromTrueToFalse() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: true)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        state.graphAllShoes = true
        
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        
        XCTAssertEqual(state.graphAllShoes, false)
        XCTAssertEqual(testUserSettings.graphAllShoes, false)
    }
    
    // Given: Multiple consecutive toggle actions
    // When: Handle toggleGraphAllShoes multiple times
    // Then: Should correctly alternate and keep UserSettings in sync
    func testMultipleTogglesAlternateCorrectly() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: false)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        state.graphAllShoes = false
        
        // First toggle: false -> true
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        XCTAssertEqual(state.graphAllShoes, true)
        XCTAssertEqual(testUserSettings.graphAllShoes, true)
        
        // Second toggle: true -> false
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        XCTAssertEqual(state.graphAllShoes, false)
        XCTAssertEqual(testUserSettings.graphAllShoes, false)
        
        // Third toggle: false -> true
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        XCTAssertEqual(state.graphAllShoes, true)
        XCTAssertEqual(testUserSettings.graphAllShoes, true)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Complete workflow from viewAppeared to data updates and toggles
    // Then: Should properly handle the complete flow
    func testCompleteWorkflow() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: false)
        
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertEqual(state.graphAllShoes, false)
        
        // Simulate data being loaded
        let testData = createTestWeeklyCollatedData()
        interactor.handle(state: &state, action: .dataUpdated(testData))
        XCTAssertEqual(state.chartData.count, 2)
        XCTAssertEqual(state.maxDistance, 5.0)
        
        // Simulate user toggling graph all shoes
        interactor.handle(state: &state, action: .toggleGraphAllShoes)
        XCTAssertEqual(state.graphAllShoes, true)
        XCTAssertEqual(testUserSettings.graphAllShoes, true)
        
        // Simulate new data being loaded (after toggle)
        let newTestData = [WeeklyCollatedNew(date: Date(), runDistance: 15.0)]
        interactor.handle(state: &state, action: .dataUpdated(newTestData))
        XCTAssertEqual(state.chartData.count, 1)
        XCTAssertEqual(state.maxDistance, 15.0)
    }
    
    // MARK: - Edge Cases
    
    // Given: Data with zero distances
    // When: Handle dataUpdated action with all zero distances
    // Then: maxDistance should be 0.0
    func testDataUpdatedWithZeroDistances() {
        let testUserSettings = createTestUserSettings()
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        let testData = [
            WeeklyCollatedNew(date: Date(), runDistance: 0.0),
            WeeklyCollatedNew(date: Date(), runDistance: 0.0)
        ]
        
        interactor.handle(state: &state, action: .dataUpdated(testData))
        
        XCTAssertEqual(state.maxDistance, 0.0)
        XCTAssertEqual(state.chartData.count, 2)
    }
    
    // Given: Data with negative distances (edge case)
    // When: Handle dataUpdated action with negative values
    // Then: Should handle gracefully and calculate max correctly
    func testDataUpdatedWithNegativeDistances() {
        let testUserSettings = createTestUserSettings()
        let interactor = RunHistoryChartInteractor(userSettings: testUserSettings)
        var state = RunHistoryChartState()
        
        let testData = [
            WeeklyCollatedNew(date: Date(), runDistance: -1.0),
            WeeklyCollatedNew(date: Date(), runDistance: 5.0),
            WeeklyCollatedNew(date: Date(), runDistance: -2.0)
        ]
        
        interactor.handle(state: &state, action: .dataUpdated(testData))
        
        XCTAssertEqual(state.maxDistance, 5.0) // Should be max of all values
        XCTAssertEqual(state.chartData.count, 3)
    }
}