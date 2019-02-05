//
//  Date+Helpers.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/4/19.
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
        
//        NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//        cal.firstWeekday = 2;// set first week day to Monday
//        // 1: Sunday, 2: Monday, ..., 7:Saturday
//        NSDate *now = [NSDate date];
//        NSDate *startOfTheWeek;
//        NSDate *endOfWeek;
//        NSTimeInterval interval;
//        [cal rangeOfUnit:NSCalendarUnitWeekOfYear
//            startDate:&startOfTheWeek
//            interval:&interval
//            forDate:now];
//        //startOfTheWeek holds the beginning of the week
//        endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval - 1];
//        // endOfWeek now holds the last second of the last week day
//        [cal rangeOfUnit:NSCalendarUnitDay
//            startDate:&endOfWeek
//            interval:NULL
//            forDate:endOfWeek];
//        // endOfWeek now holds the beginning of the last week day
    }
}
