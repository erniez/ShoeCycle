//  HistoryListView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/28/23.
//  
//

import SwiftUI
import OSLog

struct HistoryListViewModel {
    var sections: [HistorySectionViewModel] = []
    let shoeStore: ShoeStore
    let shoe: Shoe
    let yearlyTotals: [YearlyTotalDistance]
    
    let showAllShoes = true
    
    static func collatedHistoriesByYear(runsByMonth: [HistorySectionViewModel]) -> [YearlyTotalDistance] {
        var runsByYear = [YearlyTotalDistance]()
        var totalDistanceForYear: Double = 0
        let calendar = Calendar.current
        var currentYear = 0
        
        let components = calendar.dateComponents([.year], from: Date())
        currentYear = components.year ?? 0
        
        runsByMonth.forEach { runMonth in
            let components = calendar.dateComponents([.year], from: runMonth.monthDate)
            
            guard let year = components.year else {
                return
            }
            
            if year != currentYear {
                if totalDistanceForYear > 0 {
                    runsByYear.append(YearlyTotalDistance(total: totalDistanceForYear, year: currentYear))
                } else {
                    runsByYear.append(YearlyTotalDistance(total: 0, year: currentYear))
                }
                totalDistanceForYear = 0
            }
            totalDistanceForYear += runMonth.runTotal
            currentYear = year
        }
        runsByYear.append(YearlyTotalDistance(total: totalDistanceForYear, year: currentYear))
        return runsByYear
    }
    
    init(shoeStore: ShoeStore, shoe: Shoe) {
        self.shoeStore = shoeStore
        self.shoe = shoe
        var monthlyHistories: [[History]] = []
        if showAllShoes {
            var allHistories: Set<History> = []
            for shoe in shoeStore.allShoes {
                allHistories.formUnion(shoe.history)
            }
            monthlyHistories = allHistories.historiesByMonth(ascending: false)
        } else {
            monthlyHistories = shoe.history.historiesByMonth(ascending: false)
        }
        self.sections =  monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
        self.yearlyTotals = Self.collatedHistoriesByYear(runsByMonth: self.sections)
    }
    
    func removeHistories(from sectionViewModel: HistorySectionViewModel, atOffsets: IndexSet) {
        guard sections.contains(sectionViewModel) else {
            Logger.app.error("Error: Trying to remove histories from a section that doesn't exist in view model")
            return
        }
        let historiesToDelete = atOffsets.map { sectionViewModel.histories[$0] }
        historiesToDelete.forEach { shoeStore.delete(history: $0) }
        // Have to save context here so that the history changes are reflected in the shoe
        // before the distance gets totaled
        shoeStore.saveContext()
        shoeStore.updateTotalDistance(shoe: shoe)
        shoeStore.saveContext()
        if showAllShoes {
            shoeStore.updateAllShoes()
        } else {
            shoeStore.updateActiveShoes()
        }
    }
}

struct HistoryListView: View {
    var listData: HistoryListViewModel
    @EnvironmentObject var settings: UserSettings
    @Environment(\.dismiss) var dismiss
    @State var showMailComposer = false
    let analytics = AnalyticsFactory.sharedAnalyticsLogger()
    
    var body: some View {
        VStack {
            HStack {
                if MailComposeView.canSendMail() == true {
                    Button("Email Data") {
                        analytics.logEvent(name: AnalyticsKeys.Event.emailShoeTapped, userInfo: nil)
                        showMailComposer = true
                    }
                }
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            .padding([.horizontal], 24)
            .padding([.bottom], 16)
            HStack {
                Text("Run Date")
                Spacer()
                Text("Distance(\(settings.distanceUnit.displayString()))")
            }
            .font(.headline)
            .padding([.horizontal], 24)
            List {
                ForEach(listData.sections) { sectionViewModel in
                    Section(header: HistorySectionView(viewModel: sectionViewModel)) {
                        ForEach(sectionViewModel.historyViewModels) { rowViewModel in
                            HistoryRowView(viewModel: rowViewModel)
                        }
                        .onDelete { indexSet in
                            listData.removeHistories(from: sectionViewModel, atOffsets: indexSet)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .dynamicTypeSize(.medium ... .xLarge)
        .fullScreenCover(isPresented: $showMailComposer, content: {
            MailComposeView(shoe: listData.shoe)
                .ignoresSafeArea(edges: [.bottom])
        })
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static let shoeStore = ShoeStore()
    static var listData: HistoryListViewModel {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        return HistoryListViewModel(shoeStore: shoeStore, shoe: shoe)
    }
    
    static var previews: some View {
        HistoryListView(listData: listData)
    }
}
