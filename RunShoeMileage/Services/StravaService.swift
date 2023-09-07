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
    let activitiesURL = URL(string: kStravaActivitiesURL)!
    let network = NetworkService()
    let keeper = StravaTokenKeeper()
    
    private let kStravaClientID = "4002"
    private let kStravaClientIDkey = "client_id"
    private let kStravaSecret = "558112ea963c3427a387549a3361bd6677083ff9"
    private let kStravaSecretKey = "client_secret"
    
    func send(activity: StravaActivity) async {
        let dto = StravaActivityDTO(activity: activity)
        do {
            let token = try await keeper.accessToken()
            let _ = try await network.postJSON(dto: dto, url: activitiesURL, authToken: token)
        }
        catch {
            print("error")
        }
    }
    
    private func refresh(token: StravaToken) async throws -> StravaToken {
        let url = URL(string: "https://www.strava.com/oauth/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            kStravaClientIDkey: kStravaClientID,
            kStravaSecretKey: kStravaSecret,
            "refresh_token": token.refreshToken,
            "grant_type": "refresh_token"
        ]
        guard let bodyData = parameters.percentEncoded() else {
            throw NetworkError.unknownError
        }
        let data = try await network.post(request: request, data: bodyData)
        let newToken: StravaToken = try data.jsonDecode()
        return newToken
    }
    
}
