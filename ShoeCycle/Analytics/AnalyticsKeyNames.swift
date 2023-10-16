//  AnalyticsKeyNames.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/21/23.
//  
//

import Foundation

enum AnalyticsKeys {
    enum Event {
        static let logMileageEvent = "log_mileage"
        static let stravaEvent = "log_mileage_strava"
        static let healthKitEvent = "log_mileage_health_kit"
        static let addShoeEvent = "add_shoe"
        static let shoePictureAddedEvent = "add_shoe_picture"
        static let showHistoryEvent = "show_history"
        static let showFavoriteDistancesEvent = "show_favorite_distances"
        static let addToHOFEvent = "add_to_HOF"
        static let removeFromHOFEvent = "remove_from_HOF"
    }
    
    enum UserInfo {
        static let mileageNumberKey = "mileage"
        static let totalMileageNumberKey = "total_mileage"
        static let numberOfFavoritesUsedKey = "number_of_favorites"
        static let mileageUnitKey = "distance_unit"
    }
}
