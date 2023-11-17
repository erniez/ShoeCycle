//  ShoeCycleApp.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/21/23.
//  
//

import SwiftUI

@main
struct ShoeCycleApp: App {
    @ObservedObject var tsCoordinator: TSCoordinator
    
    init() {
        AnalyticsFactory.initializeAnalytics()
        tsCoordinator = TSCoordinator.shared
        tsCoordinator.start()
    }
    
    var body: some Scene {
        WindowGroup {
            if tsCoordinator.currentState == .launch {
                let _ = print("Launch State")
                TSView(coordinator: tsCoordinator)
            }
            else if tsCoordinator.currentState == .loadDatabase {
                let _ = print("Database State")
                TSView(coordinator: tsCoordinator, shoeStore: ShoeStore())
            }
            else {
                let _ = print("App State")
                AppView()
            }
        }
    }
}
