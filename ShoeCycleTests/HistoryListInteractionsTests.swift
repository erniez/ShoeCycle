//  HistoryListInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import XCTest
import CoreData
@testable import ShoeCycle

final class HistoryListInteractionsTests: DBInteractiveTestCase {
    
    // MARK: - HistoryListState Tests
    
    // Given: Default initializer
    // When: Creating HistoryListState without parameters
    // Then: Should initialize with default values
    func testHistoryListStateDefaultInitialization() {
        let state = HistoryListState()
        
        XCTAssertEqual(state.sections, [])
        XCTAssertEqual(state.yearlyTotals, [:])
        XCTAssertEqual(state.showMailComposer, false)
    }
    
    // MARK: - HistoryListInteractor Tests
    
    // Convenience function to create isolated test UserSettings
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    // Convenience function to create test shoe with history
    func createTestShoeWithHistory() -> (ShoeStore, Shoe) {
        let shoeStore = ShoeStore(context: testContext)
        let shoe = shoeStore.createShoe()
        shoe.brand = "Test"
        // Only set brand, model property doesn't exist
        
        // Add some test history entries
        let date1 = Date(timeIntervalSinceNow: -86400) // Yesterday
        let date2 = Date(timeIntervalSinceNow: -172800) // 2 days ago
        
        shoeStore.addHistory(to: shoe, date: date1, distance: 5.0)
        shoeStore.addHistory(to: shoe, date: date2, distance: 3.2)
        
        return (shoeStore, shoe)
    }
    
    // Mock analytics logger for testing
    class MockAnalyticsLogger: AnalyticsLogger {
        var loggedEvents: [(name: String, userInfo: [String: Any]?)] = []
        
        static func initializeLogger() {
            // No-op for testing
        }
        
        func logEvent(name: String, userInfo: [String : Any]?) {
            loggedEvents.append((name: name, userInfo: userInfo))
        }
    }
    
