//  AnalyticsFactory.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/21/23.
//  
//

import Foundation


struct AnalyticsFactory {
    static func sharedAnalyticsLogger() -> AnalyticsLogger {
        return FirebaseLogger.shared
    }
}
