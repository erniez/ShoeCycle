//
//  WeeklyCollated.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/3/19.
//

import Foundation

@objc
class WeeklyCollated: NSObject {
    @objc let date: NSDate
    @objc var runDistance: NSNumber

    @objc
    init(date: NSDate, runDistance: NSNumber) {
        self.date = date
        self.runDistance = runDistance
        super.init()
    }
}

class WeeklyCollatedNew: Equatable {
    static func == (lhs: WeeklyCollatedNew, rhs: WeeklyCollatedNew) -> Bool {
        if lhs.date == rhs.date, lhs.runDistance == rhs.runDistance {
            return true
        }
        return false
    }
    
    let date: Date
    var runDistance: Float
    
    init(date: Date, runDistance: Float) {
        self.date = date
        self.runDistance = runDistance
    }
}
