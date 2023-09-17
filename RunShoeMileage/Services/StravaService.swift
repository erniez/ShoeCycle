//  StravaService.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/5/23.
//  
//

import Foundation

struct StravaActivityDTO: Codable {
    let name: String
    let elapsed_time: String
    let distance: String
    let start_date_local: String
    let type: String
    
    init(activity: StravaActivity) {
        name = activity.name
        elapsed_time = activity.elapsedTime.stringValue
        distance = activity.distance.stringValue
        start_date_local = activity.startDateLocal
        type = activity.type
    }
}

struct StravaActivity {
    let name: String
    let type = "run"
    let distance: NSNumber // in meters
    let elapsedTime: NSNumber = (0)
    let startDate: Date
    var startDateLocal: String {
        DateFormatter.UTCDate.string(from: startDate)
    }
}

struct StravaService {
    enum ServiceError: Error {
        case unknown
        case reachability
    }
    
    let activitiesURL = URL(string: kStravaActivitiesURL)!
    let network = NetworkService()
    let keeper = StravaTokenKeeper()
    
    private let kStravaClientID = "4002"
    private let kStravaClientIDkey = "client_id"
    private let kStravaSecret = "558112ea963c3427a387549a3361bd6677083ff9"
    private let kStravaSecretKey = "client_secret"
    
    func send(activity: StravaActivity) async throws {
        let dto = StravaActivityDTO(activity: activity)
        do {
            let token = try await keeper.accessToken()
            let _ = try await network.postJSON(dto: dto, url: activitiesURL, authToken: token)
        }
        catch let error as NetworkService.ServiceError {
            if case .reachability = error { throw ServiceError.reachability }
            throw ServiceError.unknown
        }
        catch let error as StravaTokenKeeper.KeeperError {
            if case .reachability = error { throw ServiceError.reachability }
            throw ServiceError.unknown
        }
        catch {
            throw ServiceError.unknown
        }
    }
    
}
