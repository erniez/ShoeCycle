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
    @Published var selectedShoeURL: URL?
    
    private var allShoes: [Shoe] = []
    
    let context: NSManagedObjectContext
    
    private let settings = UserSettings()
    
    init() {
        do {
            context = try ShoeStore.openStore()

            allShoes = try context.fetch(Shoe.allShoesFetchRequest)
            updateActiveShoes()
            updateHallOfFameShoes()
            selectedShoeURL = settings.selectedShoeURL
        }
        catch {
            fatalError("could not open database or fetch shoes")
        }
    }
    
    func updateAllShoes() {
        if let shoes = try? context.fetch(Shoe.allShoesFetchRequest) {
            allShoes = shoes
            updateActiveShoes()
            updateHallOfFameShoes()
        }
    }
    
    private func updateActiveShoes() {
        activeShoes = allShoes.filter { $0.hallOfFame == false }
    }
    
    private func updateHallOfFameShoes() {
        hallOfFameShoes = allShoes.filter { $0.hallOfFame == true }
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
        activeShoes.append(newShoe)
        return newShoe
    }

    func remove(shoe: Shoe) {
        ImageStore.default().deleteImage(forKey: shoe.imageKey)
        context.delete(shoe)
        saveContext()
        updateAllShoes()
    }
    
    // TODO: Account for first load where no shoes are selected.
    func setSelected(shoe: Shoe) {
        UserSettings().selectedShoeURL = shoe.objectID.uriRepresentation()
        selectedShoeURL = UserSettings().selectedShoeURL
    }
    
    // TODO: This code needs to be reworked.
    func isSelected(shoe: Shoe) -> Bool {
        // If we can't find a shoe ...
        print("comparing \(shoe.objectID.uriRepresentation()) with \(settings.selectedShoeURL)")
        if let selectedShoeID = settings.selectedShoeURL {
            if shoe.objectID.uriRepresentation() == selectedShoeID {
                return true
            }
            else {
                return false
            }
        }
        
        //... then we return, assuming the first shoe is selected
        if let selectedShoe = activeShoes.first, selectedShoe == shoe {
            settings.selectedShoeURL = shoe.objectID.uriRepresentation()
            return true
        }

        // If all else fails, then return false. We should only hit this when we have no active shoes.
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


