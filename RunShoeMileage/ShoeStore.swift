//  ShoeStore.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/2/23.
//  
//

import Foundation
import CoreData


class ShoeStore: ObservableObject {
    
    @Published var activeShoes: [Shoe] = []
    @Published var hallOfFameShoes: [Shoe] = []
    
    private var allShoes: [Shoe] = []
    
    let context: NSManagedObjectContext
    
    private let settings = UserSettings.shared
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
        }
    }
    
    func updateActiveShoes() {
        activeShoes = allShoes.filter { $0.hallOfFame == false }
    }
    
    private func updateHallOfFameShoes() {
        hallOfFameShoes = allShoes.filter { $0.hallOfFame == true }
    }
    
    func getShoe(from url: URL?) -> Shoe? {
        guard let url = url else {
            return nil
        }
        return allShoes.first { shoe in
            url == shoe.objectID.uriRepresentation()
        }
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
    
    func adjustShoeOrderingValue(fromOffsetURL: URL, toOffsetURL: URL) {
        guard let fromShoe = getShoe(from: fromOffsetURL),
              let toIndex = allShoes.index(of: toOffsetURL) else {
            return
        }
        let newOrderingValue = getNewOrderingValue(toOffset: toIndex)
        fromShoe.orderingValue = NSNumber(value: newOrderingValue)
        saveContext()
        updateAllShoes()
    }
    
    private func getNewOrderingValue(toOffset: Int) -> Double {
        var lowerBound = 0.0
        var upperBound = 0.0
        
        if toOffset > 0 {
            lowerBound = allShoes[toOffset - 1].orderingValue.doubleValue
        }
        else {
            lowerBound = allShoes[1].orderingValue.doubleValue - 2.0
        }
        
        if toOffset < (allShoes.count - 1) {
            upperBound = allShoes[toOffset + 1].orderingValue.doubleValue
        }
        else {
            upperBound = allShoes[toOffset - 1].orderingValue.doubleValue + 2.0
        }
        
        let newOrderingValue = (lowerBound + upperBound) / 2
        return newOrderingValue
    }
    
    func removeShoe(with url: URL) {
        if let shoe = getShoe(from: url) {
            remove(shoe: shoe)
        }
    }

    func remove(shoe: Shoe) {
        if shoe.objectID.uriRepresentation() == settings.selectedShoeURL {
            settings.setSelected(shoeUrl: nil)
        }
        ImageStore_Legacy.defaultImageStore().deleteImage(forKey: shoe.imageKey)
        context.delete(shoe)
        saveContext()
        updateAllShoes()
    }
    
    func updateTotalDistance(shoe: Shoe) {
        let runTotal = shoe.history.total(initialValue: shoe.startDistance.doubleValue, for: \.runDistance.doubleValue)
        print("Total Distance: \(String(runTotal))")
        shoe.totalDistance = NSNumber(value: runTotal)
    }
    
    func addHistory(to shoe: Shoe, date: Date, distance: Double) {
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

fileprivate extension Array where Element == Shoe {
    func index(of shoeURL: URL) -> Int? {
        let shoeIndex = firstIndex { $0.objectID.uriRepresentation() == shoeURL }
        return shoeIndex
    }
}

