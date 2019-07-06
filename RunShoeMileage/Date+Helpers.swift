//
//  Date+Helpers.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/4/19.
//

import Foundation

extension NSDate {
    @objc
    func beginningOfWeek(forCalendar calendar: NSCalendar) -> NSDate {
        var startDate: NSDate?
        calendar.range(of: .weekOfYear, start: &startDate, interval: nil, for: self as Date)
        if let startDate = startDate {
            return startDate
        }
        return NSDate()
    }
}
