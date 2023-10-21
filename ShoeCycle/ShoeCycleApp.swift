//  ShoeCycleApp.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/21/23.
//  
//

import SwiftUI

@main
struct ShoeCycleApp: App {
    
    init() {
        AnalyticsFactory.initializeAnalytics()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView()
        }
    }
}
