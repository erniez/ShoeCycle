//  DBInteractiveTestCase.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  
//

import XCTest
import CoreData
@testable import ShoeCycle

class DBInteractiveTestCase: XCTestCase {
    
    var testContext: NSManagedObjectContext!
    private var shoeOrderingCounter: Double = 0
    
    override func setUp() {
        super.setUp()
        testContext = createInMemoryContext()
        shoeOrderingCounter = 0
    }
    
    override func tearDown() {
        testContext = nil
        shoeOrderingCounter = 0
        super.tearDown()
    }
    
    private func createInMemoryContext() -> NSManagedObjectContext {
        // Create an in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "TreadTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to create in-memory store: \(error)")
            }
        }
        
        return container.viewContext
    }
    
    func createTestShoe() -> Shoe {
        let shoe = Shoe(context: testContext)
        shoe.brand = "Test Shoe"
        shoe.maxDistance = NSNumber(value: 350.0)
        shoe.startDistance = NSNumber(value: 0.0)
        shoe.totalDistance = NSNumber(value: 0.0)
        shoe.startDate = Date()
        shoe.expirationDate = Date().addingTimeInterval(TimeInterval.secondsInSixMonths)
        
        // Assign ordering value similar to ShoeStore.createShoe()
        shoeOrderingCounter += 1
        shoe.orderingValue = NSNumber(value: shoeOrderingCounter)
        
        return shoe
    }
    
    func createTestHistory(for shoe: Shoe, date: Date, distance: Double) -> History {
        let history = History(context: testContext)
        history.runDate = date
        history.runDistance = NSNumber(value: distance)
        history.shoe = shoe
        return history
    }
}