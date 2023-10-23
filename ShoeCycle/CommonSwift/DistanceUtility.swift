//  DistanceUtility.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 8/2/23.
//  
//

import Foundation
import OSLog


struct DistanceUtility {
    private let settings = UserSettings.shared
    
    private let milesToKilometers = 1.609344
    private let milesToMeters = 1609.34
    private let kilometersToMiles = 0.621371
    private let formatter = NumberFormatter.decimal
    
    func displayString(for distance: NSNumber) -> String {
        var runDistance = distance.doubleValue
        if settings.distanceUnit == .km {
            runDistance = runDistance * milesToKilometers
        }
        
        return formatter.string(from: NSNumber(value: runDistance)) ?? ""
    }
    
    func displayString(for distance: Double) -> String {
        let runDistance = self.distance(from: distance)
        return formatter.string(from: NSNumber(value: runDistance)) ?? ""
    }
    
    func favoriteDistanceDisplayString(for distance: Double) -> String {
        guard distance > 0 else {
            return ""
        }
        return displayString(for: distance)
    }
    
    func distance(from string: String) -> Double {
        guard var runDistance = Double(string) else {
            // We don't want to show an error for an empty string.
            if string.count > 0 {
                Logger.app.error("Could not form number from string")
            }
            return 0
        }
        
        if settings.distanceUnit == .km {
            runDistance = runDistance * kilometersToMiles
        }
        
        return runDistance
    }
    
    func distance(from miles: Double) -> Double {
        var runDistance = miles
        if settings.distanceUnit == .km {
            runDistance = runDistance * milesToKilometers
        }
        return runDistance
    }
    
    // Strava expects distance in meters. This apps treats distance in miles, hence the conversion without taking into account user settings.
    func stravaDistance(for miles: Double) -> NSNumber {
        return NSNumber(value: miles * milesToMeters)
    }
}
