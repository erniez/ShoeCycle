//  ShoeStore.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/2/23.
//  
//

import Foundation
import CoreData

// I can make this class usable in Objective C, but my intent is to get rid of all
// Objective C code, so there's no need.
class ShoeStore: ObservableObject {
    
    @Published var activeShoes: [Shoe] = []
    @Published var hallOfFameShoes: [Shoe] = []
    // TODO: Remove selected shoe URL. Should only need selectedShoe.
    @Published var selectedShoeURL: URL?
    @Published var selectedShoe: Shoe?
    
    private var allShoes: [Shoe] = []
    
    let context: NSManagedObjectContext
    
    private let settings = UserSettings()
    private static let defaultStartDate = Date()
    private static let defaultExpirationDate = Date() + TimeInterval.secondsInSixMonths
    private static let defaultStartDistance = NSNumber(value: 0.0)
    private static let defautlMaxDistance = NSNumber(value: 350.0)
    private static let defaultTotalDistance = NSNumber(value: 0.0)
    
    init() {
        do {
            context = try ShoeStore.openStore()

            allShoes = try context.fetch(Shoe.allShoesFetchRequest)
            updateActiveShoes()
            updateHallOfFameShoes()
            updateSelectedShoe()
        }
        catch {
            fatalError("could not open database or fetch shoes")
        }
    }
    
    func updateAllShoes() {
        if let shoes = try? context.fetch(Shoe.allShoesFetchRequest) {
            print("Updating Shoes")
            allShoes = shoes
            updateActiveShoes()
            updateHallOfFameShoes()
            updateSelectedShoe()
        }
    }
    
    private func updateActiveShoes() {
        activeShoes = allShoes.filter { $0.hallOfFame == false }
    }
    
    private func updateHallOfFameShoes() {
        hallOfFameShoes = allShoes.filter { $0.hallOfFame == true }
    }
    
    func updateSelectedShoe() {
        let settings = UserSettings()
        // If we have a selected shoe URL, then find the first match.
        if let selectedShoeURL = settings.selectedShoeURL {
            let selectedShoe = activeShoes.first { shoe in
                selectedShoeURL == shoe.objectID.uriRepresentation()
            }
            self.selectedShoeURL = settings.selectedShoeURL
            self.selectedShoe = selectedShoe
            return
        }
        // ... If not, then select the first shoe.
        if let shoe = activeShoes.first {
            settings.selectedShoeURL = shoe.objectID.uriRepresentation()
            self.selectedShoe = shoe
            selectedShoeURL = settings.selectedShoeURL
            return
        }
        // ... If all else fails ...
        selectedShoeURL = nil
        self.selectedShoe = nil
    }

    func createShoe() -> Shoe {
        var order: Double = 0
        if activeShoes.count == 0 {
            order = 1
        }
        else {
            if let shoe = activeShoes.last {
                order = shoe.orderingValue.doubleValue + 1
            }
        }
        
        let newShoe = Shoe(context: context)
        newShoe.setValue(NSNumber(value: order), forKey: "orderingValue")
        newShoe.startDate = Self.defaultStartDate
        newShoe.expirationDate = Self.defaultExpirationDate
        newShoe.startDistance = Self.defaultStartDistance
        newShoe.maxDistance = Self.defautlMaxDistance
        newShoe.totalDistance = Self.defaultTotalDistance
        newShoe.brand = ""
        return newShoe
    }

    func remove(shoe: Shoe) {
        if shoe == selectedShoe {
            setSelected(shoe: nil)
        }
        ImageStore_Legacy.defaultImageStore().deleteImage(forKey: shoe.imageKey)
        context.delete(shoe)
        saveContext()
        updateAllShoes()
    }
    
    func setSelected(shoe: Shoe?) {
        UserSettings().selectedShoeURL = shoe?.objectID.uriRepresentation()
    }
    
    func isSelected(shoe: Shoe) -> Bool {
        if let selectedShoe = self.selectedShoe {
            if shoe == selectedShoe {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    func updateTotalDistance(shoe: Shoe) {
        let runTotal = shoe.history.reduce(shoe.startDistance.floatValue) { $0 + $1.runDistance.floatValue }
        print("Total Distance: \(String(runTotal))")
        shoe.totalDistance = NSNumber(value: runTotal)
    }
    
    func addHistory(to shoe: Shoe, date: Date, distance: Float) {
        guard let newHistory = NSEntityDescription.insertNewObject(forEntityName: "History", into: context) as? History else {
            print("Could not create History object")
            return
        }
        
        newHistory.runDistance = NSNumber(value: distance)
        newHistory.runDate = date
        shoe.addHistoryObject(newHistory)
        updateTotalDistance(shoe: shoe)
        saveContext()
    }
    
    func delete(history: History) {
        context.delete(history)
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                print("saving context")
                try context.save()
            } catch {
                print("Error occurred while trying to save context")
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
    
}

extension ShoeStore {
    // Using the ways of old to open the database because I am specifying the actual data file. There doesn't
    // appear to be a way to do that using NSPersistentContainer, which will figure out it's own filename.
    // TODO: Research what it will take to convert to the more modern style. SwiftData was just released, so update to that.
    static func openStore() throws -> NSManagedObjectContext {
        var context: NSManagedObjectContext
        let model = NSManagedObjectModel.mergedModel(from: nil) ?? NSManagedObjectModel()
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = documentDirectories[0]
        var storeURL = URL(fileURLWithPath: documentDirectory)
        storeURL.append(components: "store.data")
        let options = [ NSMigratePersistentStoresAutomaticallyOption : NSNumber(value: true),
                              NSInferMappingModelAutomaticallyOption : NSNumber(value: true) ]
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                          configurationName: nil,
                                                          at: storeURL,
                                                          options: options)
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator
        context.undoManager = nil
        return context
    }
}

extension Shoe {
    static var allShoesFetchRequest: NSFetchRequest<Shoe> {
        let fetchRequest = NSFetchRequest<Shoe>(entityName: "Shoe")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderingValue", ascending: true)]
        return fetchRequest
    }
}


