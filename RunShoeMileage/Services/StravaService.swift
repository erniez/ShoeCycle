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
    // TODO: Need to handle refresh case now that tokens are only valid for 6 hours.
    // Example token response
    /*
     {
         "token_type": "Bearer",
         "expires_at": 1694070543,
         "expires_in": 21600,
         "refresh_token": "908d85ef52618ff512fcfbe409cb09c883994826",
         "access_token": "6580706ed4dc53eb42bc1159af74b05798056c87",
         "athlete": {
             "id": 3019584,
             "username": "ezappacosta",
             "resource_state": 2,
             "firstname": "Ernie",
             "lastname": "Zappacosta",
             "bio": "",
             "city": "San Luis Obispo",
             "state": "CA",
             "country": "United States",
             "sex": "M",
             "premium": false,
             "summit": false,
             "created_at": "2013-09-13T00:05:16Z",
             "updated_at": "2023-08-30T21:19:43Z",
             "badge_type_id": 0,
             "weight": 83.7339,
             "profile_medium": "https://dgalywyr863hv.cloudfront.net/pictures/athletes/3019584/4377862/2/medium.jpg",
             "profile": "https://dgalywyr863hv.cloudfront.net/pictures/athletes/3019584/4377862/2/large.jpg",
             "friend": null,
             "follower": null
         }
     }
     */
    let activitiesURL = URL(string: kStravaActivitiesURL)!
    let network = NetworkService(session: .shared)
    let keeper = StravaTokenKeeper()
    
    func send(activity: StravaActivity) async {
        let dto = StravaActivityDTO(activity: activity)
        do {
            let token = try keeper.accessToken()
            let _ = try await network.postJSON(dto: dto, url: activitiesURL, authToken: token)
        }
        catch {
            print("error")
        }
    }
    
}
