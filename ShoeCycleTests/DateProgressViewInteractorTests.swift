//  DateProgressViewInteractorTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import XCTest
import SwiftUI
@testable import ShoeCycle

class DateProgressViewInteractorTests: XCTestCase {
    
    func testProgressBarValue() {
        let startDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInDay) // 1 day ago
        let endDate = Date(timeIntervalSinceNow: TimeInterval.secondsInDay * 2) // 2 day from now
        let interactor = DateProgressViewModel(startDate: startDate, endDate: endDate)
        
        let progressBarValue = interactor.progressBarValue
        
        XCTAssertEqual(progressBarValue, 0.33, accuracy: 0.01) // Expected progressBarValue = 0.33 (33%)
    }
    
    func testDaysToGo() {
        // Fixed dates for deterministic testing
        let startDate = Date(timeIntervalSince1970: 1640995200) // Jan 1, 2022 12:00 AM UTC
        let endDate = Date(timeIntervalSince1970: 1641254400)   // Jan 4, 2022 12:00 AM UTC
        let currentDate = Date(timeIntervalSince1970: 1641081600) // Jan 2, 2022 12:00 AM UTC
        
        let interactor = DateProgressViewModel(startDate: startDate, endDate: endDate)

        let daysToGo = interactor.daysToGo(currentDate: currentDate)

        XCTAssertEqual(daysToGo, 2) // Expected daysToGo = 2 (from Jan 2 to Jan 4)
    }
    
    func testDaysToGoClamp() {
        // Fixed dates for deterministic testing - endDate is in the past
        let startDate = Date(timeIntervalSince1970: 1640995200) // Jan 1, 2022 12:00 AM UTC
        let endDate = Date(timeIntervalSince1970: 1641168000)   // Jan 3, 2022 12:00 AM UTC
        let currentDate = Date(timeIntervalSince1970: 1641254400) // Jan 4, 2022 12:00 AM UTC (after endDate)
        
        let interactor = DateProgressViewModel(startDate: startDate, endDate: endDate)
        
        let daysToGo = interactor.daysToGo(currentDate: currentDate)
        
        XCTAssertEqual(daysToGo, 0) // Expected daysToGo to clamp to zero when past endDate
        
    }
    
}
