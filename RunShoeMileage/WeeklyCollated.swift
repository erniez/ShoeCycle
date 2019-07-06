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
