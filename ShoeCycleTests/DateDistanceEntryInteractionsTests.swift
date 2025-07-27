//  DateDistanceEntryInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import XCTest
import CoreData
@testable import ShoeCycle

final class DateDistanceEntryInteractionsTests: DBInteractiveTestCase {
    
    // MARK: - DateDistanceEntryState Tests
    
    // Given: Default initializer
    // When: Creating DateDistanceEntryState without parameters
    // Then: Should initialize with default values
    func testDateDistanceEntryStateDefaultInitialization() {
        let state = DateDistanceEntryState()
        
        XCTAssertNil(state.buttonMaxHeight)
        XCTAssertEqual(state.showHistoryView, false)
        XCTAssertEqual(state.showFavoriteDistances, false)
        XCTAssertEqual(state.favoriteDistanceToAdd, 0.0)
        XCTAssertEqual(state.showAuthorizationDeniedAlert, false)
        XCTAssertEqual(state.stravaLoading, false)
        XCTAssertEqual(state.showReachabilityAlert, false)
        XCTAssertEqual(state.showUnknownNetworkErrorAlert, false)
    }
    
    // MARK: - DateDistanceEntryInteractor Tests
    
    // Convenience function to create isolated test UserSettings
    func createTestUserSettings() -> UserSettings {
        let uniqueSuiteName = "com.shoecycle.tests.\(UUID().uuidString)"
        let testUserDefaults = UserDefaults(suiteName: uniqueSuiteName)!
        return UserSettings(userDefaults: testUserDefaults)
    }
    
    // Convenience function to create test shoe
    override func createTestShoe() -> Shoe {
        let shoeStore = ShoeStore(context: testContext)
        let shoe = shoeStore.createShoe()
        shoe.brand = "Test"
        // Only set brand, model property doesn't exist
        return shoe
    }
    
    // Given: Interactor without dependencies set
    // When: Handle actions before setDependencies is called
    // Then: Should return early for actions requiring dependencies
    func testActionsWithoutDependenciesHandleGracefully() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        // This should not crash and should handle gracefully
        interactor.handle(state: &state, action: .addDistancePressed(runDate: Date(), runDistance: "5.0"))
        
