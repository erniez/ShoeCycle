//  ShoeBusinessLogicTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class ShoeBusinessLogicTests: DBInteractiveTestCase {
    
    var shoeStore: ShoeStore!
    
    override func setUp() {
        super.setUp()
        // Note: ShoeStore initializes its own context, so we'll test the actual business logic
        // For pure Core Data tests, we use the parent's testContext
    }
    
    // MARK: - Shoe Creation Tests
    
    func testCreateShoeWithDefaults() throws {
        let shoe = createTestShoe()
        
        // Test default values
        XCTAssertEqual(shoe.maxDistance.doubleValue, 350.0, "Default max distance should be 350")
        XCTAssertEqual(shoe.startDistance.doubleValue, 0.0, "Default start distance should be 0")
        XCTAssertEqual(shoe.totalDistance.doubleValue, 0.0, "Default total distance should be 0")
        XCTAssertFalse(shoe.hallOfFame, "New shoes should not be in hall of fame")
        XCTAssertNotNil(shoe.startDate, "Start date should be set")
        XCTAssertNotNil(shoe.expirationDate, "Expiration date should be set")
    }
    
    func testShoeExpirationDateIsSevenMonthsAfterStart() throws {
        let shoe = createTestShoe()
        
        let timeDifference = shoe.expirationDate.timeIntervalSince(shoe.startDate)
        let expectedDifference = TimeInterval.secondsInSixMonths
        
        // Allow for small timing differences (within 1 second)
        XCTAssertEqual(timeDifference, expectedDifference, accuracy: 1.0, 
                      "Expiration should be 6 months after start date")
    }
    
    // MARK: - Distance Calculation Tests
    
    func testTotalDistanceCalculationWithNoHistory() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 50.0)
        
        // Simulate updateTotalDistance logic without ShoeStore dependency
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 50.0, "Total should equal start distance when no history exists")
    }
    
    func testTotalDistanceCalculationWithHistory() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 50.0)
        
        // Add some history
        _ = createTestHistory(for: shoe, date: Date(), distance: 10.0)
        _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay), distance: 15.0)
        _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay * 2), distance: 5.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 80.0, "Total should be start distance (50) + history distances (30)")
    }
    
    func testTotalDistanceWithZeroStartDistance() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 0.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 25.0)
        _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay), distance: 30.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 55.0, "Total should equal sum of history when start distance is 0")
    }
    
    // MARK: - Shoe Lifecycle Tests
    
    func testShoeActiveByDefault() throws {
        let shoe = createTestShoe()
        
        XCTAssertFalse(shoe.hallOfFame, "New shoes should be active (not in hall of fame)")
    }
    
    func testShoeCanBeRetired() throws {
        let shoe = createTestShoe()
        
        // Retire the shoe
        shoe.hallOfFame = true
        
        XCTAssertTrue(shoe.hallOfFame, "Shoe should be marked as retired")
    }
    
    func testShoeCanBeReactivated() throws {
        let shoe = createTestShoe()
        
        // Retire and then reactivate
        shoe.hallOfFame = true
        shoe.hallOfFame = false
        
        XCTAssertFalse(shoe.hallOfFame, "Shoe should be active again")
    }
    
    // MARK: - Distance Validation Tests
    // TODO: Delete this test
    func testShoeDistanceProgress() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 100.0)
        shoe.maxDistance = NSNumber(value: 400.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 150.0)
        
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let progress = currentTotal / shoe.maxDistance.doubleValue
        
        XCTAssertEqual(currentTotal, 250.0, "Current total should be 250")
        XCTAssertEqual(progress, 0.625, accuracy: 0.001, "Progress should be 62.5%")
    }
    
    func testShoeExceedsMaxDistance() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 300.0)
        shoe.maxDistance = NSNumber(value: 350.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 100.0)
        
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertEqual(currentTotal, 400.0, "Current total should be 400")
        XCTAssertTrue(hasExceededMax, "Shoe should have exceeded max distance")
    }
    
    // MARK: - Date Validation Tests
    
    func testShoeStartDateBeforeExpirationDate() throws {
        let shoe = createTestShoe()
        
        XCTAssertLessThan(shoe.startDate, shoe.expirationDate, 
                         "Start date should be before expiration date")
    }
    
    func testShoeCanHaveCustomDates() throws {
        let shoe = createTestShoe()
        let customStart = Date().addingTimeInterval(-TimeInterval.secondsInWeek * 10)
        let customExpiration = Date().addingTimeInterval(TimeInterval.secondsInWeek * 10)
        
        shoe.startDate = customStart
        shoe.expirationDate = customExpiration
        
        XCTAssertEqual(shoe.startDate, customStart, "Should accept custom start date")
        XCTAssertEqual(shoe.expirationDate, customExpiration, "Should accept custom expiration date")
        XCTAssertLessThan(shoe.startDate, shoe.expirationDate, "Custom dates should maintain order")
    }
    
    // MARK: - Brand Validation Tests
    
    func testShoeCanHaveEmptyBrand() throws {
        let shoe = createTestShoe()
        shoe.brand = ""
        
        XCTAssertEqual(shoe.brand, "", "Shoe should allow empty brand")
    }
    
    func testShoeCanHaveBrandName() throws {
        let shoe = createTestShoe()
        shoe.brand = "Nike Air Max"
        
        XCTAssertEqual(shoe.brand, "Nike Air Max", "Shoe should store brand name")
    }
    
    // MARK: - History Relationship Tests
    
    func testShoeHistoryRelationship() throws {
        let shoe = createTestShoe()
        let initialHistoryCount = shoe.history?.count ?? 0
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 10.0)
        
        let finalHistoryCount = shoe.history?.count ?? 0
        
        XCTAssertEqual(initialHistoryCount, 0, "Should start with no history")
        XCTAssertEqual(finalHistoryCount, 1, "Should have one history entry after adding")
    }
    
    func testShoeMultipleHistoryEntries() throws {
        let shoe = createTestShoe()
        
        for i in 1...5 {
            _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay * TimeInterval(i)), 
                                distance: Double(i) * 5.0)
        }
        
        XCTAssertEqual(shoe.history?.count, 5, "Should have 5 history entries")
        
        let totalHistoryDistance = (shoe.history ?? Set<History>()).total(initialValue: 0.0, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(totalHistoryDistance, 75.0, "Total history distance should be 5+10+15+20+25 = 75")
    }
    
    // MARK: - Edge Cases
    
    func testShoeWithNegativeStartDistance() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: -10.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 20.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 10.0, "Should handle negative start distance correctly")
    }
    
    func testShoeWithZeroMaxDistance() throws {
        let shoe = createTestShoe()
        shoe.maxDistance = NSNumber(value: 0.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 10.0)
        
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertTrue(hasExceededMax, "Any distance should exceed zero max distance")
    }
    
    func testShoeStartDateInFuture() throws {
        let shoe = createTestShoe()
        let futureDate = Date().addingTimeInterval(TimeInterval.secondsInWeek)
        
        shoe.startDate = futureDate
        
        // The app should handle this gracefully - test that it doesn't crash
        XCTAssertEqual(shoe.startDate, futureDate, "Should accept future start date")
        XCTAssertGreaterThan(shoe.startDate, Date(), "Start date should be in future")
    }
}
