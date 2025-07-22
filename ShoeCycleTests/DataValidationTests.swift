//  DataValidationTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class DataValidationTests: DBInteractiveTestCase {
    
    // MARK: - Distance Validation Tests
    
    // Given: A test shoe exists
    // When: Adding history with negative distance
    // Then: Should store negative distance and affect totals correctly
    func testNegativeDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test negative distance in history
        let history = createTestHistory(for: shoe, date: Date(), distance: -10.0)
        
        XCTAssertEqual(history.runDistance.doubleValue, -10.0, "Should store negative distance (app handles this)")
        
        // Test how negative distance affects totals
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, -10.0, "Negative distance should decrease total")
    }
    
    // Given: A test shoe exists
    // When: Adding history with zero distance
    // Then: Should accept zero distance without changing total
    func testZeroDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test zero distance
        let history = createTestHistory(for: shoe, date: Date(), distance: 0.0)
        
        XCTAssertEqual(history.runDistance.doubleValue, 0.0, "Should accept zero distance")
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 0.0, "Zero distance should not change total")
    }
    
    // Given: A test shoe exists
    // When: Adding history with very large distance (1000 miles)
    // Then: Should accept and include large distances in totals
    func testExtremelyLargeDistanceValues() throws {
        let shoe = createTestShoe()
        
        // Test very large distance (like 1000 miles)
        let largeDistance = 1000.0
        let history = createTestHistory(for: shoe, date: Date(), distance: largeDistance)
        
        XCTAssertEqual(history.runDistance.doubleValue, largeDistance, "Should accept large distance values")
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, largeDistance, "Large distance should be included in total")
    }
    
    // Given: A test shoe exists
    // When: Adding history with high-precision decimal distance
    // Then: Should maintain reasonable floating point precision
    func testFloatingPointPrecision() throws {
        let shoe = createTestShoe()
        
        // Test floating point precision
        let preciseDistance = 3.14159265359
        let history = createTestHistory(for: shoe, date: Date(), distance: preciseDistance)
        
        XCTAssertEqual(history.runDistance.doubleValue, preciseDistance, accuracy: 0.000001, 
                      "Should maintain reasonable precision for decimal distances")
    }
    
    // MARK: - Shoe Distance Constraints Tests
    // Given: A test shoe with negative max distance
    // When: Adding positive distance history
    // Then: Should store negative max and correctly identify when exceeded
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
    
    // Given: A test shoe with zero max distance
    // When: Adding any positive distance
    // Then: Should correctly identify that max is exceeded
    func testZeroMaxDistance() throws {
        let shoe = createTestShoe()
        
        shoe.maxDistance = NSNumber(value: 0.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 1.0)
        let currentTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        let hasExceededMax = currentTotal > shoe.maxDistance.doubleValue
        
        XCTAssertTrue(hasExceededMax, "Any positive distance should exceed zero max")
    }
    
    // Given: A test shoe with negative start distance
    // When: Adding positive distance history
    // Then: Should include negative start distance in total calculations
    func testNegativeStartDistance() throws {
        let shoe = createTestShoe()
        
        // Test negative start distance
        shoe.startDistance = NSNumber(value: -50.0)
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 30.0)
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, -20.0, "Negative start distance should affect calculations correctly")
    }

    // Given: A test shoe with start distance higher than max distance
    // When: Checking if max distance is exceeded
    // Then: Should correctly identify that start distance can exceed max
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
    
    // Given: A test shoe exists
    // When: Adding history with future run date
    // Then: Should accept future dates for run entries
    func testFutureRunDates() throws {
        let shoe = createTestShoe()
        
        // Test run date in the future
        let futureDate = Date().addingTimeInterval(TimeInterval.secondsInWeek)
        let history = createTestHistory(for: shoe, date: futureDate, distance: 10.0)
        
        XCTAssertEqual(history.runDate, futureDate, "Should accept future run dates")
        XCTAssertGreaterThan(history.runDate, Date(), "Run date should be in future")
    }
    
    // Given: A test shoe exists
    // When: Adding history with very old date (1970)
    // Then: Should accept historical dates for run entries
    func testVeryOldRunDates() throws {
        let shoe = createTestShoe()
        
        // Test very old date (like 1970)
        let veryOldDate = Date(timeIntervalSince1970: 0) // January 1, 1970
        let history = createTestHistory(for: shoe, date: veryOldDate, distance: 5.0)
        
        XCTAssertEqual(history.runDate, veryOldDate, "Should accept very old dates")
    }

    // Given: A test shoe exists
    // When: Setting start date after expiration date
    // Then: Should allow illogical date combinations
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
    
    // Given: A test shoe exists
    // When: Setting expiration date in the past
    // Then: Should allow past expiration dates
    func testShoeExpirationDateInPast() throws {
        let shoe = createTestShoe()
        
        // Set expiration date in the past
        let pastDate = Date().addingTimeInterval(-TimeInterval.secondsInSixMonths)
        shoe.expirationDate = pastDate
        
        XCTAssertLessThan(shoe.expirationDate, Date(), "Should allow past expiration dates")
    }
    
    // Given: A test shoe with a start date
    // When: Adding history with run date before shoe start date
    // Then: Should allow run dates before shoe creation
    func testRunDateBeforeShoeStartDate() throws {
        let shoe = createTestShoe()
        
        let shoeStartDate = Date()
        let runDate = shoeStartDate.addingTimeInterval(-TimeInterval.secondsInWeek)
        
        shoe.startDate = shoeStartDate
        let history = createTestHistory(for: shoe, date: runDate, distance: 15.0)
        
        XCTAssertLessThan(history.runDate, shoe.startDate, 
                         "Should allow run dates before shoe start date")
    }
    
    // Given: A test shoe with an expiration date
    // When: Adding history with run date after shoe expiration
    // Then: Should allow run dates after shoe expiration
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
    
    // Given: A test shoe exists
    // When: Setting brand name to empty string
    // Then: Should accept empty brand names
    func testEmptyBrandName() throws {
        let shoe = createTestShoe()
        
        shoe.brand = ""
        XCTAssertEqual(shoe.brand, "", "Should accept empty brand name")
    }
    
    // Given: A test shoe exists
    // When: Setting brand name to very long string (1000 characters)
    // Then: Should accept very long brand names
    func testVeryLongBrandName() throws {
        let shoe = createTestShoe()
        
        // Test very long brand name
        let longBrand = String(repeating: "A", count: 1000)
        shoe.brand = longBrand
        
        XCTAssertEqual(shoe.brand, longBrand, "Should accept very long brand names")
    }
    
    // Given: A test shoe exists
    // When: Setting brand name with special characters and symbols
    // Then: Should accept all special characters in brand names
    func testBrandNameWithSpecialCharacters() throws {
        let shoe = createTestShoe()
        
        let specialBrand = "Nike™ Air Max® 90's & More! @#$%^&*()[]{}|\\:;\"`~<>,.?/"
        shoe.brand = specialBrand
        
        XCTAssertEqual(shoe.brand, specialBrand, "Should accept special characters in brand name")
    }
    
    // Given: A test shoe exists
    // When: Setting brand name with Unicode characters and emojis
    // Then: Should accept Unicode characters in brand names
    func testBrandNameWithUnicodeCharacters() throws {
        let shoe = createTestShoe()
        
        let unicodeBrand = "Nike 🏃‍♂️ Running 中文 العربية ñáéíóú"
        shoe.brand = unicodeBrand
        
        XCTAssertEqual(shoe.brand, unicodeBrand, "Should accept unicode characters in brand name")
    }
    
    // MARK: - Core Data Relationship Validation Tests

    // Given: A Core Data context exists
    // When: Creating history entry without associating to a shoe
    // Then: Should allow history to exist without shoe relationship
    func testHistoryWithoutShoe() throws {
        // Test creating history without associating it to a shoe
        let history = History(context: testContext)
        history.runDate = Date()
        history.runDistance = NSNumber(value: 10.0)
        
        XCTAssertNil(history.shoe, "History should be able to exist without shoe relationship")
    }
    
    // Given: A test shoe is created
    // When: Checking history relationship
    // Then: Should allow shoe to exist without history entries
    func testShoeWithoutHistory() throws {
        let shoe = createTestShoe()
        
        // Verify shoe can exist without history
        XCTAssertEqual(shoe.history?.count ?? 0, 0, "Shoe should be able to exist without history")
    }
    
    // Given: A test shoe and history entry are created and linked
    // When: Checking bidirectional relationship
    // Then: Should maintain proper Core Data relationship integrity
    func testHistoryShoeRelationshipIntegrity() throws {
        let shoe = createTestShoe()
        let history = createTestHistory(for: shoe, date: Date(), distance: 15.0)
        
        // Verify bidirectional relationship
        XCTAssertEqual(history.shoe, shoe, "History should reference the correct shoe")
        XCTAssertTrue(shoe.history?.contains(history) ?? false, "Shoe should contain the history")
    }
    
    // Given: A test shoe with one history entry
    // When: Removing history from the shoe
    // Then: Should properly break the bidirectional relationship
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
    
    // Given: A test shoe exists
    // When: Setting max distance to maximum double value
    // Then: Should handle maximum finite double values
    func testDoubleMaxValue() throws {
        let shoe = createTestShoe()
        
        // Test with maximum double value
        let maxDouble = Double.greatestFiniteMagnitude
        shoe.maxDistance = NSNumber(value: maxDouble)
        
        XCTAssertEqual(shoe.maxDistance.doubleValue, maxDouble, "Should handle maximum double values")
    }
    
    // Given: A test shoe exists
    // When: Setting start distance to minimum double value
    // Then: Should handle most negative finite double values
    func testDoubleMinValue() throws {
        let shoe = createTestShoe()
        
        // Test with minimum double value (most negative)
        let minDouble = -Double.greatestFiniteMagnitude
        shoe.startDistance = NSNumber(value: minDouble)
        
        XCTAssertEqual(shoe.startDistance.doubleValue, minDouble, "Should handle minimum double values")
    }

    // Given: A test shoe exists
    // When: Setting total distance to NaN (Not a Number)
    // Then: Should store and preserve NaN values
    func testNaNValues() throws {
        let shoe = createTestShoe()
        
        // Test with NaN (Not a Number)
        let nanValue = Double.nan
        shoe.totalDistance = NSNumber(value: nanValue)
        
        XCTAssertTrue(shoe.totalDistance.doubleValue.isNaN, "Should store NaN values")
    }
    
    // Given: A test shoe exists
    // When: Setting max distance to positive infinity
    // Then: Should store and identify positive infinity values
    func testInfinityValues() throws {
        let shoe = createTestShoe()
        
        // Test with positive infinity
        let infinityValue = Double.infinity
        shoe.maxDistance = NSNumber(value: infinityValue)
        
        XCTAssertTrue(shoe.maxDistance.doubleValue.isInfinite, "Should store infinity values")
        XCTAssertTrue(shoe.maxDistance.doubleValue > 0, "Should be positive infinity")
    }

    // Given: A test shoe exists
    // When: Setting start distance to negative infinity
    // Then: Should store and identify negative infinity values
    func testNegativeInfinityValues() throws {
        let shoe = createTestShoe()
        
        // Test with negative infinity
        let negativeInfinityValue = -Double.infinity
        shoe.startDistance = NSNumber(value: negativeInfinityValue)
        
        XCTAssertTrue(shoe.startDistance.doubleValue.isInfinite, "Should store negative infinity")
        XCTAssertTrue(shoe.startDistance.doubleValue < 0, "Should be negative infinity")
    }
    
    // MARK: - Calculation Edge Cases
    
    // Given: A test shoe with start distance and mixed positive/negative history
    // When: Calculating total distance
    // Then: Should correctly sum all positive and negative distances
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
    
    // Given: A test shoe with zero max distance and positive history
    // When: Checking if max distance is exceeded
    // Then: Should handle division by zero scenario gracefully
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

    // Given: A test shoe with start distance and exactly offsetting negative history
    // When: Calculating total distance
    // Then: Should result in exactly zero when distances cancel out
    func testCalculationResultingInZero() throws {
        let shoe = createTestShoe()
        shoe.startDistance = NSNumber(value: 50.0)
        
        // Add negative distance that cancels out start distance
        _ = createTestHistory(for: shoe, date: Date(), distance: -50.0)
        
        let runTotal = (shoe.history ?? Set<History>()).total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        
        XCTAssertEqual(runTotal, 0.0, "Total should be zero when distances cancel out")
    }
}
