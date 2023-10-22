//
//  MockShoeGenerator.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/13/19.
//

import Foundation
import OSLog

class MockShoeGenerator {
    let store: ShoeStore
    let totalWeeks: Int
    
    init(store: ShoeStore = ShoeStore(), totalWeeks: Int = 16) {
        self.store = store
        self.totalWeeks = totalWeeks
    }

    func generateNewShoeWithData(saveData: Bool = false) -> Shoe {
        Logger.app.trace("generating new shoe data")
        let shoeCount = store.activeShoes.count
        let newShoe = store.createShoe()
        newShoe.brand = "Test Shoe \(shoeCount + 1)"
        newShoe.maxDistance = 350
        newShoe.startDistance = 0
        newShoe.startDate = Date() - (TimeInterval.secondsInWeek * TimeInterval(totalWeeks))
        newShoe.expirationDate = newShoe.startDate + TimeInterval.secondsInSixMonths
        addRunHistories(to: newShoe, saveData: saveData)
        return newShoe
    }
    
    func addRunHistories(to shoe: Shoe, saveData: Bool = false) {
        let dates = generateRandomDates(fromPriorWeeks: totalWeeks)
        let runHistories = addRandomDistances(toDates: dates)
        runHistories.forEach { runHistory in
            addRunHistory(toShoe: shoe, runHistory: runHistory)
        }
        
        if saveData {
            store.saveContext()
        }
    }

    func generateRandomDates(fromPriorWeeks weeks: Int) -> [Date] {
        var dateArray = [Date]()
        let today = Date()
        var priorDate = today - (TimeInterval.secondsInWeek * TimeInterval(weeks))
        dateArray.append(priorDate)
        while priorDate < today {
            priorDate += TimeInterval.secondsInDay
            if Bool.random() {
                dateArray.append(priorDate)
            }
        }
        return dateArray
    }

    private func addRandomDistances(toDates dates: [Date]) -> [(Date, Float)] {
        var histories = [(Date, Float)]()
        dates.forEach { date in
            let distance = Int.random(in: 1..<10)
            let history = (date, Float(distance))
            histories.append(history)
        }
        return histories
    }

    private func addRunHistory(toShoe shoe: Shoe, runHistory: (date: Date, distance: Float)) {
        guard let context = shoe.managedObjectContext else {
            fatalError("No context is available")
        }
        guard let history = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as? History else {
            fatalError("Could not create History item")
        }
        
        history.runDistance = NSNumber(value: runHistory.distance)
        history.runDate = runHistory.date
        shoe.addHistoryObject(history)
        var totalDistance = 0
        shoe.history.forEach { totalDistance += $0.runDistance.intValue }
        shoe.totalDistance = NSNumber(value: totalDistance)
    }
}
