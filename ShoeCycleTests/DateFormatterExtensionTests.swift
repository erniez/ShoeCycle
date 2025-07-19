//  DateFormatterExtensionTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
@testable import ShoeCycle

final class DateFormatterExtensionTests: XCTestCase {
    
    // MARK: - DateFormatter.shortDate Tests
    
    func testShortDateFormatterConfiguration() throws {
        let formatter = DateFormatter.shortDate
        
        XCTAssertEqual(formatter.dateStyle, .short, "Short date formatter should use short date style")
        XCTAssertEqual(formatter.timeStyle, .none, "Short date formatter should not display time")
    }
    
    func testShortDateFormatterOutput() throws {
        let formatter = DateFormatter.shortDate
        let calendar = Calendar(identifier: .gregorian)
        
        // Create a known date
        let components = DateComponents(calendar: calendar, year: 2023, month: 5, day: 25)
        guard let testDate = components.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let result = formatter.string(from: testDate)
        
        // Should contain year, month, and day but not time
        XCTAssertTrue(result.contains("2023") || result.contains("23"), "Should contain year")
        XCTAssertTrue(result.contains("5") || result.contains("05"), "Should contain month")
        XCTAssertTrue(result.contains("25"), "Should contain day")
        XCTAssertFalse(result.contains(":"), "Should not contain time separators")
    }
    
    func testShortDateFormatterWithDifferentDates() throws {
        let formatter = DateFormatter.shortDate
        let calendar = Calendar(identifier: .gregorian)
        
        // Test various dates
        let validTestCases = [
            (year: 2023, month: 1, day: 1),   // New Year's Day
            (year: 2024, month: 2, day: 29),  // Valid leap day
            (year: 2023, month: 12, day: 31), // New Year's Eve
        ]
        
        for testCase in validTestCases {
            let components = DateComponents(calendar: calendar, year: testCase.year, month: testCase.month, day: testCase.day)
            
            if let testDate = components.date {
                let result = formatter.string(from: testDate)
                XCTAssertFalse(result.isEmpty, "Formatter should produce non-empty string for valid date")
                XCTAssertFalse(result.contains(":"), "Short date should not contain time")
            } else {
                XCTFail("Should be able to create valid date for \(testCase)")
            }
        }
        
        // Test invalid date handling - DateComponents auto-corrects invalid dates
        let invalidComponents = DateComponents(calendar: calendar, year: 2023, month: 2, day: 29) // Invalid: Feb 29 in non-leap year
        if let autoCorrectDate = invalidComponents.date {
            let correctedComponents = calendar.dateComponents([.year, .month, .day], from: autoCorrectDate)
            // Should auto-correct to March 1, 2023
            XCTAssertEqual(correctedComponents.year, 2023)
            XCTAssertEqual(correctedComponents.month, 3)
            XCTAssertEqual(correctedComponents.day, 1)
        } else {
            XCTFail("DateComponents should auto-correct invalid dates, not return nil")
        }
    }
    
    // MARK: - DateFormatter.UTCDate Tests
    
    func testUTCDateFormatterConfiguration() throws {
        let formatter = DateFormatter.UTCDate
        
        XCTAssertEqual(formatter.dateFormat, "yyyy-MM-dd'T'HH:mm:ss'Z'", "UTC formatter should use ISO 8601 format")
    }
    
    func testUTCDateFormatterFormatCorrectness() throws {
        let formatter = DateFormatter.UTCDate
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        
        let components = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "UTC"), 
                                      year: 2023, month: 5, day: 25, hour: 14, minute: 30, second: 45)
        guard let testDate = components.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let result = formatter.string(from: testDate)
        
        // Should match the ISO 8601 format pattern with 4-digit year
        let expectedPattern = #"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z"#
        XCTAssertTrue(result.range(of: expectedPattern, options: .regularExpression) != nil, 
                     "Result should match expected pattern: \(result)")
        
        // Verify specific expected output
        XCTAssertEqual(result, "2023-05-25T14:30:45Z", "Should produce correct ISO 8601 formatted string")
    }
    
    func testUTCDateFormatterWithDifferentYears() throws {
        let formatter = DateFormatter.UTCDate
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        let calendar = Calendar(identifier: .gregorian)
        
        // Test with a year < 1000 to ensure 4-digit formatting
        let components99 = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "UTC"),
                                        year: 99, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        guard let testDate99 = components99.date else {
            XCTFail("Could not create test date for year 99")
            return
        }
        
        let result99 = formatter.string(from: testDate99)
        
        // With "yyyy" format, year 99 should be displayed as 4 digits ("0099")
        XCTAssertTrue(result99.hasPrefix("0099-"), "Year should be formatted with 4 digits: \(result99)")
        
        // Test with normal 4-digit year
        let components2023 = DateComponents(calendar: calendar, timeZone: TimeZone(identifier: "UTC"),
                                          year: 2023, month: 1, day: 1, hour: 0, minute: 0, second: 0)
        guard let testDate2023 = components2023.date else {
            XCTFail("Could not create test date for 2023")
            return
        }
        
        let result2023 = formatter.string(from: testDate2023)
        XCTAssertTrue(result2023.hasPrefix("2023-"), "4-digit years should display correctly: \(result2023)")
        XCTAssertEqual(result2023, "2023-01-01T00:00:00Z", "Should produce correct format for 2023")
    }
    
    func testUTCDateFormatterTimeZoneHandling() throws {
        let formatter = DateFormatter.UTCDate
        let testDate = Date()
        
        // Test with different timezone settings
        formatter.timeZone = TimeZone(identifier: "UTC")
        let utcResult = formatter.string(from: testDate)
        
        formatter.timeZone = TimeZone(identifier: "America/New_York")
        let nyResult = formatter.string(from: testDate)
        
        // Results should be different (different times) but same format
        XCTAssertTrue(utcResult.hasSuffix("Z"), "UTC result should end with Z")
        XCTAssertTrue(nyResult.hasSuffix("Z"), "NY result should still end with Z (literal)")
        
        // The times should differ if not during UTC offset change
        if !utcResult.hasPrefix(nyResult.prefix(10)) { // Different date
            XCTAssertNotEqual(utcResult, nyResult, "Different timezones should produce different times")
        }
    }
    
    // MARK: - Locale Handling Tests
}
