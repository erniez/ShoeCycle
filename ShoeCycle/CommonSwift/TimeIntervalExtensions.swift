//  TimeIntervalExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/21/23.
//  
//

import Foundation

extension TimeInterval {
    static let secondsInDay: TimeInterval = 60 * 60 * 24
    static let secondsInWeek: TimeInterval = TimeInterval.secondsInDay * 7
    static let secondsInSixMonths: TimeInterval = TimeInterval.secondsInDay * (30.42) * 6
}
