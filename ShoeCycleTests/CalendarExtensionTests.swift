//  CalendarExtensionTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
@testable import ShoeCycle

final class CalendarExtensionTests: XCTestCase {
    
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
    }
    
    // MARK: - datesForTheBeginningOfWeeksBetweenDates Tests
    
    func testDatesForWeeksBetweenConsecutiveWeeks() throws {
        // Create dates that are exactly one week apart
        let startDate = createDate(year: 2023, month: 5, day: 22) // Monday
        let endDate = createDate(year: 2023, month: 5, day: 29)   // Monday (one week later)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return empty array - no weeks between consecutive weeks
        XCTAssertEqual(result.count, 0, "No intermediate weeks between consecutive weeks")
    }
    
    func testDatesForWeeksBetweenSameWeek() throws {
        let startDate = createDate(year: 2023, month: 5, day: 22) // Monday
        let endDate = createDate(year: 2023, month: 5, day: 25)   // Thursday (same week)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return empty array - same week
        XCTAssertEqual(result.count, 0, "No intermediate weeks within the same week")
    }
    
    func testDatesForWeeksBetweenTwoWeeksApart() throws {
        let startDate = createDate(year: 2023, month: 5, day: 22) // Monday
        let endDate = createDate(year: 2023, month: 6, day: 5)    // Monday (two weeks later)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return one intermediate week (May 29)
        XCTAssertEqual(result.count, 1, "One intermediate week between dates two weeks apart")
        
        let expectedDate = createDate(year: 2023, month: 5, day: 29) // Monday between the two dates
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result[0])
        let expectedComponents = calendar.dateComponents([.year, .month, .day], from: expectedDate)
        
        XCTAssertEqual(resultComponents.year, expectedComponents.year)
        XCTAssertEqual(resultComponents.month, expectedComponents.month)
        XCTAssertEqual(resultComponents.day, expectedComponents.day)
    }
    
    func testDatesForWeeksBetweenMultipleWeeksApart() throws {
        let startDate = createDate(year: 2023, month: 5, day: 22) // Monday
        let endDate = createDate(year: 2023, month: 6, day: 12)   // Monday (three weeks later)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return two intermediate weeks
        XCTAssertEqual(result.count, 2, "Two intermediate weeks between dates three weeks apart")
        
        // Check first intermediate week (May 29)
        let firstResult = calendar.dateComponents([.year, .month, .day], from: result[0])
        XCTAssertEqual(firstResult.year, 2023)
        XCTAssertEqual(firstResult.month, 5)
        XCTAssertEqual(firstResult.day, 29)
        
        // Check second intermediate week (June 5)
        let secondResult = calendar.dateComponents([.year, .month, .day], from: result[1])
        XCTAssertEqual(secondResult.year, 2023)
        XCTAssertEqual(secondResult.month, 6)
        XCTAssertEqual(secondResult.day, 5)
    }
    
    func testDatesForWeeksBetweenAcrossMonthBoundary() throws {
        let startDate = createDate(year: 2023, month: 5, day: 29) // Monday (last week of May)
        let endDate = createDate(year: 2023, month: 6, day: 12)   // Monday (second week of June)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return one intermediate week (June 5)
        XCTAssertEqual(result.count, 1, "One intermediate week across month boundary")
        
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result[0])
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 6)
        XCTAssertEqual(resultComponents.day, 5)
    }
    
    func testDatesForWeeksBetweenAcrossYearBoundary() throws {
        let startDate = createDate(year: 2023, month: 12, day: 25) // Monday (last week of 2023)
        let endDate = createDate(year: 2024, month: 1, day: 8)     // Monday (second week of 2024)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return one intermediate week (January 1, 2024)
        XCTAssertEqual(result.count, 1, "One intermediate week across year boundary")
        
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result[0])
        XCTAssertEqual(resultComponents.year, 2024)
        XCTAssertEqual(resultComponents.month, 1)
        XCTAssertEqual(resultComponents.day, 1)
    }
    
    func testDatesForWeeksBetweenWithLeapYear() throws {
        let startDate = createDate(year: 2024, month: 2, day: 26) // Monday in leap year February
        let endDate = createDate(year: 2024, month: 3, day: 11)   // Monday in March
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return one intermediate week (March 4, accounting for leap day)
        XCTAssertEqual(result.count, 1, "One intermediate week in leap year")
        
        let resultComponents = calendar.dateComponents([.year, .month, .day], from: result[0])
        XCTAssertEqual(resultComponents.year, 2024)
        XCTAssertEqual(resultComponents.month, 3)
        XCTAssertEqual(resultComponents.day, 4)
    }
    
    func testDatesForWeeksBetweenReversedDates() throws {
        let startDate = createDate(year: 2023, month: 6, day: 5)  // Later date
        let endDate = createDate(year: 2023, month: 5, day: 22)   // Earlier date
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return empty array when start date is after end date
        XCTAssertEqual(result.count, 0, "No intermediate weeks when start date is after end date")
    }
    
    func testDatesForWeeksBetweenLargeGap() throws {
        let startDate = createDate(year: 2023, month: 1, day: 2)  // First Monday of 2023
        let endDate = createDate(year: 2023, month: 2, day: 6)    // First Monday of February
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return 4 intermediate weeks in January
        XCTAssertEqual(result.count, 4, "Four intermediate weeks in January")
        
        // Verify the dates are in ascending order
        for i in 0..<result.count-1 {
            XCTAssertLessThan(result[i], result[i+1], "Dates should be in ascending order")
        }
    }
    
    func testDatesForWeeksBetweenWithDifferentWeekStart() throws {
        // Test with Sunday as first day of week
        var sundayCalendar = Calendar(identifier: .gregorian)
        sundayCalendar.firstWeekday = 1 // Sunday
        
        let startDate = createDate(year: 2023, month: 5, day: 21) // Sunday
        let endDate = createDate(year: 2023, month: 6, day: 4)    // Sunday (two weeks later)
        
        let result = sundayCalendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // Should return one intermediate week (May 28)
        XCTAssertEqual(result.count, 1, "One intermediate week with Sunday start")
        
        let resultComponents = sundayCalendar.dateComponents([.year, .month, .day], from: result[0])
        XCTAssertEqual(resultComponents.year, 2023)
        XCTAssertEqual(resultComponents.month, 5)
        XCTAssertEqual(resultComponents.day, 28)
    }
    
    func testDatesForWeeksBetweenResultsAreMondays() throws {
        let startDate = createDate(year: 2023, month: 5, day: 22) // Monday
        let endDate = createDate(year: 2023, month: 6, day: 19)   // Monday (4 weeks later)
        
        let result = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: endDate)
        
        // All results should be Mondays (weekday 2 in our calendar)
        for date in result {
            let weekday = calendar.component(.weekday, from: date)
            XCTAssertEqual(weekday, 2, "All intermediate dates should be Mondays")
        }
    }
    
    // MARK: - Helper Methods
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(calendar: calendar, year: year, month: month, day: day)
        guard let date = components.date else {
            XCTFail("Could not create date for \(year)-\(month)-\(day)")
            return Date()
        }
        return date
    }
}