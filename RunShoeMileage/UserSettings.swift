//  UserSettings.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import Foundation

class UserSettings: ObservableObject {
    @Published private(set) var distanceUnit: DistanceUnit
    
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
            else {
                settings.removeObject(forKey: StorageKey.selectedShoe)
            }
        }
    }
       
    enum DistanceUnit: Int, Identifiable {
        var id: Self { self }
        
        case miles, km
        
        func displayString() -> String {
            switch self {
            case .miles: return "miles"
            case .km: return "km"
            }
        }
    }
    
    enum FirstDayOfWeek: Int {
        case sunday = 1
        case monday
    }
    
    @propertyWrapper struct FavoriteDistance {
        var wrappedValue: Float {
            get {
                UserDefaults.standard.float(forKey: key)
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
        private let key: String
        private let formatter = NumberFormatter.decimal
        
        init(key: String) {
            self.key = key
        }
        
        var projectedValue: String? {
            if wrappedValue > 0 {
                return formatter.string(from: NSNumber(value: wrappedValue))
            }
            return nil
        }
    }
    
    init() {
        distanceUnit = DistanceUnit(rawValue: UserDefaults.standard.integer(forKey: StorageKey.distanceUnit)) ?? .miles
    }
    
    func set(distanceUnit: DistanceUnit) {
        settings.set(distanceUnit.rawValue, forKey: StorageKey.distanceUnit)
        self.distanceUnit = distanceUnit
    }
    
    var firstDayOfWeek: FirstDayOfWeek {
        get {
            FirstDayOfWeek(rawValue: settings.integer(forKey: StorageKey.firstDayOfWeek)) ?? .monday
        }
        set {
            settings.set(newValue.rawValue, forKey: StorageKey.firstDayOfWeek)
        }
    }
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance1)
    var favorite1: Float
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance2)
    var favorite2: Float
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance3)
    var favorite3: Float
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance4)
    var favorite4: Float
    
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
