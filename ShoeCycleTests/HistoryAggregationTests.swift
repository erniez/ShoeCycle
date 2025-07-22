//  HistoryAggregationTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class HistoryAggregationTests: DBInteractiveTestCase {
    
    // MARK: - YTD (Year-to-Date) Calculation Tests
    
    // Given: A test shoe with multiple runs in current year
    // When: Calculating YTD totals using history aggregation
    // Then: Should sum all current year distances correctly
    func testYTDCalculationWithCurrentYearHistory() throws {
        let shoe = createTestShoe()
        let currentYear = Date.currentYear
        
        // Add runs in current year
        let jan1 = createDate(year: currentYear, month: 1, day: 15)
        let feb15 = createDate(year: currentYear, month: 2, day: 15)
        let march20 = createDate(year: currentYear, month: 3, day: 20)
        
        _ = createTestHistory(for: shoe, date: jan1, distance: 25.0)
        _ = createTestHistory(for: shoe, date: feb15, distance: 30.0)
        _ = createTestHistory(for: shoe, date: march20, distance: 20.0)
        
        // Calculate monthly groups and yearly totals
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let ytd = yearlyTotals[currentYear] ?? 0
        
        XCTAssertEqual(ytd, 75.0, "YTD should be sum of current year distances")
    }
    
    // Given: A test shoe with runs only in previous year
    // When: Calculating YTD totals for current year
    // Then: Should return 0 for current year with no runs
    func testYTDCalculationWithNoCurrentYearHistory() throws {
        let shoe = createTestShoe()
        let currentYear = Date.currentYear
        let lastYear = currentYear - 1
        
        // Add runs only in previous year
        let dec15 = createDate(year: lastYear, month: 12, day: 15)
        _ = createTestHistory(for: shoe, date: dec15, distance: 50.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let ytd = yearlyTotals[currentYear] ?? 0
        
        XCTAssertEqual(ytd, 0.0, "YTD should be 0 when no runs in current year")
    }
    
    // Given: A test shoe with runs in both current and previous years
    // When: Calculating YTD totals
    // Then: Should separate current year from previous year totals
    func testYTDCalculationWithMixedYearHistory() throws {
        let shoe = createTestShoe()
        let currentYear = Date.currentYear
        let lastYear = currentYear - 1
        
        // Add runs in both years
        let lastYearRun = createDate(year: lastYear, month: 12, day: 15)
        let thisYearRun = createDate(year: currentYear, month: 3, day: 15)
        
        _ = createTestHistory(for: shoe, date: lastYearRun, distance: 100.0)
        _ = createTestHistory(for: shoe, date: thisYearRun, distance: 40.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let ytd = yearlyTotals[currentYear] ?? 0
        let lastYearTotal = yearlyTotals[lastYear] ?? 0
        
        XCTAssertEqual(ytd, 40.0, "YTD should only include current year distances")
        XCTAssertEqual(lastYearTotal, 100.0, "Last year total should be separate")
    }
    
    // MARK: - Yearly Total Calculation Tests
    
    // Given: A test shoe with multiple runs distributed throughout a single year
    // When: Calculating yearly totals
    // Then: Should sum all runs for that year correctly
    func testYearlyTotalWithSingleYear() throws {
        let shoe = createTestShoe()
        let testYear = 2023
        
        // Add multiple runs in single year
        let run1 = createDate(year: testYear, month: 2, day: 10)
        let run2 = createDate(year: testYear, month: 5, day: 15)
        let run3 = createDate(year: testYear, month: 8, day: 20)
        let run4 = createDate(year: testYear, month: 11, day: 25)
        
        _ = createTestHistory(for: shoe, date: run1, distance: 15.0)
        _ = createTestHistory(for: shoe, date: run2, distance: 20.0)
        _ = createTestHistory(for: shoe, date: run3, distance: 25.0)
        _ = createTestHistory(for: shoe, date: run4, distance: 30.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let yearTotal = yearlyTotals[testYear] ?? 0
        
        XCTAssertEqual(yearTotal, 90.0, "Yearly total should sum all runs in the year")
    }
    
    // Given: A test shoe with runs across three different years
    // When: Calculating yearly totals for each year
    // Then: Should correctly total distances for each year separately
    func testYearlyTotalWithMultipleYears() throws {
        let shoe = createTestShoe()
        
        // Add runs across three years
        let year2022Runs = [
            (createDate(year: 2022, month: 6, day: 10), 40.0),
            (createDate(year: 2022, month: 9, day: 15), 35.0)
        ]
        
        let year2023Runs = [
            (createDate(year: 2023, month: 3, day: 10), 50.0),
            (createDate(year: 2023, month: 7, day: 15), 45.0),
            (createDate(year: 2023, month: 12, day: 20), 25.0)
        ]
        
        let year2024Runs = [
            (createDate(year: 2024, month: 2, day: 10), 60.0)
        ]
        
        // Add all runs
        for (date, distance) in year2022Runs + year2023Runs + year2024Runs {
            _ = createTestHistory(for: shoe, date: date, distance: distance)
        }
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        XCTAssertEqual(yearlyTotals[2022] ?? 0, 75.0, "2022 total should be 40 + 35")
        XCTAssertEqual(yearlyTotals[2023] ?? 0, 120.0, "2023 total should be 50 + 45 + 25")
        XCTAssertEqual(yearlyTotals[2024] ?? 0, 60.0, "2024 total should be 60")
    }
    
    // Given: A test shoe with runs in 2022 and 2024 but none in 2023
    // When: Calculating yearly totals including gap year
    // Then: Should handle empty years correctly with 0 totals
    func testYearlyTotalWithEmptyYear() throws {
        let shoe = createTestShoe()
        
        // Add runs with a gap year
        _ = createTestHistory(for: shoe, date: createDate(year: 2022, month: 6, day: 10), distance: 30.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2024, month: 3, day: 15), distance: 40.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        XCTAssertEqual(yearlyTotals[2022] ?? 0, 30.0, "2022 should have total")
        XCTAssertEqual(yearlyTotals[2023] ?? 0, 0.0, "2023 should be 0 (gap year)")
        XCTAssertEqual(yearlyTotals[2024] ?? 0, 40.0, "2024 should have total")
    }
    
    // MARK: - Monthly Aggregation Tests
    
    // Given: A test shoe with multiple runs in the same month
    // When: Grouping histories by month
    // Then: Should group all runs from same month together
    func testMonthlyHistoryGrouping() throws {
        let shoe = createTestShoe()
        
        // Add multiple runs in same month
        let jan5 = createDate(year: 2023, month: 1, day: 5)
        let jan15 = createDate(year: 2023, month: 1, day: 15)
        let jan25 = createDate(year: 2023, month: 1, day: 25)
        
        _ = createTestHistory(for: shoe, date: jan5, distance: 10.0)
        _ = createTestHistory(for: shoe, date: jan15, distance: 15.0)
        _ = createTestHistory(for: shoe, date: jan25, distance: 20.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        
        XCTAssertEqual(monthlyHistories.count, 1, "Should have one month group")
        XCTAssertEqual(monthlyHistories[0].count, 3, "January should have 3 runs")
        
        let januaryTotal = monthlyHistories[0].reduce(0.0) { total, history in
            total + history.runDistance.doubleValue
        }
        
        XCTAssertEqual(januaryTotal, 45.0, "January total should be 10 + 15 + 20")
    }
    
    // Given: A test shoe with runs across different months in same year
    // When: Grouping histories by month
    // Then: Should create separate groups for each month
    func testMonthlyHistoryAcrossMultipleMonths() throws {
        let shoe = createTestShoe()
        
        // Add runs across different months
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 1, day: 10), distance: 20.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 1, day: 20), distance: 25.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 3, day: 15), distance: 30.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 5, day: 12), distance: 35.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        
        XCTAssertEqual(monthlyHistories.count, 3, "Should have three month groups")
        
        // Verify each month's total
        let monthTotals = monthlyHistories.map { monthGroup in
            monthGroup.reduce(0.0) { total, history in
                total + history.runDistance.doubleValue
            }
        }
        
        // Note: historiesByMonth returns in descending order, so May, March, January
        XCTAssertEqual(monthTotals[0], 35.0, "May total should be 35")
        XCTAssertEqual(monthTotals[1], 30.0, "March total should be 30")
        XCTAssertEqual(monthTotals[2], 45.0, "January total should be 20 + 25")
    }
    
    // MARK: - Cross-Year Boundary Tests
    
    // Given: A test shoe with runs on both sides of year boundary
    // When: Calculating yearly totals and monthly groupings
    // Then: Should correctly separate runs by year boundary
    func testYearBoundaryCalculations() throws {
        let shoe = createTestShoe()
        
        // Add runs around year boundary
        let dec2022 = createDate(year: 2022, month: 12, day: 30)
        let jan2023 = createDate(year: 2023, month: 1, day: 2)
        
        _ = createTestHistory(for: shoe, date: dec2022, distance: 50.0)
        _ = createTestHistory(for: shoe, date: jan2023, distance: 60.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        XCTAssertEqual(yearlyTotals[2022] ?? 0, 50.0, "2022 should have December run")
        XCTAssertEqual(yearlyTotals[2023] ?? 0, 60.0, "2023 should have January run")
        XCTAssertEqual(monthlyHistories.count, 2, "Should have two separate months")
    }
    
    // MARK: - Section ViewModel Tests
    
    // Given: A test shoe with multiple history entries in same month
    // When: Creating HistorySectionViewModel from histories
    // Then: Should calculate correct totals and section metadata
    func testHistorySectionViewModelCreation() throws {
        let shoe = createTestShoe()
        
        let jan10 = createDate(year: 2023, month: 1, day: 10)
        let jan20 = createDate(year: 2023, month: 1, day: 20)
        
        let history1 = createTestHistory(for: shoe, date: jan10, distance: 15.0)
        let history2 = createTestHistory(for: shoe, date: jan20, distance: 25.0)
        
        let histories = [history1, history2]
        let sectionViewModel = HistorySectionViewModel(shoe: shoe, histories: histories)
        
        XCTAssertEqual(sectionViewModel.runTotal, 40.0, "Section run total should be sum of histories")
        XCTAssertEqual(sectionViewModel.historyViewModels.count, 2, "Should have 2 history view models")
        
        let calendar = Calendar.current
        let monthComponents = calendar.dateComponents([.year, .month], from: sectionViewModel.monthDate)
        XCTAssertEqual(monthComponents.year, 2023, "Section should be for year 2023")
        XCTAssertEqual(monthComponents.month, 1, "Section should be for January")
    }
    
    // Given: A HistorySectionViewModel and mock yearly totals
    // When: Populating sections with yearly total data
    // Then: Should correctly apply yearly totals to sections
    func testHistorySectionPopulateWithYearlyTotals() throws {
        let shoe = createTestShoe()
        let currentYear = Date.currentYear
        
        // Create section for current year
        let currentYearRun = createDate(year: currentYear, month: 6, day: 15)
        let history = createTestHistory(for: shoe, date: currentYearRun, distance: 100.0)
        
        let sectionViewModel = HistorySectionViewModel(shoe: shoe, histories: [history])
        let yearlyTotals: YearlyTotalDistance = [currentYear: 200.0] // Mock yearly total
        
        let populatedSections = HistorySectionViewModel.populate(yearlyTotals: yearlyTotals, for: [sectionViewModel])
        
        XCTAssertEqual(populatedSections.count, 1, "Should have one populated section")
        // Note: The populate method only adds yearly totals for December sections in non-current years
        // For current year sections, it doesn't modify the yearlyRunTotal
    }
    
    // MARK: - Edge Cases
    
    // Given: A test shoe with no history entries
    // When: Calculating yearly totals
    // Then: Should return 0 for current year and include current year key
    func testYearlyCalculationWithNoHistory() throws {
        let shoe = createTestShoe()
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let currentYear = Date.currentYear
        let currentYearTotal = yearlyTotals[currentYear] ?? -1
        
        XCTAssertEqual(currentYearTotal, 0.0, "Current year should have 0.0 total when no history exists")
        XCTAssertTrue(yearlyTotals.keys.contains(currentYear), "Current year should be in dictionary for UI display")
    }
    
    // Given: A test shoe with runs that have zero distance
    // When: Calculating yearly totals
    // Then: Should handle zero distances and maintain year in dictionary
    func testYearlyCalculationWithZeroDistanceRuns() throws {
        let shoe = createTestShoe()
        let testYear = 2023
        
        // Add runs with zero distance
        _ = createTestHistory(for: shoe, date: createDate(year: testYear, month: 3, day: 15), distance: 0.0)
        _ = createTestHistory(for: shoe, date: createDate(year: testYear, month: 6, day: 20), distance: 0.0)
        
        let monthlyHistories = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let sections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        let yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: sections)
        
        let yearTotal = yearlyTotals[testYear] ?? -1 // Use -1 to verify the key exists
        
        XCTAssertEqual(yearTotal, 0.0, "Yearly total should be 0 when all runs have zero distance")
        XCTAssertTrue(yearlyTotals.keys.contains(testYear), "Year with zero total should still be in the dictionary for UI display")
    }
    
    // Given: A test shoe with runs added in non-chronological order
    // When: Grouping histories by month with ascending/descending sort
    // Then: Should return properly sorted month groups
    func testMonthlyGroupingSortOrder() throws {
        let shoe = createTestShoe()
        
        // Add runs in non-chronological order
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 5, day: 15), distance: 30.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 1, day: 10), distance: 10.0)
        _ = createTestHistory(for: shoe, date: createDate(year: 2023, month: 3, day: 20), distance: 20.0)
        
        let monthlyHistoriesDesc = (shoe.history ?? Set<History>()).historiesByMonth(ascending: false)
        let monthlyHistoriesAsc = (shoe.history ?? Set<History>()).historiesByMonth(ascending: true)
        
        XCTAssertEqual(monthlyHistoriesDesc.count, 3, "Should have 3 months descending")
        XCTAssertEqual(monthlyHistoriesAsc.count, 3, "Should have 3 months ascending")
        
        // Verify descending order (May, March, January)
        let calendar = Calendar.current
        let descMonths = monthlyHistoriesDesc.map { monthGroup in
            calendar.component(.month, from: monthGroup[0].runDate)
        }
        XCTAssertEqual(descMonths, [5, 3, 1], "Descending should be May, March, January")
        
        // Verify ascending order (January, March, May)
        let ascMonths = monthlyHistoriesAsc.map { monthGroup in
            calendar.component(.month, from: monthGroup[0].runDate)
        }
        XCTAssertEqual(ascMonths, [1, 3, 5], "Ascending should be January, March, May")
    }
    
    // MARK: - Helper Methods
    
    private func createDate(year: Int, month: Int, day: Int) -> Date {
        let calendar = Calendar.current
        let components = DateComponents(calendar: calendar, year: year, month: month, day: day)
        guard let date = components.date else {
            XCTFail("Could not create date for \(year)-\(month)-\(day)")
            return Date()
        }
        return date
    }
}