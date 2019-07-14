//
//  MockShoeGenerator.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/13/19.
//

import Foundation

@objc
class MockShoeGenerator: NSObject {
    let store = ShoeStore.default()
    let secondsInWeek: TimeInterval = 60 * 60 * 24 * 7
    let secondsInDay: TimeInterval = 60 * 60 * 24
    let secondsInSixMonths: TimeInterval = 6 * 30.4 * 24 * 60 * 60

    @objc
    func generateNewShoeWithData() {
        let totalWeeks = 16
        let shoeCount = store.allShoes().count
        let newShoe = store.createShoe()
        newShoe.brand = "Test Shoe \(shoeCount + 1)"
        newShoe.maxDistance = 350
        newShoe.startDistance = 0
        newShoe.startDate = Date() - (secondsInWeek * TimeInterval(totalWeeks))
        newShoe.expirationDate = newShoe.startDate + secondsInSixMonths
        let dates = generateRandomDates(fromPriorWeeks: totalWeeks)
        let runHistories = addRandomDistances(toDates: dates)
        runHistories.forEach { runHistory in
            addRunHistory(toShoe: newShoe, runHistory: runHistory)
        }
    }

    func generateRandomDates(fromPriorWeeks weeks: Int) -> [Date] {
        var dateArray = [Date]()
        let today = Date()
        var priorDate = today - (secondsInWeek * TimeInterval(weeks))
        dateArray.append(priorDate)
        while priorDate < today {
            priorDate += secondsInDay
            if Bool.random() {
                dateArray.append(priorDate)
            }
        }
        return dateArray
    }

    func addRandomDistances(toDates dates: [Date]) -> [(Date, Float)] {
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
        store.saveChangesEZ()
    }
}
