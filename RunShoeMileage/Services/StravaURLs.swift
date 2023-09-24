//  StravaConstants.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/23/23.
//  
//

import Foundation

/**
 URL Constants used in Strava API interactions
 */
enum StravaURLs {
    static let oauthURL = "https://www.strava.com/oauth/mobile/authorize?client_id=4002&redirect_uri=ShoeCycle%3A%2F%2Fshoecycleapp.com/callback%2F&response_type=code&approval_prompt=auto&scope=activity%3Awrite%2Cread&state=test"
    static let oauthRefreshURL = "https://www.strava.com/oauth/token"
    static let actvitiesURL = "https://www.strava.com/api/v3/activities"
}

/*
TODO: Move these keys to a secrets file that isn't part of the repo.
TODO: If I'm feeling particulary motivated, use obfuscation techniques
TODO: for further protection.
 */
/**
 Constants used in Strava API Authentication
 */
enum StravaKeys {
    static let clientIDValue = "4002"
    static let clientIDkey = "client_id"
    static let secretValue = "558112ea963c3427a387549a3361bd6677083ff9"
    static let secretKey = "client_secret"
}

