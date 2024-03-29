//  StravaInteractor.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/5/23.
//  
//

import SwiftUI
import AuthenticationServices
import OSLog

struct StravaInteractor {
    let settings: UserSettings
    private let urlSession: URLSession = .shared
    private let stravaTokenKeeper = StravaTokenKeeper()
    private let stravaSecretKeyFactory: SecretKeyFactory = .strava
    
    init(settings: UserSettings) {
        self.settings = settings
    }
    
    func fetchToken(with session: WebAuthenticationSession) async -> Bool {
        do {
            let urlWithToken = try await session.authenticate(
                using: URL(string: StravaURLs.oauthURL)!,
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
                Logger.app.info("User cancelled web login flow")
            }
            else {
                Logger.app.error("oops! something went wrong! \(error)")
            }
            return false
        }
        catch {
            return false
        }
    }
    
    // TODO: move this to Strava service or TokenKeeper
    func didReceiveTemporaryToken(_ token: String, session: WebAuthenticationSession) async throws {
        let keeper = StravaTokenKeeper()
        let url = URL(string: "https://www.strava.com/oauth/token")!
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        let parameters: [String: Any] = [
            StravaKeys.clientIDkey: StravaKeys.clientIDValue,
            StravaKeys.secretKey: stravaSecretKeyFactory.getClearString()
            ,
            "code": token,
            "grant_type": "authorization_code"
        ]
        request.httpBody = parameters.percentEncoded()
        let (data, _) = try await urlSession.data(for: request)
        if let token: StravaToken = try? data.jsonDecode() {
            await MainActor.run(body: {
                keeper.store(token: token)
                settings.set(stravaEnabled: true)
            })
        }
        else {
            settings.set(stravaEnabled: false)
            resetStravaToken()
            Logger.app.error("oops! something went wrong!")
            throw NSError(domain: "Strava Web Login", code: 0)
        }
    }
    
    func resetStravaToken() {
        stravaTokenKeeper.eraseToken()
    }
    
}
