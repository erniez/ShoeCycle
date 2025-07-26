//  FavoriteDistancesInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import SwiftUI
import CoreData

struct FavoriteDistancesState {
    var distanceToAdd: Double = 0.0
    var favorite1DisplayString: String?
    var favorite2DisplayString: String?
    var favorite3DisplayString: String?
    var favorite4DisplayString: String?
    
    init() {}
}

struct FavoriteDistancesInteractor {
    
    enum Action {
        case viewAppeared
        case distanceSelected(Double)
        case cancelPressed
    }
    
    private let userSettings: UserSettings
    private let distanceUtility: DistanceUtility
    
    init(userSettings: UserSettings = UserSettings.shared, 
         distanceUtility: DistanceUtility = DistanceUtility()) {
        self.userSettings = userSettings
        self.distanceUtility = distanceUtility
    }
    
    func handle(state: inout FavoriteDistancesState, action: Action) {
        switch action {
        case .viewAppeared:
            state.favorite1DisplayString = displayString(for: Double(userSettings.favorite1))
            state.favorite2DisplayString = displayString(for: Double(userSettings.favorite2))
            state.favorite3DisplayString = displayString(for: Double(userSettings.favorite3))
            state.favorite4DisplayString = displayString(for: Double(userSettings.favorite4))
            
        case .distanceSelected(let distance):
            state.distanceToAdd = distance
            
        case .cancelPressed:
            state.distanceToAdd = 0
        }
    }
    
    private func displayString(for distance: Double) -> String? {
        let displayString = distanceUtility.favoriteDistanceDisplayString(for: distance)
        if displayString.count > 0 {
            return displayString
        }
        return nil
    }
}