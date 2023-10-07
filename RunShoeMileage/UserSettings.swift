//  UserSettings.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import Foundation

class UserSettings: ObservableObject {
    
    @propertyWrapper struct FavoriteDistance {
        var wrappedValue: Double {
            get {
                UserDefaults.standard.double(forKey: key)
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
        // Have to start numbering at 1 because that's what the calendar weekday units do.
        case sunday = 1
        case monday
    }
    
    // I'm using a shared object here because there are a number of places that I need access
    // to the settings within the initializer of views. Environment Objects are not available
    // in the initializer, so I decided to go with the singleton instead of instantiating a 
    // bunch of short lived settings objects all over the code base.
    static let shared = UserSettings()
    
    @Published private(set) var distanceUnit: DistanceUnit
    @Published private(set) var firstDayOfWeek: FirstDayOfWeek
    @Published private(set) var stravaEnabled: Bool
    @Published private(set) var healthKitEnabled: Bool
    @Published private(set) var selectedShoeURL: URL?
    
    private let defaults = UserDefaults.standard
    
    init() {
        distanceUnit = DistanceUnit(rawValue: defaults.integer(forKey: StorageKey.distanceUnit)) ?? .miles
        firstDayOfWeek = FirstDayOfWeek(rawValue: defaults.integer(forKey: StorageKey.firstDayOfWeek)) ?? .monday
        stravaEnabled = defaults.bool(forKey: StorageKey.stravaEnabled)
        selectedShoeURL = defaults.url(forKey: StorageKey.selectedShoe)
        let healthKitService = HealthKitService()
        // Health App access can be turned off outside the app, so we need to check when we init UserSettings.
        // If access is granted, then the ShoeCycle app setting will override the device settings.
        if healthKitService.authorizationStatus == .sharingAuthorized {
            healthKitEnabled = defaults.bool(forKey: StorageKey.healthKitEnabled)
        }
        else {
            healthKitEnabled = false
            defaults.set(false, forKey: StorageKey.healthKitEnabled)
        }
        
    }
    
    func setSelected(shoeUrl: URL?) {
        if let url = shoeUrl {
            selectedShoeURL = url
            defaults.set(url, forKey: StorageKey.selectedShoe)
        }
        else {
            selectedShoeURL = nil
            defaults.removeObject(forKey: StorageKey.selectedShoe)
        }
    }
    
    func isSelected(shoeURL: URL) -> Bool {
        if let selectedShoe = selectedShoeURL {
            if shoeURL == selectedShoe {
                return true
            }
            else {
                return false
            }
        }
        return false
    }
    
    func set(distanceUnit: DistanceUnit) {
        defaults.set(distanceUnit.rawValue, forKey: StorageKey.distanceUnit)
        self.distanceUnit = distanceUnit
    }
    
    func set(firstDayOfWeek: FirstDayOfWeek) {
        defaults.set(firstDayOfWeek.rawValue, forKey: StorageKey.firstDayOfWeek)
        self.firstDayOfWeek = firstDayOfWeek
    }
    
    func set(stravaEnabled: Bool) {
        self.stravaEnabled = stravaEnabled
        defaults.set(stravaEnabled, forKey: StorageKey.stravaEnabled)
    }
    
    func set(healthKitEnabled: Bool) {
        self.healthKitEnabled = healthKitEnabled
        defaults.set(healthKitEnabled, forKey: StorageKey.healthKitEnabled)
    }
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance1)
    var favorite1: Double
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance2)
    var favorite2: Double
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance3)
    var favorite3: Double
    
    @FavoriteDistance(key: StorageKey.userDefinedDistance4)
    var favorite4: Double
    
    /// Count of all favorite distances used. For analytics use only
    func favoriteDistanceCount() -> Int {
        var count = 0
        if favorite1 > 0 { count += 1 }
        if favorite2 > 0 { count += 1 }
        if favorite3 > 0 { count += 1 }
        if favorite4 > 0 { count += 1 }
        return count
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
        static let stravaAccessToken = "ShoeCycleStravaAccessToken"
        static let stravaToken = "ShoeCycleStravaToken"
    }
}
