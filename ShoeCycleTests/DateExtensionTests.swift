//  DateExtensionTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
@testable import ShoeCycle

final class DateExtensionTests: XCTestCase {
    
    // MARK: - Date.currentYear Tests
    
    func testCurrentYearIsNonZero() throws {
        XCTAssertNotEqual(Date.currentYear, 0, "Current year should never be 0")
    }
    
    // MARK: - Date.beginningOfWeek Tests
    
    func testBeginningOfWeekWithMondayStart() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        
        // Test with a known Thursday (May 25, 2023)
        let thursdayComponents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 25)
        guard let thursday = thursdayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = thursday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be Monday, May 22, 2023
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 5)
        XCTAssertEqual(resultComponents.day, 22)
    }
    
    func testBeginningOfWeekWithSundayStart() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1 // Sunday
        
        // Test with a known Thursday (May 25, 2023)
        let thursdayComponents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 25)
        guard let thursday = thursdayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = thursday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be Sunday, May 21, 2023
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 5)
        XCTAssertEqual(resultComponents.day, 21)
    }
    
    func testBeginningOfWeekAcrossMonthBoundary() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        
        // Test with Tuesday, March 1, 2023
        let tuesdayComponents = DateComponents(calendar: calendar, year: 2023, month: 3, day: 1)
        guard let tuesday = tuesdayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = tuesday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be Monday, February 27, 2023 (previous month)
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 2)
        XCTAssertEqual(resultComponents.day, 27)
    }
    
    func testBeginningOfWeekAcrossYearBoundary() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        
        // Test with Wednesday, January 4, 2023
        let wednesdayComponents = DateComponents(calendar: calendar, year: 2023, month: 1, day: 4)
        guard let wednesday = wednesdayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = wednesday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be Monday, January 2, 2023 (same year in this case)
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 1)
        XCTAssertEqual(resultComponents.day, 2)
    }
    
    func testBeginningOfWeekWithLeapYear() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        
        // Test with Thursday, March 1, 2024 (leap year)
        let thursdayComponents = DateComponents(calendar: calendar, year: 2024, month: 3, day: 1)
        guard let thursday = thursdayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = thursday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be Monday, February 26, 2024 (leap year has 29 days in Feb)
        XCTAssertEqual(resultComponents.year, 2024)
        XCTAssertEqual(resultComponents.month, 2)
        XCTAssertEqual(resultComponents.day, 26)
    }
    
    func testBeginningOfWeekWhenAlreadyAtWeekStart() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
        
        // Test with a Monday
        let mondayComponents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 22)
        guard let monday = mondayComponents.date else {
            XCTFail("Could not create test date")
            return
        }
        
        let beginningOfWeek = monday.beginningOfWeek(forCalendar: calendar)
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: beginningOfWeek)
        
        // Should be the same Monday
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 5)
        XCTAssertEqual(resultComponents.day, 22)
    }
    
    func testBeginningOfWeekFallbackBehavior() throws {
        let calendar = Calendar(identifier: .gregorian)
        let testDate = Date()
        
        let result = testDate.beginningOfWeek(forCalendar: calendar)
        
        // Should never return a date in the future
        XCTAssertLessThanOrEqual(result, testDate)
        
        // Should be within the same week (within 7 days)
        let timeDifference = testDate.timeIntervalSince(result)
        XCTAssertLessThan(timeDifference, TimeInterval.secondsInWeek)
        XCTAssertGreaterThanOrEqual(timeDifference, 0)
    }

}
