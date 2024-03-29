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

/// Strava Token storage and management
struct StravaTokenKeeper: ThrowingService {
    enum DomainError: Error {
        case unknown
        case jsonDecoding
        case reachability
    }
    
    private let network: any RESTService
    private let stravaSecretKeyFactory: SecretKeyFactory = .strava
    
    /**
     Initialize the StravaTokenKeeper
     - Parameter networkService: Any object that conforms to RESTService. Defaults to NetworkService().
     */
    init(networkService: any RESTService = NetworkService()) {
        // Allows for dependency injection
        network = networkService
    }
    
    /**
     Store token in User Defaults
     - Parameter token: The StravaToken to store
     */
    func store(token: StravaToken) {
        if let tokenData = try? token.jsonEncode() {
            UserDefaults.standard.set(tokenData, forKey: UserSettings.StorageKey.stravaToken)
        }
    }
    
    /**
     Grab the Strava token in storage, or reach out to the network and fetch, if necessary
     - Returns: The token as a StravaToken object
     */
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
    
    /**
     Grab the Strava token in storage, or reach out to the network and fetch, if necessary
     - Returns: The token in String format
     */
    func accessToken() async throws -> String {
        return try await stravaToken().token
    }
    
    /// Delete the token from UserDefults
    func eraseToken() {
        UserDefaults.standard.set(nil, forKey: UserSettings.StorageKey.stravaToken)
    }
    
    /**
     Refresh the Strava token via the api
     - Parameter token: Strava token to refresh
     - Returns: New StravaToken object
     - Throws: Domain Error
     */
    private func refresh(token: StravaToken) async throws -> StravaToken {
        let url = URL(string: StravaURLs.oauthRefreshURL)!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            StravaKeys.clientIDkey: StravaKeys.clientIDValue,
            StravaKeys.secretKey: stravaSecretKeyFactory.getClearString(),
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