        // State should remain unchanged for dependency-requiring actions
        XCTAssertEqual(state.stravaLoading, false)
    }
    
    // Given: Fresh state and interactor
    // When: Handle viewAppeared action
    // Then: Should complete without error (no specific state changes expected)
    func testViewAppearedHandlesGracefully() {
        let shoe = createTestShoe()
        let testUserSettings = createTestUserSettings()
        let shoeStore = ShoeStore(context: testContext)
        
        var interactor = DateDistanceEntryInteractor(shoe: shoe)
        interactor.setDependencies(shoeStore: shoeStore, settings: testUserSettings)
        
        var state = DateDistanceEntryState()
        
        interactor.handle(state: &state, action: .viewAppeared)
        
        // No specific assertions as viewAppeared currently has no implementation
        XCTAssertNotNil(state) // Just ensure it doesn't crash
    }
    
    // Given: State with nil buttonMaxHeight
    // When: Handle buttonMaxHeightChanged action with specific height
    // Then: State buttonMaxHeight should be updated
    func testButtonMaxHeightChangedUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        let newHeight: CGFloat = 44.0
        
        interactor.handle(state: &state, action: .buttonMaxHeightChanged(newHeight))
        
        XCTAssertEqual(state.buttonMaxHeight, newHeight)
    }
    
    // Given: State with showHistoryView false
    // When: Handle showHistory action
    // Then: State showHistoryView should be true
    func testShowHistoryUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        interactor.handle(state: &state, action: .showHistory)
        
        XCTAssertEqual(state.showHistoryView, true)
    }
    
    // Given: State with showHistoryView true
    // When: Handle dismissHistory action
    // Then: State showHistoryView should be false
    func testDismissHistoryUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .showHistory)
        
        interactor.handle(state: &state, action: .dismissHistory)
        
        XCTAssertEqual(state.showHistoryView, false)
    }
    
    // Given: State with showFavoriteDistances false and dependencies set
    // When: Handle showFavoriteDistances action
    // Then: State showFavoriteDistances should be true
    func testShowFavoriteDistancesUpdatesState() {
        let shoe = createTestShoe()
        let testUserSettings = createTestUserSettings()
        let shoeStore = ShoeStore(context: testContext)
        
        var interactor = DateDistanceEntryInteractor(shoe: shoe)
        interactor.setDependencies(shoeStore: shoeStore, settings: testUserSettings)
        
        var state = DateDistanceEntryState()
        
        interactor.handle(state: &state, action: .showFavoriteDistances)
        
        XCTAssertEqual(state.showFavoriteDistances, true)
    }
    
    // Given: State with showFavoriteDistances true
    // When: Handle dismissFavoriteDistances action
    // Then: State showFavoriteDistances should be false
    func testDismissFavoriteDistancesUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .showFavoriteDistances)
        
        interactor.handle(state: &state, action: .dismissFavoriteDistances)
        
        XCTAssertEqual(state.showFavoriteDistances, false)
    }
    
    // Given: State with favoriteDistanceToAdd = 0
    // When: Handle favoriteDistanceSelected action with specific distance
    // Then: State favoriteDistanceToAdd should be updated
    func testFavoriteDistanceSelectedUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        let selectedDistance = 5.5
        
        interactor.handle(state: &state, action: .favoriteDistanceSelected(selectedDistance))
        
        XCTAssertEqual(state.favoriteDistanceToAdd, selectedDistance)
    }
    
    // Given: State with stravaLoading false
    // When: Handle stravaLoadingChanged action with true
    // Then: State stravaLoading should be updated
    func testStravaLoadingChangedUpdatesState() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        interactor.handle(state: &state, action: .stravaLoadingChanged(true))
        
        XCTAssertEqual(state.stravaLoading, true)
    }
    
    // Given: State with alert flags false
    // When: Handle showAlert action for each alert type
    // Then: Corresponding alert flag should be true
    func testShowAlertUpdatesCorrectAlertFlags() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        // Test authorization denied alert
        interactor.handle(state: &state, action: .showAlert(.authorizationDenied))
        XCTAssertEqual(state.showAuthorizationDeniedAlert, true)
        
        // Test reachability alert
        interactor.handle(state: &state, action: .showAlert(.reachability))
        XCTAssertEqual(state.showReachabilityAlert, true)
        
        // Test unknown network error alert
        interactor.handle(state: &state, action: .showAlert(.unknownNetworkError))
        XCTAssertEqual(state.showUnknownNetworkErrorAlert, true)
    }
    
    // Given: State with alert flags true
    // When: Handle dismissAlert action for each alert type
    // Then: Corresponding alert flag should be false
    func testDismissAlertUpdatesCorrectAlertFlags() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        // Set all alerts to true first through interactor actions
        interactor.handle(state: &state, action: .showAlert(.authorizationDenied))
        interactor.handle(state: &state, action: .showAlert(.reachability))
        interactor.handle(state: &state, action: .showAlert(.unknownNetworkError))
        
        // Test dismissing authorization denied alert
        interactor.handle(state: &state, action: .dismissAlert(.authorizationDenied))
        XCTAssertEqual(state.showAuthorizationDeniedAlert, false)
        
        // Test dismissing reachability alert
        interactor.handle(state: &state, action: .dismissAlert(.reachability))
        XCTAssertEqual(state.showReachabilityAlert, false)
        
        // Test dismissing unknown network error alert
        interactor.handle(state: &state, action: .dismissAlert(.unknownNetworkError))
        XCTAssertEqual(state.showUnknownNetworkErrorAlert, false)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Complete workflow simulating user interaction
    // Then: Should properly handle the complete flow
    func testCompleteUserInteractionWorkflow() {
        let shoe = createTestShoe()
        let testUserSettings = createTestUserSettings()
        let shoeStore = ShoeStore(context: testContext)
        
        var interactor = DateDistanceEntryInteractor(shoe: shoe)
        interactor.setDependencies(shoeStore: shoeStore, settings: testUserSettings)
        
        var state = DateDistanceEntryState()
        
        // Simulate view appeared
        interactor.handle(state: &state, action: .viewAppeared)
        
        // Simulate button height measurement
        interactor.handle(state: &state, action: .buttonMaxHeightChanged(44.0))
        XCTAssertEqual(state.buttonMaxHeight, 44.0)
        
        // Simulate user showing favorite distances
        interactor.handle(state: &state, action: .showFavoriteDistances)
        XCTAssertEqual(state.showFavoriteDistances, true)
        
        // Simulate user selecting a favorite distance
        interactor.handle(state: &state, action: .favoriteDistanceSelected(5.0))
        XCTAssertEqual(state.favoriteDistanceToAdd, 5.0)
        
        // Simulate user dismissing favorite distances
        interactor.handle(state: &state, action: .dismissFavoriteDistances)
        XCTAssertEqual(state.showFavoriteDistances, false)
        
        // Simulate user showing history
        interactor.handle(state: &state, action: .showHistory)
        XCTAssertEqual(state.showHistoryView, true)
        
        // Simulate user dismissing history
        interactor.handle(state: &state, action: .dismissHistory)
        XCTAssertEqual(state.showHistoryView, false)
    }
    
    // MARK: - Edge Cases
    
    // Given: Multiple rapid height changes
    // When: Handle buttonMaxHeightChanged multiple times quickly
    // Then: Should reflect the most recent height
    func testRapidHeightChangesReflectLatestValue() {
        let shoe = createTestShoe()
        let interactor = DateDistanceEntryInteractor(shoe: shoe)
        var state = DateDistanceEntryState()
        
        interactor.handle(state: &state, action: .buttonMaxHeightChanged(40.0))
        interactor.handle(state: &state, action: .buttonMaxHeightChanged(44.0))
        interactor.handle(state: &state, action: .buttonMaxHeightChanged(48.0))
        
        XCTAssertEqual(state.buttonMaxHeight, 48.0)
    }
    
    // Given: Alternating show/dismiss actions
    // When: Handle show and dismiss actions for the same UI element
    // Then: Should correctly toggle state
    func testAlternatingShowDismissActionsToggleCorrectly() {
        let shoe = createTestShoe()
        let testUserSettings = createTestUserSettings()
        let shoeStore = ShoeStore(context: testContext)
        
        var interactor = DateDistanceEntryInteractor(shoe: shoe)
        interactor.setDependencies(shoeStore: shoeStore, settings: testUserSettings)
        
        var state = DateDistanceEntryState()
        
        // History view toggle
        interactor.handle(state: &state, action: .showHistory)
        XCTAssertEqual(state.showHistoryView, true)
        
        interactor.handle(state: &state, action: .dismissHistory)
        XCTAssertEqual(state.showHistoryView, false)
        
        // Favorite distances toggle
        interactor.handle(state: &state, action: .showFavoriteDistances)
        XCTAssertEqual(state.showFavoriteDistances, true)
        
        interactor.handle(state: &state, action: .dismissFavoriteDistances)
        XCTAssertEqual(state.showFavoriteDistances, false)
    }
}