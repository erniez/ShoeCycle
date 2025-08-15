//  ShoeDetailInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 8/13/25.
//  
//

import SwiftUI
import PhotosUI
import Foundation

struct ShoeDetailState {
    fileprivate(set) var shoeName: String
    fileprivate(set) var startDistance: String
    fileprivate(set) var maxDistance: String
    fileprivate(set) var startDate: Date
    fileprivate(set) var expirationDate: Date
    fileprivate(set) var hasChanged: Bool = false
    
    let shoeURL: URL
    let newShoe: Shoe?
    let isNewShoe: Bool
    
    init(shoeURL: URL, newShoe: Shoe? = nil, store: ShoeStore) {
        self.shoeURL = shoeURL
        self.newShoe = newShoe
        self.isNewShoe = newShoe != nil
        
        let distanceUtility = DistanceUtility()
        
        if let shoe = newShoe {
            self.shoeName = shoe.brand
            self.startDistance = distanceUtility.displayString(for: shoe.startDistance.doubleValue)
            self.maxDistance = distanceUtility.displayString(for: shoe.maxDistance.doubleValue)
            self.startDate = shoe.startDate
            self.expirationDate = shoe.expirationDate
        } else if let shoe = store.getShoe(from: shoeURL) {
            self.shoeName = shoe.brand
            self.startDistance = distanceUtility.displayString(for: shoe.startDistance.doubleValue)
            self.maxDistance = distanceUtility.displayString(for: shoe.maxDistance.doubleValue)
            self.startDate = shoe.startDate
            self.expirationDate = shoe.expirationDate
        } else {
            // Fallback values if shoe not found
            self.shoeName = ""
            self.startDistance = ""
            self.maxDistance = ""
            self.startDate = Date()
            self.expirationDate = Date()
        }
    }
}

struct ShoeDetailInteractor {
    
    enum Action {
        case viewAppeared
        case shoeNameChanged(String)
        case startDistanceChanged(String)
        case maxDistanceChanged(String)
        case startDateChanged(Date)
        case expirationDateChanged(Date)
        case hallOfFameToggled(Bool)
        case cancelNewShoe
        case saveNewShoe
        case viewDisappeared
    }
    
    private var store: ShoeStore?
    private let selectedShoeStrategy: SelectedShoeStrategy?
    private let distanceUtility = DistanceUtility()
    
    init(selectedShoeStrategy: SelectedShoeStrategy? = nil) {
        self.selectedShoeStrategy = selectedShoeStrategy
    }
    
    mutating func setStore(_ store: ShoeStore) {
        self.store = store
    }
    
    func handle(state: inout ShoeDetailState, action: Action) {
        guard let store = store else { return }
        
        switch action {
        case .viewAppeared:
            // Log analytics for existing shoes only
            if !state.isNewShoe {
                AnalyticsFactory.sharedAnalyticsLogger().logEvent(name: AnalyticsKeys.Event.viewShoeDetail, userInfo: nil)
            }
            
        case .shoeNameChanged(let newName):
            state.shoeName = newName
            state.hasChanged = true
            
        case .startDistanceChanged(let newDistance):
            state.startDistance = newDistance
            state.hasChanged = true
            
        case .maxDistanceChanged(let newDistance):
            state.maxDistance = newDistance
            state.hasChanged = true
            
        case .startDateChanged(let newDate):
            state.startDate = newDate
            state.hasChanged = true
            
        case .expirationDateChanged(let newDate):
            state.expirationDate = newDate
            state.hasChanged = true
            
        case .hallOfFameToggled(let newValue):
            guard let shoe = getShoe(from: state) else { return }
            shoe.hallOfFame = newValue
            
        case .cancelNewShoe:
            if let shoe = state.newShoe {
                store.remove(shoe: shoe)
            }
            
        case .saveNewShoe:
            updateShoeValues(state: state)
            
        case .viewDisappeared:
            if !state.isNewShoe && state.hasChanged {
                AnalyticsFactory.sharedAnalyticsLogger().logEvent(name: AnalyticsKeys.Event.didEditShoe, userInfo: nil)
                updateShoeValues(state: state)
            }
        }
    }
    
    func getShoe(from state: ShoeDetailState) -> Shoe? {
        if let shoe = state.newShoe {
            return shoe
        }
        return store?.getShoe(from: state.shoeURL)
    }
    
    func getHallOfFameStatus(from state: ShoeDetailState) -> Bool {
        guard let shoe = getShoe(from: state) else {
            return false
        }
        return shoe.hallOfFame
    }
    
    private func updateShoeValues(state: ShoeDetailState) {
        guard let store = store else { return }
        let shoeToUpdate: Shoe?
        if state.isNewShoe {
            shoeToUpdate = state.newShoe
        } else {
            shoeToUpdate = store.getShoe(from: state.shoeURL)
        }
        
        guard let shoe = shoeToUpdate else {
            return
        }
        
        shoe.brand = state.shoeName
        shoe.startDistance = NSNumber(value: distanceUtility.distance(from: state.startDistance))
        shoe.maxDistance = NSNumber(value: distanceUtility.distance(from: state.maxDistance))
        store.updateTotalDistance(shoe: shoe)
        shoe.startDate = state.startDate
        shoe.expirationDate = state.expirationDate
        
        store.saveContext()
        store.updateAllShoes()
        selectedShoeStrategy?.updateSelectedShoe()
    }
}