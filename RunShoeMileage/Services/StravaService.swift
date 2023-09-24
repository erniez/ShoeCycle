//  StravaService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/5/23.
//  
//

import Foundation


/// Activity used to send to the Strava API
struct StravaActivity: Codable {
    enum CodingKeys: String, CodingKey {
        case elapsedTime = "elapsed_time"
        case startDateLocal = "start_date_local"
        case name
        case type
        case distance
    }
    
    let name: String
    let type: String = "run"
    let distance: String // in meters
    let elapsedTime: String = "0.0"
    let startDateLocal: String
    
    /**
     Activity used to send to the Strava API
     
     - Parameters:
        - name: Name to appear in the title of the activity
        - distance: Distance as an NSNumber in meters
        - startDate: Date of the run
     */
    init(name: String, distance: NSNumber, startDate: Date) {
        self.name = name
        self.distance = distance.stringValue
        self.startDateLocal = DateFormatter.UTCDate.string(from: startDate)
    }
}

/// Service to interact with the Strava API
struct StravaService: ThrowingService {
    enum DomainError: Error {
        case unknown
        case reachability
    }
    
    private let activitiesURL = URL(string: StravaURLs.actvitiesURL)!
    private let network = NetworkService()
    private let keeper = StravaTokenKeeper()
    
    /**
     Send Strava activity to the API.
     - Parameter activity: Strave activity, mostly just used for distance. Distance is defined in meters.
     - Throws: StravaService.DomainError
     */
    func send(activity: StravaActivity) async throws {
        do {
            let token = try await keeper.accessToken()
            let _ = try await network.postJSON(dto: activity, url: activitiesURL, authToken: token)
        }
        catch let error as NetworkService.DomainError {
            if case .reachability = error { throw DomainError.reachability }
            throw DomainError.unknown
        }
        catch let error as StravaTokenKeeper.DomainError {
            if case .reachability = error { throw DomainError.reachability }
            throw DomainError.unknown
        }
        catch {
            throw DomainError.unknown
        }
    }
    
}
