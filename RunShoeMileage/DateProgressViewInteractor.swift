//  DateProgressViewInteractor.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import Foundation

struct DateProgressViewInteractor {
    let startDate: Date
    let endDate: Date
    
    var progressBarValue: Double {
        let shoeDateDifference = endDate.timeIntervalSince(startDate) / TimeInterval.secondsInDay
        let currentDateDifference = Date().timeIntervalSince(startDate) / TimeInterval.secondsInDay
        let progressBarValue = currentDateDifference / shoeDateDifference
        return progressBarValue
    }
    
    var daysToGo: Int {
        let currentDateDifference = -Date().timeIntervalSince(endDate) / TimeInterval.secondsInDay
        return max(0, Int(currentDateDifference))
    }
}
