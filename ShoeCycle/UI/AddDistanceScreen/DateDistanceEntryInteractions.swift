//  DateDistanceEntryInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import SwiftUI
import CoreData

struct DateDistanceEntryState {
    var buttonMaxHeight: CGFloat?
    var showHistoryView: Bool = false
    var showFavoriteDistances: Bool = false
    var favoriteDistanceToAdd: Double = 0.0
    var showAuthorizationDeniedAlert: Bool = false
    var stravaLoading: Bool = false
    var showReachabilityAlert: Bool = false
    var showUnknownNetworkErrorAlert: Bool = false
    
    init() {}
}

struct DateDistanceEntryInteractor {
    
    enum Action {
        case viewAppeared
        case buttonMaxHeightChanged(CGFloat?)
        case showHistory
        case dismissHistory
        case showFavoriteDistances
        case dismissFavoriteDistances
        case favoriteDistanceSelected(Double)
        case addDistancePressed(runDate: Date, runDistance: String)
        case stravaLoadingChanged(Bool)
        case showAlert(AlertType)
        case dismissAlert(AlertType)
    }
    
    enum AlertType {
        case authorizationDenied
        case reachability
        case unknownNetworkError
    }
    
    private let shoe: Shoe
    private var shoeStore: ShoeStore?
    private var settings: UserSettings?
    private let distanceUtility: DistanceUtility
    private let stravaService: StravaService
    private let healthService: HealthKitService
    private let analytics: AnalyticsLogger
    
    init(shoe: Shoe,
         distanceUtility: DistanceUtility = DistanceUtility(),
         stravaService: StravaService = StravaService(),
         healthService: HealthKitService = HealthKitService(),
         analytics: AnalyticsLogger = AnalyticsFactory.sharedAnalyticsLogger()) {
        self.shoe = shoe
        self.distanceUtility = distanceUtility
        self.stravaService = stravaService
        self.healthService = healthService
        self.analytics = analytics
    }
    
    mutating func setDependencies(shoeStore: ShoeStore, settings: UserSettings) {
        self.shoeStore = shoeStore
        self.settings = settings
    }
    
    func handle(state: inout DateDistanceEntryState, action: Action) {
        switch action {
        case .viewAppeared:
            break
            
        case .buttonMaxHeightChanged(let height):
            state.buttonMaxHeight = height
            
        case .showHistory:
            analytics.logEvent(name: AnalyticsKeys.Event.showHistoryEvent, userInfo: nil)
            state.showHistoryView = true
            
        case .dismissHistory:
            state.showHistoryView = false
            
        case .showFavoriteDistances:
            guard let settings = settings else { return }
            analytics.logEvent(name: AnalyticsKeys.Event.showFavoriteDistancesEvent,
                            userInfo: [AnalyticsKeys.UserInfo.numberOfFavoritesUsedKey : settings.favoriteDistanceCount()])
            state.showFavoriteDistances = true
            
        case .dismissFavoriteDistances:
            state.showFavoriteDistances = false
            
        case .favoriteDistanceSelected(let distance):
            state.favoriteDistanceToAdd = distance
            
        case .addDistancePressed(let runDate, let runDistance):
            guard let shoeStore = shoeStore, let settings = settings else { return }
            let distance = distanceUtility.distance(from: runDistance)
            
            // Start async operation - state changes will be handled through separate actions
            Task { @MainActor in
                await handleAsynchronousDistanceAdd(distance: distance, runDate: runDate, shoeStore: shoeStore, settings: settings)
            }
            
        case .stravaLoadingChanged(let loading):
            state.stravaLoading = loading
            
        case .showAlert(let alertType):
            switch alertType {
            case .authorizationDenied:
                state.showAuthorizationDeniedAlert = true
            case .reachability:
                state.showReachabilityAlert = true
            case .unknownNetworkError:
                state.showUnknownNetworkErrorAlert = true
            }
            
        case .dismissAlert(let alertType):
            switch alertType {
            case .authorizationDenied:
                state.showAuthorizationDeniedAlert = false
            case .reachability:
                state.showReachabilityAlert = false
            case .unknownNetworkError:
                state.showUnknownNetworkErrorAlert = false
            }
        }
    }
    
    private func handleAsynchronousDistanceAdd(distance: Double, runDate: Date, shoeStore: ShoeStore, settings: UserSettings) async {
        do {
            if settings.healthKitEnabled == true {
                let shoeIdentifier = shoe.objectID.uriRepresentation().absoluteString
                let metadata = ["ShoeCycleShoeIdentifier" : shoeIdentifier]
                try await healthService.saveRun(distance: distance,
                                                date: runDate, metadata: metadata)
                analytics.logEvent(name: AnalyticsKeys.Event.healthKitEvent, userInfo: nil)
            }
            
            if settings.stravaEnabled == true {
                let activity = StravaActivity(name: "ShoeCycle Logged Run",
                                              distance: distanceUtility.stravaDistance(for: distance),
                                              startDate: runDate)
                // TODO: Handle loading state through separate mechanism
                try await stravaService.send(activity: activity)
                analytics.logEvent(name: AnalyticsKeys.Event.stravaEvent, userInfo: nil)
            }
            
            shoeStore.addHistory(to: shoe, date: runDate, distance: distance)
            handleAddDistanceAnalytics(for: shoe, distance: distance, settings: settings)
            // TODO: Handle success state through separate mechanism
        }
        catch let error {
            // TODO: Handle errors through separate mechanism
            if case HealthKitService.DomainError.healthDataSharingDenied = error {
                // Show authorization denied alert
            }
            else if case StravaService.DomainError.reachability = error {
                // Show reachability alert
            }
            else {
                // Show unknown error alert
            }
        }
    }
    
    private func handleAddDistanceAnalytics(for shoe: Shoe, distance: Double, settings: UserSettings) {
        let userInfo: [String : Any] = [ AnalyticsKeys.UserInfo.mileageNumberKey : NSNumber(value: distance),
                                         AnalyticsKeys.UserInfo.totalMileageNumberKey : NSNumber(value: shoe.totalDistance.doubleValue),
                                         AnalyticsKeys.UserInfo.mileageUnitKey : settings.distanceUnit.displayString() ]
        analytics.logEvent(name: AnalyticsKeys.Event.logMileageEvent, userInfo: userInfo)
    }
}