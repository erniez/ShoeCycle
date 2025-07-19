//  ShoeTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import XCTest
@testable import ShoeCycle

final class ShoeTests: DBInteractiveTestCase {

    func testShoeHistorySort() throws {
        let shoe = createTestShoe()
        
        // Add some test history entries with different dates
        let dates = [
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 3),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 1),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 2),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 5),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 4)
        ]
        
        for (index, date) in dates.enumerated() {
            _ = createTestHistory(for: shoe, date: date, distance: Double(index + 1))
        }
        
        // Test Ascending Case
        let histories = shoe.history ?? Set<History>()
        let ascSortedHistory = histories.sortHistories(ascending: true)
        XCTAssertTrue(ascSortedHistory.count > 0, "Empty run history")
        var priorHistory = ascSortedHistory[0]
        ascSortedHistory.forEach { history in
            XCTAssertTrue(history.runDate >= priorHistory.runDate, "Run histories are not in ascending order")
            priorHistory = history
        }

        // Test Descending Case
        let decSortedHistory = histories.sortHistories(ascending: false)
        XCTAssertTrue(decSortedHistory.count > 0, "Empty run history")
        priorHistory = decSortedHistory[0]
        decSortedHistory.forEach { history in
            XCTAssertTrue(history.runDate <= priorHistory.runDate, "Run histories are not in descending order")
            priorHistory = history
        }
    }
    
    func testBeginningOfTheWeekGenerator() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set to Monday as first day
        var sut = Date()
        // Setup date components. No reason for date. It's just the day I was coding this.
        let components = DateComponents(calendar: calendar, year: 2023, month: 5, day: 25)
        if let refDate = components.date {
            sut = refDate
            var expectedDateCompenents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 22)
            var begginningOfWeek = sut.beginningOfWeek(forCalendar: calendar)
            var sutDateComponents = calendar.dateComponents([.calendar, .day, .month, .year], from: begginningOfWeek)
            XCTAssertEqual(sutDateComponents, expectedDateCompenents)

            sut = refDate.addingTimeInterval(-TimeInterval.secondsInWeek)
            expectedDateCompenents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 15)
            begginningOfWeek = sut.beginningOfWeek(forCalendar: calendar)
            sutDateComponents = calendar.dateComponents([.calendar, .day, .month, .year], from: begginningOfWeek)
            XCTAssertEqual(sutDateComponents, expectedDateCompenents)
            
            sut = refDate.addingTimeInterval(-TimeInterval.secondsInWeek * 2)
            expectedDateCompenents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 8)
            begginningOfWeek = sut.beginningOfWeek(forCalendar: calendar)
            sutDateComponents = calendar.dateComponents([.calendar, .day, .month, .year], from: begginningOfWeek)
            XCTAssertEqual(sutDateComponents, expectedDateCompenents)
            
            sut = refDate.addingTimeInterval(-TimeInterval.secondsInWeek * 3)
            expectedDateCompenents = DateComponents(calendar: calendar, year: 2023, month: 5, day: 1)
            begginningOfWeek = sut.beginningOfWeek(forCalendar: calendar)
            sutDateComponents = calendar.dateComponents([.calendar, .day, .month, .year], from: begginningOfWeek)
            XCTAssertEqual(sutDateComponents, expectedDateCompenents)
        }
        else {
            XCTFail("could not create reference date")
        }
    }
    
    func testBeginningOfTheWeekGeneratorBetweenTwoDatesWithZeroDatesInsertedForZeroMilageWeeks() throws {
        let shoe = createTestShoe()
        
        // Add some test history entries
        for i in 1...5 {
            let date = Date().addingTimeInterval(-TimeInterval.secondsInWeek * TimeInterval(i))
            _ = createTestHistory(for: shoe, date: date, distance: Double(i))
        }
        
        let histories = Array(shoe.history ?? Set<History>())
        let formatter = DateFormatter.shortDate
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set to Monday as first day
        
        let startDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInWeek * 7)

        let sut = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: Date())
        sut.forEach { date in
            print(formatter.string(from: date))
        }
    }
    
    func testHistoryWeeklyCollation() throws {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set to Monday as first day
        
        var sut = [WeeklyCollatedNew]()
        sut = shoe.history.collateHistories(ascending: true)
        let formatter = DateFormatter.shortDate
        sut.forEach { weeklyCollatedHistories in
            print("Start of Week: \(formatter.string(from: weeklyCollatedHistories.date as Date)), Total Distance: \(weeklyCollatedHistories.runDistance)")
        }
    }

}
