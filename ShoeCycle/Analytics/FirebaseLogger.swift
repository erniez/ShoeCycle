//  FirebaseLogger.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/21/23.
//  
//

import Foundation
import Firebase


struct FirebaseLogger: AnalyticsLogger {
    
    static let shared = FirebaseLogger()
    
    static func initializeLogger() {
        FirebaseApp.configure()
    }
    
    func logEvent(name: String, userInfo: [String : Any]?) {
        Analytics.logEvent(name, parameters: userInfo)
    }
    
}
