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

struct StravaTokenKeeper: ThrowingService {
    enum DomainError: Error {
        case unknown
        case jsonDecoding
        case reachability
    }
    
    private let network = NetworkService()
    
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
            catch is DecodingError {
                throw DomainError.jsonDecoding
            }
            catch let error as NetworkService.DomainError {
                if case NetworkService.DomainError.reachability = error {
                    throw DomainError.reachability
                }
                throw DomainError.unknown
            }
            catch {
                throw DomainError.unknown
            }
        }
        throw DomainError.unknown
    }
    
    func accessToken() async throws -> String {
        return try await stravaToken().token
    }
    
    func eraseToken() {
        UserDefaults.standard.set(nil, forKey: UserSettings.StorageKey.stravaToken)
    }
    
    private func refresh(token: StravaToken) async throws -> StravaToken {
        let url = URL(string: StravaURLs.oauthRefreshURL)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            StravaKeys.clientIDkey: StravaKeys.clientIDValue,
            StravaKeys.secretKey: StravaKeys.secretValue,
            "refresh_token": token.refreshToken,
            "grant_type": "refresh_token"
        ]
        guard let bodyData = parameters.percentEncoded() else {
            throw DomainError.unknown
        }
        let data = try await network.post(request: request, data: bodyData)
        let newToken: StravaToken = try data.jsonDecode()
        store(token: newToken)
        return newToken
    }
}
