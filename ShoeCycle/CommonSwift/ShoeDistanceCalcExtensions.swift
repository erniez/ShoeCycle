//  ShoeDistanceCalcExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/22/23.
//  
//

import Foundation


extension Set where Element == History {
    // TODO: Conform History to Comparable once I update the data models to Swift
    func sortHistories(ascending: Bool) -> [History] {
        var sortedRuns = Array(self)
        sortedRuns.sort {
            ascending ? $0.runDate < $1.runDate : $0.runDate > $1.runDate
        }
        return sortedRuns
    }
    
    func collateHistories(ascending: Bool, firstDayOfWeek: Int = UserSettings.shared.firstDayOfWeek.rawValue) -> [WeeklyCollatedNew] {
        var collatedArray = [WeeklyCollatedNew]()
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = firstDayOfWeek
        let sortedRuns = self.sortHistories(ascending: ascending)
        sortedRuns.forEach { history in
            let beginningOfWeek = history.runDate.beginningOfWeek(forCalendar: calendar)
            if let currentWeeklyCollated = collatedArray.last {
                if currentWeeklyCollated.date == beginningOfWeek {
                    // We're still within the week, so we add more distance.
                    currentWeeklyCollated.runDistance += history.runDistance.doubleValue
                }
                else {
                    // Check to see if there is a long time between runs, and add zero mileage dates so that they show up on the graph.
                    let zeroMilageDates = calendar.datesForTheBeginningOfWeeksBetweenDates(startDate: currentWeeklyCollated.date, endDate: history.runDate)
                    zeroMilageDates.forEach { date in
                        let collatedZeroDistance = WeeklyCollatedNew(date: date, runDistance: 0.0)
                        collatedArray.append(collatedZeroDistance)
                    }
                    // Create a new weekly collated entry to start adding miles to
                    let newWeeklyCollated = WeeklyCollatedNew(date: beginningOfWeek, runDistance: history.runDistance.doubleValue)
                    collatedArray.append(newWeeklyCollated)
                }
            }
            else {
                // The result array is empty, so we add the first value here.
                let weeklyCollated = WeeklyCollatedNew(date: beginningOfWeek, runDistance: history.runDistance.doubleValue)
                collatedArray.append(weeklyCollated)
            }
        }
        return collatedArray
    }
    
    func historiesByMonth(ascending: Bool) -> [[History]] {
        let sortedHistories = self.sortHistories(ascending: ascending)
        var runsByMonth = [[History]]()
        var runsForCurrentMonth = [History]()
        let calendar = Calendar.current
        var previousMonth = 0
        var previousYear = 0
        
        sortedHistories.forEach { history in
            let components = calendar.dateComponents([.year, .month], from: history.runDate)
            
            guard let month = components.month, let year = components.year else {
                return
            }
            
            if month != previousMonth || year != previousYear {
                if runsForCurrentMonth.count > 0 {
                    runsByMonth.append(runsForCurrentMonth)
                }
                runsForCurrentMonth = [History]()
            }
            runsForCurrentMonth.append(history)
            previousYear = year
            previousMonth = month
        }
        if runsForCurrentMonth.count > 0 {
            runsByMonth.append(runsForCurrentMonth)
        }
        return runsByMonth
    }
    
}

extension Calendar {
    func datesForTheBeginningOfWeeksBetweenDates(startDate: Date, endDate:Date) -> [Date] {
        var beginningOfWeekDates: [Date] = []
        let beginningOfStartDateWeek = startDate.beginningOfWeek(forCalendar: self)
        let beginningOfEndDateWeek = endDate.beginningOfWeek(forCalendar: self)
        var dateComponents = DateComponents()
        dateComponents.weekday = self.firstWeekday
        self.enumerateDates(startingAfter: beginningOfStartDateWeek, matching: dateComponents, matchingPolicy: .nextTime) { currentDate, exactMatch, stop in
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
}
