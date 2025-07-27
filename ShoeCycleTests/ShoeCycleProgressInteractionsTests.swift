//  ShoeCycleProgressInteractionsTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import XCTest
@testable import ShoeCycle

final class ShoeCycleProgressInteractionsTests: XCTestCase {
    
    // MARK: - ShoeCycleProgressState Tests
    
    // Given: Default initializer
    // When: Creating ShoeCycleProgressState without parameters
    // Then: Should initialize with bounceState false
    func testShoeCycleProgressStateDefaultInitialization() {
        let state = ShoeCycleProgressState()
        
        XCTAssertEqual(state.bounceState, false)
    }
    
    // MARK: - ShoeCycleProgressInteractor Tests
    
    // Given: State with bounceState false
    // When: Handle bounceTriggered action
    // Then: bounceState should toggle to true
    func testBounceTriggeredTogglesFromFalseToTrue() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        
        interactor.handle(state: &state, action: .bounceTriggered)
        
        XCTAssertEqual(state.bounceState, true)
    }
    
    // Given: State with bounceState true
    // When: Handle bounceTriggered action
    // Then: bounceState should toggle to false
    func testBounceTriggeredTogglesFromTrueToFalse() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .bounceStateChanged(true))
        
        interactor.handle(state: &state, action: .bounceTriggered)
        
        XCTAssertEqual(state.bounceState, false)
    }
    
    // Given: State with bounceState false
    // When: Handle bounceStateChanged action with true
    // Then: bounceState should be set to true
    func testBounceStateChangedSetsToTrue() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        
        interactor.handle(state: &state, action: .bounceStateChanged(true))
        
        XCTAssertEqual(state.bounceState, true)
    }
    
    // Given: State with bounceState true
    // When: Handle bounceStateChanged action with false
    // Then: bounceState should be set to false
    func testBounceStateChangedSetsToFalse() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .bounceStateChanged(true))
        
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        
        XCTAssertEqual(state.bounceState, false)
    }
    
    // Given: State with bounceState false
    // When: Handle bounceStateChanged action with false
    // Then: bounceState should remain false (idempotent)
    func testBounceStateChangedIsIdempotent() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        // Set initial state through interactor action to match actual usage
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        
        XCTAssertEqual(state.bounceState, false)
    }
    
    // Given: Multiple consecutive toggle actions
    // When: Handle bounceTriggered multiple times
    // Then: Should correctly alternate between true and false
    func testMultipleBounceTriggersAlternateCorrectly() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        
        // Start with false
        XCTAssertEqual(state.bounceState, false)
        
        // First trigger -> true
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
        
        // Second trigger -> false
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, false)
        
        // Third trigger -> true
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
    }
    
    // MARK: - Integration Tests
    
    // Given: Fresh interactor and state
    // When: Complete workflow simulating bounce animation cycle
    // Then: Should properly handle the complete bounce sequence
    func testCompleteBounceAnimationWorkflow() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        
        // Initial state
        XCTAssertEqual(state.bounceState, false)
        
        // Trigger bounce (e.g., user adds distance)
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
        
        // Animation completes, manually set to false
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        XCTAssertEqual(state.bounceState, false)
        
        // Another bounce cycle
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
        
        // Reset again
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        XCTAssertEqual(state.bounceState, false)
    }
    
    // MARK: - Edge Cases
    
    // Given: Rapid successive actions
    // When: Handle mixed bounce actions quickly
    // Then: Should maintain correct state regardless of timing
    func testRapidSuccessiveActions() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        
        // Rapid sequence of actions
        interactor.handle(state: &state, action: .bounceTriggered)
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        interactor.handle(state: &state, action: .bounceTriggered)
        interactor.handle(state: &state, action: .bounceTriggered) // Should toggle back
        interactor.handle(state: &state, action: .bounceStateChanged(true))
        
        XCTAssertEqual(state.bounceState, true)
    }
    
    // Given: State manipulation through different action types
    // When: Mix bounceTriggered and bounceStateChanged actions
    // Then: Final state should reflect the last action taken
    func testMixedActionTypesProduceCorrectFinalState() {
        let interactor = ShoeCycleProgressInteractor()
        var state = ShoeCycleProgressState()
        
        // Set to true via toggle
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
        
        // Override to false via direct change
        interactor.handle(state: &state, action: .bounceStateChanged(false))
        XCTAssertEqual(state.bounceState, false)
        
        // Toggle from false to true
        interactor.handle(state: &state, action: .bounceTriggered)
        XCTAssertEqual(state.bounceState, true)
        
        // Override to true (should be idempotent)
        interactor.handle(state: &state, action: .bounceStateChanged(true))
        XCTAssertEqual(state.bounceState, true)
    }
}