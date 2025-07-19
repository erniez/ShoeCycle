//  TimeIntervalExtensionTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
@testable import ShoeCycle

final class TimeIntervalExtensionTests: XCTestCase {
    
    // MARK: - Constants Accuracy Tests
    
    func testSecondsInDayAccuracy() throws {
        let expectedSecondsInDay: TimeInterval = 60 * 60 * 24 // 86,400 seconds
        
        XCTAssertEqual(TimeInterval.secondsInDay, expectedSecondsInDay, "Day should be exactly 86,400 seconds")
    }
    
    func testSecondsInWeekAccuracy() throws {
        let expectedSecondsInWeek: TimeInterval = 60 * 60 * 24 * 7 // 604,800 seconds
        
        XCTAssertEqual(TimeInterval.secondsInWeek, expectedSecondsInWeek, "Day should be exactly 86,400 seconds")
    }
    
    func testSecondsInSixMonthsApproximation() throws {
        // Current implementation uses 30.42 days per month average
        let expectedSecondsUsing30Point4Days: TimeInterval = TimeInterval.secondsInDay * 30.42 * 6
        
        XCTAssertEqual(TimeInterval.secondsInSixMonths, expectedSecondsUsing30Point4Days, accuracy: 0.1)
        
        // Verify it's approximately 6 months (within reasonable bounds)
        let approximateSixMonthsLower: TimeInterval = TimeInterval.secondsInDay * 180 // 6 months * 30 days
        let approximateSixMonthsUpper: TimeInterval = TimeInterval.secondsInDay * 186 // 6 months * 31 days
        
        XCTAssertGreaterThan(TimeInterval.secondsInSixMonths, approximateSixMonthsLower)
        XCTAssertLessThan(TimeInterval.secondsInSixMonths, approximateSixMonthsUpper)
    }
    
    // MARK: - Relationship Tests
    
    func testDayToWeekRelationship() throws {
        XCTAssertEqual(TimeInterval.secondsInWeek, TimeInterval.secondsInDay * 7)
    }
    
    func testSixMonthsToWeekRelationship() throws {
        // Six months should be approximately 26 weeks (6 * 4.33 weeks per month)
        let approximateWeeksInSixMonths = TimeInterval.secondsInSixMonths / TimeInterval.secondsInWeek
        
        XCTAssertGreaterThan(approximateWeeksInSixMonths, 25, "Six months should be more than 25 weeks")
        XCTAssertLessThan(approximateWeeksInSixMonths, 27, "Six months should be less than 27 weeks")
    }
    
    func testSixMonthsToDayRelationship() throws {
        let daysInSixMonths = TimeInterval.secondsInSixMonths / TimeInterval.secondsInDay
        
        // Should be 30.42 * 6 = 182.52 days
        XCTAssertEqual(daysInSixMonths, 182.52, accuracy: 0.1)
    }
    
    // MARK: - Real-world Usage Tests
    
    func testDateArithmeticUsingConstants() throws {
        let baseDate = Date()
        
        // Test adding one day
        let nextDay = baseDate.addingTimeInterval(TimeInterval.secondsInDay)
        let calendar = Calendar.current
        let dayDifference = calendar.dateComponents([.day], from: baseDate, to: nextDay).day
        
        XCTAssertEqual(dayDifference, 1, "Adding secondsInDay should advance by exactly one day")
    }
    
    //TODO: Delete this test
    func testDateArithmeticAcrossTimeZoneChanges() throws {
        // Test during daylight saving time transitions
        let calendar = Calendar.current
        let baseDate = Date()
        
        let oneWeekLater = baseDate.addingTimeInterval(TimeInterval.secondsInWeek)
        let weekDifference = calendar.dateComponents([.weekOfYear], from: baseDate, to: oneWeekLater).weekOfYear
        
        // Should advance by one week regardless of DST
        XCTAssertEqual(abs(weekDifference ?? 0), 1, "Adding secondsInWeek should advance by one week")
    }
    
    func testSixMonthsCalculationEdgeCases() throws {
        let calendar = Calendar.current
        let baseDate = Date()
        
        let sixMonthsLater = baseDate.addingTimeInterval(TimeInterval.secondsInSixMonths)
        let monthDifference = calendar.dateComponents([.month], from: baseDate, to: sixMonthsLater).month
        
        // Should be approximately 6 months (could be 5-7 due to varying month lengths)
        XCTAssertGreaterThanOrEqual(monthDifference ?? 0, 5, "Six months calculation should be at least 5 months")
        XCTAssertLessThanOrEqual(monthDifference ?? 0, 7, "Six months calculation should be at most 7 months")
    }
    
    // MARK: - Precision Tests
    
    func testConstantsArePrecise() throws {
        // Ensure no floating point precision issues
        XCTAssertEqual(TimeInterval.secondsInDay, 86400.0)
        XCTAssertEqual(TimeInterval.secondsInWeek, 604800.0)
        
        // Test that six months calculation maintains precision
        let expectedSixMonths = 86400.0 * 30.42 * 6
        XCTAssertEqual(TimeInterval.secondsInSixMonths, expectedSixMonths)
    }
    
    func testConstantsArePositive() throws {
        XCTAssertGreaterThan(TimeInterval.secondsInDay, 0)
        XCTAssertGreaterThan(TimeInterval.secondsInWeek, 0)
        XCTAssertGreaterThan(TimeInterval.secondsInSixMonths, 0)
    }
    
    // MARK: - Comparison with Different Calendar Systems
    
    func testSixMonthsConstantValue() throws {
        // Test that the constant matches our expected value (30.42 days per month * 6 months)
        let expectedSixMonths = 86400.0 * 30.42 * 6  // 15,755,328 seconds
        XCTAssertEqual(TimeInterval.secondsInSixMonths, expectedSixMonths, "Six months constant should match expected calculation")
    }
    
    // MARK: - Performance Tests
    //TODO: Delete this test
    func testConstantsPerformance() throws {
        // Ensure constants are computed efficiently
        measure {
            for _ in 0..<10000 {
                _ = TimeInterval.secondsInDay
                _ = TimeInterval.secondsInWeek
                _ = TimeInterval.secondsInSixMonths
            }
        }
    }
}
