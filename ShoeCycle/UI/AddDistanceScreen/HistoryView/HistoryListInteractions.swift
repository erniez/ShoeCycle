//  HistoryListInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import SwiftUI
import CoreData

struct HistoryListState {
    fileprivate(set) var sections: [HistorySectionViewModel] = []
    fileprivate(set) var yearlyTotals: YearlyTotalDistance = [:]
    fileprivate(set) var showMailComposer: Bool = false
    
    init() {}
}

struct HistoryListInteractor {
    
    enum Action {
        case viewAppeared
        case showMailComposer
        case dismissMailComposer
        case removeHistories(from: HistorySectionViewModel, atOffsets: IndexSet)
    }
    
    private let shoeStore: ShoeStore
    private let shoe: Shoe
    private let settings: UserSettings
    private let analytics: AnalyticsLogger
    
    init(shoeStore: ShoeStore, shoe: Shoe, settings: UserSettings = UserSettings.shared, analytics: AnalyticsLogger = AnalyticsFactory.sharedAnalyticsLogger()) {
        self.shoeStore = shoeStore
        self.shoe = shoe
        self.settings = settings
        self.analytics = analytics
    }
    
    func handle(state: inout HistoryListState, action: Action) {
        switch action {
        case .viewAppeared:
            loadHistoryData(state: &state)
            
        case .showMailComposer:
            analytics.logEvent(name: AnalyticsKeys.Event.emailShoeTapped, userInfo: nil)
            state.showMailComposer = true
            
        case .dismissMailComposer:
            state.showMailComposer = false
            
        case .removeHistories(let sectionViewModel, let indexSet):
            guard state.sections.contains(sectionViewModel) else {
                return
            }
            
            let historiesToDelete = indexSet.map { sectionViewModel.histories[$0] }
            historiesToDelete.forEach { shoeStore.delete(history: $0) }
            
            // Save context and update totals
            shoeStore.saveContext()
            shoeStore.updateTotalDistance(shoe: shoe)
            shoeStore.saveContext()
            
            if settings.graphAllShoes {
                shoeStore.updateAllShoes()
            } else {
                shoeStore.updateActiveShoes()
            }
            
            // Reload data to reflect changes
            loadHistoryData(state: &state)
        }
    }
    
    private func loadHistoryData(state: inout HistoryListState) {
        var monthlyHistories: [[History]] = []
        
        if settings.graphAllShoes {
            var allHistories: Set<History> = []
            for shoe in shoeStore.allShoes {
                allHistories.formUnion(shoe.history)
            }
            monthlyHistories = allHistories.historiesByMonth(ascending: false)
        } else {
            monthlyHistories = shoe.history.historiesByMonth(ascending: false)
        }
        
        let interimSections = monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        state.yearlyTotals = HistoryListViewModel.collatedHistoriesByYear(runsByMonth: interimSections)
        state.sections = HistorySectionViewModel.populate(yearlyTotals: state.yearlyTotals, for: interimSections)
    }
}