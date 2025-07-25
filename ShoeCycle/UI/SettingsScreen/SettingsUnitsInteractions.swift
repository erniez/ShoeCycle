//  SettingsUnitsArchitecture.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/23/25.
//  
//

import SwiftUI

struct SettingsUnitsState {
    var selectedUnit: UserSettings.DistanceUnit
    
    init(selectedUnit: UserSettings.DistanceUnit = .miles) {
        self.selectedUnit = selectedUnit
    }
}

struct SettingsUnitsInteractor {
    
    enum Action {
        case unitChanged(UserSettings.DistanceUnit)
        case viewAppeared
    }
    
    private let userSettings: UserSettings
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func handle(state: inout SettingsUnitsState, action: Action) {
        switch action {
        case .unitChanged(let newUnit):
            guard state.selectedUnit != newUnit else { return }
            state.selectedUnit = newUnit
            userSettings.set(distanceUnit: newUnit)
            
        case .viewAppeared:
            state.selectedUnit = userSettings.distanceUnit
        }
    }
}
