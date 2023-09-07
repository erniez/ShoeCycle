//  StravaInteractor.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/5/23.
//  
//

import SwiftUI
import AuthenticationServices

struct StravaInteractor {
    private let kStravaClientID = "4002"
    private let kStravaClientIDkey = "client_id"
    private let kStravaSecret = "558112ea963c3427a387549a3361bd6677083ff9"
    private let kStravaSecretKey = "client_secret"
    let settings: UserSettings
    private let urlSession: URLSession = .shared
    
    init(settings: UserSettings) {
        self.settings = settings
    }
    
    func fetchToken(with session: WebAuthenticationSession) async -> Bool {
        do {
            let urlWithToken = try await session.authenticate(
                using: URL(string: kStravaOAuthURL)!,
                callbackURLScheme: "ShoeCycle",
                preferredBrowserSession: .ephemeral)
            let components = URLComponents(url: urlWithToken, resolvingAgainstBaseURL: false)
            var tokenString: String?
            components?.queryItems?.forEach({ queryItem in
                if queryItem.name == "code", let token = queryItem.value {
                    tokenString = token
                }
            })
            if let token = tokenString {
                try await didReceiveTemporaryToken(token, session: session)
                return true
            }
            else {
                return false
            }
        }
        catch let(error as NSError)
        {
            if error.domain == "com.apple.AuthenticationServices.WebAuthenticationSession",
               error.code == 1 {
                print("User cancelled web login flow")
            }
            else {
                print("oops! something went wrong! \(error)")
            }
            return false
        }
        catch {
            return false
        }
    }
    
    func didReceiveTemporaryToken(_ token: String, session: WebAuthenticationSession) async throws {
        let keeper = StravaTokenKeeper()
        let url = URL(string: "https://www.strava.com/oauth/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            kStravaClientIDkey: kStravaClientID,
            kStravaSecretKey: kStravaSecret,
            "code": token,
            "grant_type": "authorization_code"
        ]
        request.httpBody = parameters.percentEncoded()
        let (data, _) = try await urlSession.data(for: request)
        if let token: StravaToken = try? data.jsonDecode() {
            await MainActor.run(body: {
                keeper.store(token: token)
                settings.set(stravaAccessToken: token)
            })
        }
        else {
            print("oops! something went wrong!")
            throw NSError(domain: "Strava Web Login", code: 0)
        }
    }
    
    func resetStravaToken() {
        // currently, no async case is needed
        settings.set(stravaAccessToken: nil)
    }
    
}
