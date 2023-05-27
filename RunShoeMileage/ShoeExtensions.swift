//  ShoeExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import Foundation


extension Shoe {
    
    static func sortRunHistories(_ histories: [History], ascending: Bool) -> [History] {
        var sortedRuns = Array(histories)
        sortedRuns.sort {
            ascending ? $0.runDate < $1.runDate : $0.runDate > $1.runDate
        }
        return sortedRuns
    }
    
    static func datesForTheBeginningOfWeeksBetweenDates(startDate: Date, endDate:Date, calendar: Calendar) -> [Date] {
        var beginningOfWeekDates = [Date]()
        let beginningOfStartDateWeek = startDate.beginningOfWeek(forCalendar: calendar)
        let beginningOfEndDateWeek = endDate.beginningOfWeek(forCalendar: calendar)
        var dateComponents = DateComponents()
        dateComponents.weekday = calendar.firstWeekday
        calendar.enumerateDates(startingAfter: beginningOfStartDateWeek, matching: dateComponents, matchingPolicy: .nextTime) { currentDate, exactMatch, stop in
            guard let date = currentDate else {
                stop = true
                return
            }
            
            let dateCompare = date.compare(beginningOfEndDateWeek)
            if dateCompare == .orderedDescending || dateCompare == .orderedSame {
                stop = true
            }
            else {
                beginningOfWeekDates.append(date)
            }
        }
        return beginningOfWeekDates
    }
    
    static func collateRunHistories(_ histories: [History], ascending: Bool) -> [WeeklyCollatedNew] {
        var collatedArray = [WeeklyCollatedNew]()
        let dateFormatter = DateFormatter.shortDate
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = UserDistanceSetting.getFirstDayOfWeek()
        let sortedRuns = Shoe.sortRunHistories(histories, ascending: true)
        sortedRuns.forEach { history in
            let beginningOfWeek = history.runDate.beginningOfWeek(forCalendar: calendar)
            if let currentWeeklyCollated = collatedArray.last {
                if currentWeeklyCollated.date == beginningOfWeek {
                    // We're still within the week, so we add more distance.
                    currentWeeklyCollated.runDistance += history.runDistance.floatValue
                }
                else {
                    // Check to see if there is a long time between runs, and add zero mileage dates so that they show up on the graph.
                    let zeroMilageDates = Self.datesForTheBeginningOfWeeksBetweenDates(startDate: currentWeeklyCollated.date, endDate: history.runDate, calendar: calendar)
                    zeroMilageDates.forEach { date in
                        let collatedZeroDistance = WeeklyCollatedNew(date: date, runDistance: 0.0)
                        collatedArray.append(collatedZeroDistance)
                    }
                    // Create a new weekly collated entry to start adding miles to
                    let newWeeklyCollated = WeeklyCollatedNew(date: beginningOfWeek, runDistance: history.runDistance.floatValue)
                    collatedArray.append(newWeeklyCollated)
                }
            }
            else {
                // The result array is empty, so we add the first value here.
                let weeklyCollated = WeeklyCollatedNew(date: beginningOfWeek, runDistance: history.runDistance.floatValue)
                collatedArray.append(weeklyCollated)
            }
        }
        return collatedArray
    }
    
}
