//  StravaInteractionViewController.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/9/22.
//  
//

import Foundation
import AuthenticationServices
import MBProgressHUD

class StravaInteractionViewController: UIViewController {
    var session: URLSession = .shared
    @objc var completion: ((Bool, NSError?) -> Void)?

    private var authSession: ASWebAuthenticationSession?

    private let kStravaClientID = "4002"
    private let kStravaClientIDkey = "client_id"
    private let kStravaSecret = "558112ea963c3427a387549a3361bd6677083ff9" // Not valid anymore
    private let kStravaSecretKey = "client_secret"
    private lazy var hud = MBProgressHUD(view: view)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let targetURL = URL(string: kStravaOAuthURL) else {
            return
        }

        authSession = ASWebAuthenticationSession(url: targetURL, callbackURLScheme: "ShoeCycle") { [weak self] url, error in
            if let url = url {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                components?.queryItems?.forEach({ queryItem in
                    if queryItem.name == "code", let token = queryItem.value {
                        self?.didReceiveTemporaryToken(token)
                    }
                })
            }
            if let error = error {
                let domainError = NSError(domain: "Authentication", code: 1, userInfo: ["error": error])
                self?.dismissInteractionViewController(success: false, error: domainError)
            }
        }
        authSession?.prefersEphemeralWebBrowserSession = true
        authSession?.presentationContextProvider = self
        authSession?.start()
    }

    func didReceiveTemporaryToken(_ token: String) {
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
        session.dataTask(with: request) { [weak self] data, _, error in
            if let data = data,
               let dataDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let accessToken = dataDict["access_token"] {
                UserDefaults.standard.set(accessToken, forKey: kStravaAccessToken)
                DispatchQueue.main.async {
                    self?.dismissInteractionViewController(success: true, error: nil)
                }
            } else {
                print("oops! something went wrong!")
            }
        }.resume()
    }

    func dismissInteractionViewController(success: Bool, error: NSError?) {
        authSession?.cancel()
        dismiss(animated: true) { [weak self] in
            self?.completion?(success, error)
        }
    }
}

extension StravaInteractionViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window!
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
