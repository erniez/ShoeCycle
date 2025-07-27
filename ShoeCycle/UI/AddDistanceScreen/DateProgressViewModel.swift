//  DateProgressViewModel.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import SwiftUI

struct DateProgressViewModel {
    let startDate: Date
    let endDate: Date
    
    var progressBarValue: Double {
        let shoeDateDifference = endDate.timeIntervalSince(startDate) / TimeInterval.secondsInDay
        let currentDateDifference = Date().timeIntervalSince(startDate) / TimeInterval.secondsInDay
        let progressBarValue = min((currentDateDifference / shoeDateDifference), 1)
        return progressBarValue
    }
    
    func daysToGo(currentDate: Date = Date()) -> Int {
        let currentDateDifference = -currentDate.timeIntervalSince(endDate) / TimeInterval.secondsInDay
        return max(0, Int(currentDateDifference))
    }
}
