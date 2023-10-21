//  AnalyticsFactory.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/21/23.
//  
//

import Foundation


struct AnalyticsFactory {
    static func sharedAnalyticsLogger() -> AnalyticsLogger {
        #if DEBUG
        return ConsoleLogger()
        #else
        return FirebaseLogger.shared
        #endif
    }
    static func initializeAnalytics() {
        #if DEBUG
        ConsoleLogger.initializeLogger()
        #else
        FirebaseLogger.initializeLogger()
        #endif
    }
}
