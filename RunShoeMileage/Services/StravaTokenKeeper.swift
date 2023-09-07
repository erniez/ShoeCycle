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
    func store(token: StravaToken) {
        if let tokenData = try? token.jsonEncode() {
            UserDefaults.standard.set(tokenData, forKey: UserSettings.StorageKey.stravaToken)
        }
    }
    
    func accessToken() throws -> String {
        if let tokenData = UserDefaults.standard.object(forKey: UserSettings.StorageKey.stravaToken) as? Data {
            do {
                let stravaToken: StravaToken = try tokenData.jsonDecode()
                return stravaToken.token
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
    
    func eraseToken() {
        UserDefaults.standard.set(nil, forKey: UserSettings.StorageKey.stravaToken)
    }
}
