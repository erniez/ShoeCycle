//
//  MockShoeGenerator.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/13/19.
//

import Foundation


class MockShoeGenerator {
    let store = ShoeStore()

    func generateNewShoeWithData(saveData: Bool = false) -> Shoe {
        print("generating new shoe data")
        let totalWeeks = 16
        let shoeCount = store.activeShoes.count
        let newShoe = store.createShoe()
        newShoe.brand = "Test Shoe \(shoeCount + 1)"
        newShoe.maxDistance = 350
        newShoe.startDistance = 0
        newShoe.startDate = Date() - (TimeInterval.secondsInWeek * TimeInterval(totalWeeks))
        newShoe.expirationDate = newShoe.startDate + TimeInterval.secondsInSixMonths
        let dates = generateRandomDates(fromPriorWeeks: totalWeeks)
        let runHistories = addRandomDistances(toDates: dates)
        runHistories.forEach { runHistory in
            addRunHistory(toShoe: newShoe, runHistory: runHistory, saveData: saveData)
        }
        return newShoe
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

    private func addRunHistory(toShoe shoe: Shoe, runHistory: (date: Date, distance: Float), saveData: Bool) {
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
        if saveData {
            store.saveContext()
        }
    }
}
