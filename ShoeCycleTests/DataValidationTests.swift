//  DataValidationTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class DataValidationTests: DBInteractiveTestCase {
    
    // MARK: - Distance Validation Tests
    
    func testNegativeDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test negative distance in history
        let history = createTestHistory(for: shoe, date: Date(), distance: -10.0)
        
        XCTAssertEqual(history.runDistance.doubleValue, -10.0, "Should store negative distance (app handles this)")
        
        // Test how negative distance affects totals
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, -10.0, "Negative distance should decrease total")
    }
    
    func testZeroDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test zero distance
        let history = createTestHistory(for: shoe, date: Date(), distance: 0.0)
        
        XCTAssertEqual(history.runDistance.doubleValue, 0.0, "Should accept zero distance")
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 0.0, "Zero distance should not change total")
    }
    
    func testExtremelyLargeDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test very large distance (like 1000 miles)
        let largeDistance = 1000.0
        let history = createTestHistory(for: shoe, date: Date(), distance: largeDistance)
        
        XCTAssertEqual(history.runDistance.doubleValue, largeDistance, "Should accept large distance values")
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, largeDistance, "Large distance should be included in total")
    }
    
    func testFloatingPointPrecision() throws {
        let shoe = createTestShoe()
        
        // Test floating point precision
        let preciseDistance = 3.14159265359
        let history = createTestHistory(for: shoe, date: Date(), distance: preciseDistance)
        
        XCTAssertEqual(history.runDistance.doubleValue, preciseDistance, accuracy: 0.000001, 
                      "Should maintain reasonable precision for decimal distances")
    }
    
    // MARK: - Shoe Distance Constraints Tests
    func testNegativeMaxDistance() throws {
        let shoe = createTestShoe()
        
        // Test negative max distance
        shoe.maxDistance = NSNumber(value: -100.0)
        
        XCTAssertEqual(shoe.maxDistance.doubleValue, -100.0, "Should store negative max distance")
        
        // Test how this affects progress calculations
        _ = createTestHistory(for: shoe, date: Date(), distance: 50.0)
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertTrue(hasExceededMax, "Positive distance should exceed negative max")
    }
    
    func testZeroMaxDistance() throws {
        let shoe = createTestShoe()
        
        shoe.maxDistance = NSNumber(value: 0.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 1.0)
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertTrue(hasExceededMax, "Any positive distance should exceed zero max")
    }
    
    func testNegativeStartDistance() throws {
        let shoe = createTestShoe()
        
        // Test negative start distance
        shoe.startDistance = NSNumber(value: -50.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 30.0)
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, -20.0, "Negative start distance should affect calculations correctly")
    }

    func testStartDistanceExceedsMaxDistance() throws {
        let shoe = createTestShoe()
        
        // Set start distance higher than max distance
        shoe.startDistance = NSNumber(value: 400.0)
        shoe.maxDistance = NSNumber(value: 350.0)
        
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertTrue(hasExceededMax, "Start distance can exceed max distance")
        XCTAssertEqual(currentTotal, 400.0, "Total should equal start distance with no history")
    }
    
    // MARK: - Date Validation Tests
    
    func testFutureRunDates() throws {
        let shoe = createTestShoe()
        
        // Test run date in the future
        let futureDate = Date().addingTimeInterval(TimeInterval.secondsInWeek)
        let history = createTestHistory(for: shoe, date: futureDate, distance: 10.0)
        
        XCTAssertEqual(history.runDate, futureDate, "Should accept future run dates")
        XCTAssertGreaterThan(history.runDate, Date(), "Run date should be in future")
    }
    
    func testVeryOldRunDates() throws {
        let shoe = createTestShoe()
        
        // Test very old date (like 1970)
        let veryOldDate = Date(timeIntervalSince1970: 0) // January 1, 1970
        let history = createTestHistory(for: shoe, date: veryOldDate, distance: 5.0)
        
        XCTAssertEqual(history.runDate, veryOldDate, "Should accept very old dates")
    }

    func testShoeStartDateAfterExpirationDate() throws {
        let shoe = createTestShoe()
        
        // Set start date after expiration date
        let startDate = Date()
        let expirationDate = startDate.addingTimeInterval(-TimeInterval.secondsInWeek)
        
        shoe.startDate = startDate
        shoe.expirationDate = expirationDate
        
        XCTAssertGreaterThan(shoe.startDate, shoe.expirationDate, 
                           "Should allow start date after expiration date")
    }
    
    func testShoeExpirationDateInPast() throws {
        let shoe = createTestShoe()
        
        // Set expiration date in the past
        let pastDate = Date().addingTimeInterval(-TimeInterval.secondsInSixMonths)
        shoe.expirationDate = pastDate
        
        XCTAssertLessThan(shoe.expirationDate, Date(), "Should allow past expiration dates")
    }
    
    func testRunDateBeforeShoeStartDate() throws {
        let shoe = createTestShoe()
        
        let shoeStartDate = Date()
        let runDate = shoeStartDate.addingTimeInterval(-TimeInterval.secondsInWeek)
        
        shoe.startDate = shoeStartDate
        let history = createTestHistory(for: shoe, date: runDate, distance: 15.0)
        
        XCTAssertLessThan(history.runDate, shoe.startDate, 
                         "Should allow run dates before shoe start date")
    }
    
    func testRunDateAfterShoeExpirationDate() throws {
        let shoe = createTestShoe()
        
        let expirationDate = Date()
        let runDate = expirationDate.addingTimeInterval(TimeInterval.secondsInWeek)
        
        shoe.expirationDate = expirationDate
        let history = createTestHistory(for: shoe, date: runDate, distance: 20.0)
        
        XCTAssertGreaterThan(history.runDate, shoe.expirationDate,
                           "Should allow run dates after shoe expiration")
    }
    
    // MARK: - String/Text Validation Tests
    
    func testEmptyBrandName() throws {
        let shoe = createTestShoe()
        
        shoe.brand = ""
        XCTAssertEqual(shoe.brand, "", "Should accept empty brand name")
    }
    
    func testVeryLongBrandName() throws {
        let shoe = createTestShoe()
        
        // Test very long brand name
        let longBrand = String(repeating: "A", count: 1000)
        shoe.brand = longBrand
        
        XCTAssertEqual(shoe.brand, longBrand, "Should accept very long brand names")
    }
    
    func testBrandNameWithSpecialCharacters() throws {
        let shoe = createTestShoe()
        
        let specialBrand = "Nike™ Air Max® 90's & More! @#$%^&*()[]{}|\\:;\"`~<>,.?/"
        shoe.brand = specialBrand
        
        XCTAssertEqual(shoe.brand, specialBrand, "Should accept special characters in brand name")
    }
    
    func testBrandNameWithUnicodeCharacters() throws {
        let shoe = createTestShoe()
        
        let unicodeBrand = "Nike 🏃‍♂️ Running 中文 العربية ñáéíóú"
        shoe.brand = unicodeBrand
        
        XCTAssertEqual(shoe.brand, unicodeBrand, "Should accept unicode characters in brand name")
    }
    
    // MARK: - Core Data Relationship Validation Tests

    func testHistoryWithoutShoe() throws {
        // Test creating history without associating it to a shoe
        let history = History(context: testContext)
        history.runDate = Date()
        history.runDistance = NSNumber(value: 10.0)
        
        XCTAssertNil(history.shoe, "History should be able to exist without shoe relationship")
    }
    
    func testShoeWithoutHistory() throws {
        let shoe = createTestShoe()
        
        // Verify shoe can exist without history
        XCTAssertEqual(shoe.history?.count ?? 0, 0, "Shoe should be able to exist without history")
    }
    
    func testHistoryShoeRelationshipIntegrity() throws {
        let shoe = createTestShoe()
        let history = createTestHistory(for: shoe, date: Date(), distance: 15.0)
        
        // Verify bidirectional relationship
        XCTAssertEqual(history.shoe, shoe, "History should reference the correct shoe")
        XCTAssertTrue(shoe.history?.contains(history) ?? false, "Shoe should contain the history")
    }
    
    func testRemoveHistoryFromShoe() throws {
        let shoe = createTestShoe()
        let history = createTestHistory(for: shoe, date: Date(), distance: 25.0)
        
        XCTAssertEqual(shoe.history?.count, 1, "Should have one history entry")
        
        // Remove history from shoe
        shoe.removeHistoryObject(history)
        
        XCTAssertEqual(shoe.history?.count ?? 0, 0, "Should have no history entries after removal")
        XCTAssertNil(history.shoe, "History should no longer reference shoe")
    }
    
    // MARK: - Numerical Edge Cases
    
    func testDoubleMaxValue() throws {
        let shoe = createTestShoe()
        
        // Test with maximum double value
        let maxDouble = Double.greatestFiniteMagnitude
        shoe.maxDistance = NSNumber(value: maxDouble)
        
        XCTAssertEqual(shoe.maxDistance.doubleValue, maxDouble, "Should handle maximum double values")
    }
    
    func testDoubleMinValue() throws {
        let shoe = createTestShoe()
        
        // Test with minimum double value (most negative)
        let minDouble = -Double.greatestFiniteMagnitude
        shoe.startDistance = NSNumber(value: minDouble)
        
        XCTAssertEqual(shoe.startDistance.doubleValue, minDouble, "Should handle minimum double values")
    }

    func testNaNValues() throws {
        let shoe = createTestShoe()
        
        // Test with NaN (Not a Number)
        let nanValue = Double.nan
        shoe.totalDistance = NSNumber(value: nanValue)
        
        XCTAssertTrue(shoe.totalDistance.doubleValue.isNaN, "Should store NaN values")
    }
    
    func testInfinityValues() throws {
        let shoe = createTestShoe()
        
        // Test with positive infinity
        let infinityValue = Double.infinity
        shoe.maxDistance = NSNumber(value: infinityValue)
        
        XCTAssertTrue(shoe.maxDistance.doubleValue.isInfinite, "Should store infinity values")
        XCTAssertTrue(shoe.maxDistance.doubleValue > 0, "Should be positive infinity")
    }

    func testNegativeInfinityValues() throws {
        let shoe = createTestShoe()
        
        // Test with negative infinity
        let negativeInfinityValue = -Double.infinity
        shoe.startDistance = NSNumber(value: negativeInfinityValue)
        
        XCTAssertTrue(shoe.startDistance.doubleValue.isInfinite, "Should store negative infinity")
        XCTAssertTrue(shoe.startDistance.doubleValue < 0, "Should be negative infinity")
    }
    
    // MARK: - Calculation Edge Cases
    
    func testTotalCalculationWithMixedSigns() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 100.0)
        
        // Add mix of positive and negative distances
        _ = createTestHistory(for: shoe, date: Date(), distance: 50.0)
        _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay), distance: -30.0)
        _ = createTestHistory(for: shoe, date: Date().addingTimeInterval(-TimeInterval.secondsInDay * 2), distance: 20.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 140.0, "Should handle mixed positive/negative distances: 100 + 50 - 30 + 20")
    }
    
    func testProgressCalculationWithZeroMax() throws {
        let shoe = createTestShoe()
        shoe.maxDistance = NSNumber(value: 0.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 10.0)
        
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        // Progress calculation would result in division by zero
        // The app should handle this gracefully
        XCTAssertEqual(currentTotal, 10.0, "Current total should be calculated correctly")
        XCTAssertEqual(shoe.maxDistance.doubleValue, 0.0, "Max distance should be zero")
        
        // Any positive distance should exceed zero max
        let hasExceeded = currentTotal > shoe.maxDistance.doubleValue
        XCTAssertTrue(hasExceeded, "Should correctly identify when zero max is exceeded")
    }

    func testCalculationResultingInZero() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 50.0)
        
        // Add negative distance that cancels out start distance
        _ = createTestHistory(for: shoe, date: Date(), distance: -50.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 0.0, "Total should be zero when distances cancel out")
    }
}
