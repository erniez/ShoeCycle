//  ShoeTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import XCTest
@testable import ShoeCycle

final class ShoeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShoeHistorySort() throws {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        
        // Test Ascending Case
        let histories = Array(shoe.history) as! [History]
        let ascSortedHistory = Shoe.sortRunHistories(histories, ascending: true)
        XCTAssertTrue(ascSortedHistory.count > 0, "Empty run history")
        var priorHistory = ascSortedHistory[0]
        ascSortedHistory.forEach { history in
            XCTAssertTrue(history.runDate >= priorHistory.runDate, "Run histories are not in ascending order")
            priorHistory = history
        }

        // Test Descending Case
        let decSortedHistory = Shoe.sortRunHistories(histories, ascending: false)
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
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        let histories = Array(shoe.history) as! [History]
        let formatter = DateFormatter.shortDate
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set to Monday as first day
        
        let startDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInWeek * 7)

        let sut = Shoe.datesForTheBeginningOfWeeksBetweenDates(startDate: startDate, endDate: Date(), calendar: calendar)
        sut.forEach { date in
            print(formatter.string(from: date))
        }
    }
    
    func testHistoryWeeklyCollation() throws {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        let histories = Array(shoe.history) as! [History]
        
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Set to Monday as first day
        
        var sut = [WeeklyCollatedNew]()
        sut = Shoe.collateRunHistories(histories, ascending: true)
        let formatter = DateFormatter.shortDate
        sut.forEach { weeklyCollatedHistories in
            print("Start of Week: \(formatter.string(from: weeklyCollatedHistories.date as Date)), Total Distance: \(weeklyCollatedHistories.runDistance)")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
