//  UserSettings.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import Foundation

class UserSettings {
    let settings = UserDefaults.standard
    var selectedShoeURL: URL? {
        get {
            guard let url = settings.url(forKey: StorageKey.selectedShoe) else {
                return nil
            }
            return url
        }
        set {
            if let url = newValue {
                settings.set(url, forKey: StorageKey.selectedShoe)
            }
        }
    }
}

extension UserSettings {
    enum StorageKey {
        static let distanceUnit = "TreadTrackerDistanceUnitPrefKey"
        static let userDefinedDistance1 = "TreadTrackerUserDefineDistance1PrefKey"
        static let userDefinedDistance2 = "TreadTrackerUserDefineDistance2PrefKey"
        static let userDefinedDistance3 = "TreadTrackerUserDefineDistance3PrefKey"
        static let userDefinedDistance4 = "TreadTrackerUserDefineDistance4PrefKey"
        static let selectedShoe = "ShoesCycleSelectedShoePrefKey"
        static let legacySelectedShoe = "TreadTrackerSelecredShoePrefKey"
        static let healthKitEnabled = "ShoeCycleHealthKitEnabled"
        static let stravaEnabled = "ShoeCycleStravaEnabledKey"
        static let firstDayOfWeek = "ShoeCycleFirstDayOfWeekKey"
        static let graphAllShoesToggle = "ShoeCycleGraphAllShoesToggle"
    }
}
