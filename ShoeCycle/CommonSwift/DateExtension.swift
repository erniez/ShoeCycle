//  DateExtension.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/25/23.
//  
//

import Foundation

extension Date {
    static var currentYear: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year], from: Date())
        return components.year ?? 0
    }
    
    func beginningOfWeek(forCalendar calendar: Calendar) -> Date {
        let weekInterval = calendar.dateInterval(of: .weekOfMonth, for: self)
        if let startDate = weekInterval?.start {
            return startDate
        }
        return Date()
    }
}
