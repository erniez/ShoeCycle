//  HistoryCollationTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
@testable import ShoeCycle

final class HistoryCollationTests: DBInteractiveTestCase {
    
    var calendar: Calendar!
    
    override func setUp() {
        super.setUp()
        calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2 // Monday
    }
    
    // MARK: - sortHistories Tests
    
    func testSortHistoriesAscending() throws {
        let shoe = createTestShoe()
        
        // Add some test history entries
        let dates = [
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 3),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 1),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 2)
        ]
        
        for (index, date) in dates.enumerated() {
            _ = createTestHistory(for: shoe, date: date, distance: Double(index + 1))
        }
        
        let histories = shoe.history ?? Set<History>()
        let sortedAscending = histories.sortHistories(ascending: true)
        
        XCTAssertGreaterThan(sortedAscending.count, 0, "Should have history entries")
        
        // Verify ascending order
        for i in 0..<sortedAscending.count-1 {
            XCTAssertLessThanOrEqual(sortedAscending[i].runDate, sortedAscending[i+1].runDate,
                                   "Histories should be in ascending order")
        }
    }
    
    func testSortHistoriesDescending() throws {
        let shoe = createTestShoe()
        
        // Add some test history entries
        let dates = [
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 1),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 3),
            Date().addingTimeInterval(-TimeInterval.secondsInDay * 2)
        ]
        
        for (index, date) in dates.enumerated() {
            _ = createTestHistory(for: shoe, date: date, distance: Double(index + 1))
        }
        
        let histories = shoe.history ?? Set<History>()
        let sortedDescending = histories.sortHistories(ascending: false)
        
        XCTAssertGreaterThan(sortedDescending.count, 0, "Should have history entries")
        
        // Verify descending order
        for i in 0..<sortedDescending.count-1 {
            XCTAssertGreaterThanOrEqual(sortedDescending[i].runDate, sortedDescending[i+1].runDate,
                                      "Histories should be in descending order")
        }
    }
    
    func testSortHistoriesWithSameDates() throws {
        // Create shoe with multiple runs on same day
        let shoe = createTestShoe()
        let sameDate = Date()
        
        // Add multiple histories with same date
        for i in 1...3 {
            _ = createTestHistory(for: shoe, date: sameDate, distance: Double(i))
        }
        
        let histories = shoe.history ?? Set<History>()
        let sortedAscending = histories.sortHistories(ascending: true)
        let sortedDescending = histories.sortHistories(ascending: false)
        
        // Should maintain stable sort for equal dates
        XCTAssertEqual(sortedAscending.count, 3)
        XCTAssertEqual(sortedDescending.count, 3)
        
        // All dates should be the same in both sorts
        for history in sortedAscending {
            XCTAssertEqual(history.runDate, sameDate)
        }
        
        for history in sortedDescending {
            XCTAssertEqual(history.runDate, sameDate)
        }
    }
    
    // MARK: - collateHistories Tests
    
    func testCollateHistoriesWithSingleWeek() throws {
        let shoe = createTestShoe()
        let baseDate = createDate(year: 2023, month: 5, day: 22) // Monday
        
        // Add multiple runs in the same week
        let distances = [3.1, 5.0, 2.8]
        for (index, distance) in distances.enumerated() {
            let runDate = baseDate.addingTimeInterval(TimeInterval(index) * TimeInterval.secondsInDay) // Add days
            _ = createTestHistory(for: shoe, date: runDate, distance: distance)
        }
        
        let collated = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        
        XCTAssertEqual(collated.count, 1, "Should collate into single week")
        XCTAssertEqual(collated[0].runDistance, distances.reduce(0, +), accuracy: 0.01,
                      "Should sum all distances in the week")
        
        let expectedWeekStart = baseDate.beginningOfWeek(forCalendar: calendar)
        XCTAssertEqual(collated[0].date, expectedWeekStart, "Should use beginning of week date")
    }
    
    func testCollateHistoriesWithMultipleWeeks() throws {
        let shoe = createTestShoe()
        let week1Date = createDate(year: 2023, month: 5, day: 22) // Monday
        let week2Date = week1Date.addingTimeInterval(TimeInterval.secondsInWeek) // Next Monday
        
        // Week 1 runs
        let week1Distances = [3.0, 4.0]
        for (index, distance) in week1Distances.enumerated() {
            let runDate = week1Date.addingTimeInterval(TimeInterval(index) * TimeInterval.secondsInDay)
            _ = createTestHistory(for: shoe, date: runDate, distance: distance)
        }
        
        // Week 2 runs
        let week2Distances = [5.0, 6.0]
        for (index, distance) in week2Distances.enumerated() {
            let runDate = week2Date.addingTimeInterval(TimeInterval(index) * TimeInterval.secondsInDay)
            _ = createTestHistory(for: shoe, date: runDate, distance: distance)
        }
        
        let collated = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        
        XCTAssertEqual(collated.count, 2, "Should have two weeks")
        
        // Verify week 1
        XCTAssertEqual(collated[0].runDistance, week1Distances.reduce(0, +), accuracy: 0.01)
        
        // Verify week 2
        XCTAssertEqual(collated[1].runDistance, week2Distances.reduce(0, +), accuracy: 0.01)
    }
    
    func testCollateHistoriesWithGapWeeks() throws {
        let shoe = createTestShoe()
        let week1Date = createDate(year: 2023, month: 5, day: 22) // Monday
        let week3Date = week1Date.addingTimeInterval(TimeInterval.secondsInWeek * 2) // Two weeks later
        
        // Week 1 run
        _ = createTestHistory(for: shoe, date: week1Date, distance: 5.0)
        
        // Week 3 run (skip week 2)
        _ = createTestHistory(for: shoe, date: week3Date, distance: 7.0)
        
        let collated = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        
        XCTAssertEqual(collated.count, 3, "Should include gap week with zero distance")
        
        // Week 1
        XCTAssertEqual(collated[0].runDistance, 5.0, accuracy: 0.01)
        
        // Gap week (week 2) - should be zero
        XCTAssertEqual(collated[1].runDistance, 0.0, accuracy: 0.01)
        
        // Week 3
        XCTAssertEqual(collated[2].runDistance, 7.0, accuracy: 0.01)
    }
    
    func testCollateHistoriesAcrossYearBoundary() throws {
        let shoe = createTestShoe()
        let lastWeek2023 = createDate(year: 2023, month: 12, day: 25) // Last Monday of 2023
        let firstWeek2024 = createDate(year: 2024, month: 1, day: 1)  // First Monday of 2024
        
        // Add runs in both years
        _ = createTestHistory(for: shoe, date: lastWeek2023, distance: 3.0)
        _ = createTestHistory(for: shoe, date: firstWeek2024, distance: 4.0)
        
        let collated = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        
        XCTAssertGreaterThanOrEqual(collated.count, 2, "Should handle year boundary")
        
        // Verify dates are properly collated across year boundary
        let years = collated.map { calendar.component(.year, from: $0.date) }
        XCTAssertTrue(years.contains(2023), "Should include 2023")
        XCTAssertTrue(years.contains(2024), "Should include 2024")
    }
    
    // MARK: - historiesByMonth Tests
    
    func testHistoriesByMonthWithSingleMonth() throws {
        let shoe = createTestShoe()
        let mayDate = createDate(year: 2023, month: 5, day: 15)
        
        // Add multiple runs in May
        for i in 1...5 {
            let runDate = mayDate.addingTimeInterval(TimeInterval(i) * TimeInterval.secondsInDay)
            _ = createTestHistory(for: shoe, date: runDate, distance: Double(i))
        }
        
        let monthGroups = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(monthGroups.count, 1, "Should have one month group")
        XCTAssertEqual(monthGroups[0].count, 5, "Should have all 5 runs in May")
        
        // Verify all runs are in May 2023
        for history in monthGroups[0] {
            let components = calendar.dateComponents([.year, .month], from: history.runDate)
            XCTAssertEqual(components.year, 2023)
            XCTAssertEqual(components.month, 5)
        }
    }
    
    func testHistoriesByMonthWithMultipleMonths() throws {
        let shoe = createTestShoe()
        
        // Add runs in different months
        let months = [(year: 2023, month: 4), (year: 2023, month: 5), (year: 2023, month: 6)]
        
        for (monthIndex, monthData) in months.enumerated() {
            for day in 1...3 {
                let runDate = createDate(year: monthData.year, month: monthData.month, day: day)
                _ = createTestHistory(for: shoe, date: runDate, distance: Double(monthIndex + 1))
            }
        }
        
        let monthGroups = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(monthGroups.count, 3, "Should have three month groups")
        
        // Verify each month group
        for (index, monthGroup) in monthGroups.enumerated() {
            XCTAssertEqual(monthGroup.count, 3, "Each month should have 3 runs")
            
            let expectedMonth = months[index].month
            for history in monthGroup {
                let components = calendar.dateComponents([.month], from: history.runDate)
                XCTAssertEqual(components.month, expectedMonth, "All runs should be in correct month")
            }
        }
    }
    
    func testHistoriesByMonthAcrossYears() throws {
        let shoe = createTestShoe()
        
        // Add runs in December 2023 and January 2024
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 12, day: 15), distance: 5.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2024, month: 1, day: 15), distance: 6.0)
        
        let monthGroups = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(monthGroups.count, 2, "Should have two month groups across years")
        
        // Verify December 2023
        let decGroup = monthGroups[0]
        XCTAssertEqual(decGroup.count, 1)
        let decComponents = calendar.dateComponents([.year, .month], from: decGroup[0].runDate)
        XCTAssertEqual(decComponents.year, 2023)
        XCTAssertEqual(decComponents.month, 12)
        
        // Verify January 2024
        let janGroup = monthGroups[1]
        XCTAssertEqual(janGroup.count, 1)
        let janComponents = calendar.dateComponents([.year, .month], from: janGroup[0].runDate)
        XCTAssertEqual(janComponents.year, 2024)
        XCTAssertEqual(janComponents.month, 1)
    }
    
    func testHistoriesByMonthAscendingOrder() throws {
        let shoe = createTestShoe()
        
        // Add runs in chronological order
        let months = [3, 4, 5] // March, April, May
        for month in months {
            let runDate = createDate(year: 2023, month: month, day: 15)
            _ = createTestHistory(for: shoe, date: runDate, distance: Double(month))
        }
        
        let monthGroups = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(monthGroups.count, 3, "Should have three month groups")
        
        // Verify ascending order (March, April, May)
        let expectedMonths = [3, 4, 5]
        for (index, monthGroup) in monthGroups.enumerated() {
            let components = calendar.dateComponents([.month], from: monthGroup[0].runDate)
            XCTAssertEqual(components.month, expectedMonths[index], 
                          "Months should be in ascending order")
        }
    }
    
    func testHistoriesByMonthDescendingOrder() throws {
        let shoe = createTestShoe()
        
        // Add runs in chronological order
        let months = [3, 4, 5] // March, April, May
        for month in months {
            let runDate = createDate(year: 2023, month: month, day: 15)
            _ = createTestHistory(for: shoe, date: runDate, distance: Double(month))
        }
        
        let monthGroups = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        
        XCTAssertEqual(monthGroups.count, 3, "Should have three month groups")
        
        // Verify descending order (May, April, March)
        let expectedMonths = [5, 4, 3]
        for (index, monthGroup) in monthGroups.enumerated() {
            let components = calendar.dateComponents([.month], from: monthGroup[0].runDate)
            XCTAssertEqual(components.month, expectedMonths[index], 
                          "Months should be in descending order")
        }
    }
    
    // MARK: - Edge Cases
    
    func testEmptyHistorySet() throws {
        let shoe = createTestShoe()
        // Don't add any history
        
        let histories = shoe.history ?? Set<History>()
        let sortedHistories = histories.sortHistories(ascending: true)
        let collatedHistories = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(sortedHistories.count, 0, "Empty set should remain empty")
        XCTAssertEqual(collatedHistories.count, 0, "Empty set should produce no collated data")
        XCTAssertEqual(monthlyHistories.count, 0, "Empty set should produce no monthly groups")
    }
    
    func testSingleHistoryEntry() throws {
        let shoe = createTestShoe()
        
        _ = createTestHistory(for: shoe, date: Date(), distance: 5.0)
        
        let histories = shoe.history ?? Set<History>()
        let sortedHistories = histories.sortHistories(ascending: true)
        let collatedHistories = (shoe.history ?? Set<History>()).collateHistories(ascending: true, firstDayOfWeek: calendar.firstWeekday)
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(sortedHistories.count, 1, "Single entry should remain single")
        XCTAssertEqual(collatedHistories.count, 1, "Single entry should produce one collated week")
        XCTAssertEqual(monthlyHistories.count, 1, "Single entry should produce one monthly group")
        XCTAssertEqual(monthlyHistories[0].count, 1, "Monthly group should contain single entry")
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
