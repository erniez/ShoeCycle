//  AnalyticsLogger.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/21/23.
//  
//

import Foundation

protocol AnalyticsLogger {
    static func initializeLogger()
    func logEvent(name: String, userInfo: [String: Any]?)
}
