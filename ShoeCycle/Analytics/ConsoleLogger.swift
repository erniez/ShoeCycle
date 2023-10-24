//  ConsoleLogger.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/9/23.
//  
//

import Foundation
import OSLog

struct ConsoleLogger: AnalyticsLogger {
    
    static let shared = FirebaseLogger()
    
    static func initializeLogger() {
        // Nothing to initialize
    }
    
    func logEvent(name: String, userInfo: [String : Any]?) {
        Logger.app.info("*** Shoecycle Analytic Event Log: \(name)")
        if let userInfo = userInfo {
            userInfo.keys.forEach({ key in
                let value = userInfo[key] ?? ""
                Logger.app.info("*** \(key): \(String(describing: value))")
            })
        }
    }
    
}