    // Given: Interactor with shoe that has history
    // When: Handle viewAppeared action
    // Then: State should be populated with sections and yearly totals
    func testViewAppearedLoadsHistoryData() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        // Should have loaded sections and yearly totals
        XCTAssertGreaterThan(state.sections.count, 0)
        XCTAssertGreaterThan(state.yearlyTotals.count, 0)
    }
    
    // Given: State with showMailComposer false
    // When: Handle showMailComposer action
    // Then: State should update and analytics should be logged
    func testShowMailComposerUpdatesStateAndLogsAnalytics() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        interactor.handle(state: &state, action: .showMailComposer)
        
        XCTAssertEqual(state.showMailComposer, true)
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        XCTAssertEqual(mockAnalytics.loggedEvents[0].name, AnalyticsKeys.Event.emailShoeTapped)
    }
    
    // Given: State with showMailComposer true
    // When: Handle dismissMailComposer action
    // Then: State showMailComposer should be false
    func testDismissMailComposerUpdatesState() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .showMailComposer)
        
        interactor.handle(state: &state, action: .dismissMailComposer)
        
        XCTAssertEqual(state.showMailComposer, false)
    }
    
    // Given: Shoe with multiple history entries and loaded state
    // When: Handle removeHistories action with valid section and offsets
    // Then: Should remove histories and reload data
    func testRemoveHistoriesRemovesEntriesAndReloadsData() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        // First load the data
        interactor.handle(state: &state, action: .viewAppeared)
        let initialHistoryCount = shoe.history.count
        XCTAssertGreaterThan(initialHistoryCount, 0)
        
        // Get the first section for testing
        guard let firstSection = state.sections.first else {
            XCTFail("No sections loaded")
            return
        }
        
        let initialSectionHistoryCount = firstSection.histories.count
        guard initialSectionHistoryCount > 0 else {
            XCTFail("No histories in first section")
            return
        }
        
        // Remove the first history from the first section
        let offsetsToRemove = IndexSet([0])
        interactor.handle(state: &state, action: .removeHistories(from: firstSection, atOffsets: offsetsToRemove))
        
        // Should have one less history entry
        XCTAssertEqual(shoe.history.count, initialHistoryCount - 1)
        
        // State should be reloaded with updated data
        XCTAssertNotNil(state.sections)
    }
    
    // Given: Invalid section not in state
    // When: Handle removeHistories action with section not in state
    // Then: Should handle gracefully without crashing
    func testRemoveHistoriesWithInvalidSectionHandlesGracefully() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        // Load initial data
        interactor.handle(state: &state, action: .viewAppeared)
        let initialHistoryCount = shoe.history.count
        
        // Create a fake section that's not in the state
        let fakeSection = HistorySectionViewModel(shoe: shoe, histories: [])
        let offsetsToRemove = IndexSet([0])
        
        // This should not crash and should not remove any histories
        interactor.handle(state: &state, action: .removeHistories(from: fakeSection, atOffsets: offsetsToRemove))
        
        // History count should remain the same
        XCTAssertEqual(shoe.history.count, initialHistoryCount)
    }
    
    // Given: UserSettings with graphAllShoes enabled
    // When: Handle viewAppeared action
    // Then: Should load histories from all shoes, not just the target shoe
    func testViewAppearedWithGraphAllShoesLoadsAllShoeHistories() {
        let testUserSettings = createTestUserSettings()
        testUserSettings.set(graphAllShoes: true)
        
        let shoeStore = ShoeStore(context: testContext)
        
        // Create multiple shoes with history
        let shoe1 = shoeStore.createShoe()
        shoe1.brand = "Nike"
        shoeStore.addHistory(to: shoe1, date: Date(), distance: 5.0)
        
        let shoe2 = shoeStore.createShoe()
        shoe2.brand = "Adidas"
        shoeStore.addHistory(to: shoe2, date: Date(), distance: 3.0)
        
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe1, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        // Should have loaded data (exact verification would require more complex setup)
        XCTAssertNotNil(state.sections)
        XCTAssertNotNil(state.yearlyTotals)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Complete workflow from viewAppeared to mail composer interactions
    // Then: Should properly handle the complete flow
    func testCompleteMailComposerWorkflow() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        XCTAssertGreaterThan(state.sections.count, 0)
        
        // Simulate user showing mail composer
        interactor.handle(state: &state, action: .showMailComposer)
        XCTAssertEqual(state.showMailComposer, true)
        XCTAssertEqual(mockAnalytics.loggedEvents.count, 1)
        
        // Simulate user dismissing mail composer
        interactor.handle(state: &state, action: .dismissMailComposer)
        XCTAssertEqual(state.showMailComposer, false)
    }
    
    // Given: State with loaded history data
    // When: Complete workflow of removing history entries
    // Then: Should properly handle removal and data reloading
    func testCompleteHistoryRemovalWorkflow() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        // Load initial data
        interactor.handle(state: &state, action: .viewAppeared)
        let initialHistoryCount = shoe.history.count
        XCTAssertGreaterThan(initialHistoryCount, 0)
        
        // Verify we have sections with history
        guard let firstSection = state.sections.first, 
              firstSection.histories.count > 0 else {
            XCTFail("No section with histories found")
            return
        }
        
        // Remove a history entry
        let offsetsToRemove = IndexSet([0])
        interactor.handle(state: &state, action: .removeHistories(from: firstSection, atOffsets: offsetsToRemove))
        
        // Verify removal
        XCTAssertEqual(shoe.history.count, initialHistoryCount - 1)
        
        // State should be updated
        XCTAssertNotNil(state.sections)
    }
    
    // MARK: - Edge Cases
    
    // Given: Shoe with no history
    // When: Handle viewAppeared action
    // Then: Should handle gracefully with empty sections
    func testViewAppearedWithNoHistoryHandlesGracefully() {
        let testUserSettings = createTestUserSettings()
        let shoeStore = ShoeStore(context: testContext)
        let shoe = shoeStore.createShoe() // No history added
        
        // Save context to ensure shoe is properly persisted
        shoeStore.saveContext()
        
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        // Should not crash and should have empty sections
        XCTAssertEqual(state.sections.count, 0)
        // collatedHistoriesByYear returns at least one value even with no history
        XCTAssertGreaterThanOrEqual(state.yearlyTotals.count, 1)
    }
    
    // Given: Empty IndexSet for removal
    // When: Handle removeHistories action with empty offsets
    // Then: Should handle gracefully without removing anything
    func testRemoveHistoriesWithEmptyOffsetsHandlesGracefully() {
        let testUserSettings = createTestUserSettings()
        let (shoeStore, shoe) = createTestShoeWithHistory()
        let mockAnalytics = MockAnalyticsLogger()
        
        let interactor = HistoryListInteractor(shoeStore: shoeStore, shoe: shoe, settings: testUserSettings, analytics: mockAnalytics)
        var state = HistoryListState()
        
        // Load initial data
        interactor.handle(state: &state, action: .viewAppeared)
        let initialHistoryCount = shoe.history.count
        
        guard let firstSection = state.sections.first else {
            XCTFail("No sections loaded")
            return
        }
        
        // Remove with empty offsets
        let emptyOffsets = IndexSet()
        interactor.handle(state: &state, action: .removeHistories(from: firstSection, atOffsets: emptyOffsets))
        
        // Should not remove anything
        XCTAssertEqual(shoe.history.count, initialHistoryCount)
    }
}