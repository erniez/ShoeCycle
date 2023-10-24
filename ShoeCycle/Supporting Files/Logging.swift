//  Logging.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/21/23.
//  
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem = Bundle.main.bundleIdentifier!
    static let app = Logger(subsystem: subsystem, category: "app")
}
