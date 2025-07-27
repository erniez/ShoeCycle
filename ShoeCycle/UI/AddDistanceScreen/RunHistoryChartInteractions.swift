//  RunHistoryChartInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import SwiftUI
import CoreData

struct RunHistoryChartState {
    fileprivate(set) var graphAllShoes: Bool = false
    fileprivate(set) var maxDistance: Double = 0.0
    fileprivate(set) var xValues: [Date] = []
    fileprivate(set) var chartData: [WeeklyCollatedNew] = []
    
    init() {}
}

struct RunHistoryChartInteractor {
    
    enum Action {
        case viewAppeared
        case dataUpdated([WeeklyCollatedNew])
        case toggleGraphAllShoes
    }
    
    private let userSettings: UserSettings
    
    init(userSettings: UserSettings = UserSettings.shared) {
        self.userSettings = userSettings
    }
    
    func handle(state: inout RunHistoryChartState, action: Action) {
        switch action {
        case .viewAppeared:
            state.graphAllShoes = userSettings.graphAllShoes
            
        case .dataUpdated(let collatedHistory):
            state.chartData = collatedHistory
            state.xValues = collatedHistory.map { $0.date }
            state.maxDistance = collatedHistory.reduce(Double(0)) { max($0, $1.runDistance) }
            
        case .toggleGraphAllShoes:
            state.graphAllShoes.toggle()
            userSettings.set(graphAllShoes: state.graphAllShoes)
        }
    }
}