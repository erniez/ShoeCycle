//  DistanceUtility.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 8/2/23.
//  
//

import Foundation


struct DistanceUtility {
    private let settings = UserSettings()
    
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
    
    func distance(from string: String) -> Double {
        guard var runDistance = Double(string) else {
            print("Could not form number from string")
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
    func stravaDistance(for distance: String) -> NSNumber {
        guard var runDistance = Double(distance) else {
            print("Could not form number from string")
            return 0
        }
        return NSNumber(value: runDistance * milesToMeters)
    }
}
