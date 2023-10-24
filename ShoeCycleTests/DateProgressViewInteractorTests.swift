//  DateProgressViewInteractorTests.swift
//  ShoeCycleTests
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import XCTest
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
        let startDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInDay - 3) // 1 day ago (plus a few seconds to push it across the boundary)
        let endDate = Date(timeIntervalSinceNow: TimeInterval.secondsInDay * 3) // 3 days from now
        let interactor = DateProgressViewModel(startDate: startDate, endDate: endDate)

        let daysToGo = interactor.daysToGo

        XCTAssertEqual(daysToGo, 2) // Expected daysToGo = 2
    }
    
    func testDaysToGoClamp() {
        let startDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInDay * 5) // 5 days ago
        let endDate = Date(timeIntervalSinceNow: -TimeInterval.secondsInDay * 2) // 2 days ago
        let interactor = DateProgressViewModel(startDate: startDate, endDate: endDate)
        
        let daysToGo = interactor.daysToGo
        
        XCTAssertEqual(daysToGo, 0) // Expected daysToGo to clamp to zero
        
    }
    
}
