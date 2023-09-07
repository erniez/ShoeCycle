//  StravaTokenKeeper.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/7/23.
//  
//

import Foundation


struct StravaToken: Codable {
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case refreshToken = "refresh_token"
        case expiration = "expires_at"
    }
    
    let token: String
    let refreshToken: String
    let expiration: Int
    var isExpired: Bool {
        Date().timeIntervalSince1970 > TimeInterval(expiration)
    }
}

struct StravaTokenKeeper {
    private let network = NetworkService()
    
    // TODO: find common storage for creds
    private let kStravaClientID = "4002"
    private let kStravaClientIDkey = "client_id"
    private let kStravaSecret = "558112ea963c3427a387549a3361bd6677083ff9"
    private let kStravaSecretKey = "client_secret"
    
    func store(token: StravaToken) {
        if let tokenData = try? token.jsonEncode() {
            UserDefaults.standard.set(tokenData, forKey: UserSettings.StorageKey.stravaToken)
        }
    }
    
    func stravaToken() async throws -> StravaToken {
        if let tokenData = UserDefaults.standard.object(forKey: UserSettings.StorageKey.stravaToken) as? Data {
            do {
                var stravaToken: StravaToken = try tokenData.jsonDecode()
                if stravaToken.isExpired == true {
                    stravaToken = try await refresh(token: stravaToken)
                }
                return stravaToken
            }
            catch(let error as DecodingError) {
                throw NetworkError.jsonDecodingError(error: error)
            }
            catch {
                throw NetworkError.unknownError
            }
        }
        throw NetworkError.unknownError
    }
    
    func accessToken() async throws -> String {
        return try await stravaToken().token
    }
    
    func eraseToken() {
        UserDefaults.standard.set(nil, forKey: UserSettings.StorageKey.stravaToken)
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
