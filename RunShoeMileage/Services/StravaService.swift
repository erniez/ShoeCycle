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
    
    private let activitiesURL = URL(string: StravaConstants.actvitiesURL)!
    private let network = NetworkService()
    private let keeper = StravaTokenKeeper()
    
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
