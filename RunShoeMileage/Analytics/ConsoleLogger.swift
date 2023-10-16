//  ConsoleLogger.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/9/23.
//  
//

import Foundation

struct ConsoleLogger: AnalyticsLogger {
    
    static let shared = FirebaseLogger()
    
    static func initializeLogger() {
        // Nothing to initialize
    }
    
    func logEvent(name: String, userInfo: [String : Any]?) {
        print("*** Shoecycle Analytic Event Log: \(name)")
        if let userInfo = userInfo {
            userInfo.keys.forEach({ key in
                print("*** \(key): \(userInfo[key] ?? "")")
            })
        }
    }
    
}
