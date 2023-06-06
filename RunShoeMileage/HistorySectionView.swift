//  HistorySectionView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI


struct HistorySectionViewModel: Identifiable {
    let id = UUID()
    let monthDate: Date
    let runTotal: Float
    let historyViewModels: [HistoryRowViewModel]
    let shoe: Shoe
    let histories: [History]
    
    var monthString: String {
        let calendar = Calendar.current
        let monthStrings = calendar.monthSymbols
        let components = calendar.dateComponents([.month], from: monthDate)
        guard let month = components.month else {
            return "Month not found"
        }
        return monthStrings[month - 1]
    }
    
    var runTotalString: String {
        let number = NSNumber(value: runTotal)
        return NumberFormatter.decimal.string(from: number) ?? ""
    }
    
    init(shoe: Shoe, histories: [History]) {
        self.shoe = shoe
        self.monthDate = histories.first?.runDate ?? Date()
        self.runTotal = Shoe.runDistanceTotal(histories: histories)
        self.histories = histories
        self.historyViewModels = histories.map { HistoryRowViewModel(history: $0) }
    }
    
    func removeHistories(atOffsets: IndexSet) {
        let store = ShoeStore.defaultStore
        let historiesToDelete = atOffsets.map { histories[$0] }
        historiesToDelete.forEach { store.delete(history: $0) }
        // Have to save context here so that the history changes are reflected in the shoe
        // before the distance gets totaled
        store.saveContext()
        store.updateTotalDistance(shoe: shoe)
        store.saveContext()
    }
}

extension HistorySectionViewModel {
    static func listData(shoe: Shoe) -> [HistorySectionViewModel] {
        let monthlyHistories = shoe.runHistoriesByMonth(ascending: false)
        return monthlyHistories.map { HistorySectionViewModel(shoe: shoe, histories: $0) }
    }
}

struct HistorySectionView: View {
    var viewModel: HistorySectionViewModel

    var body: some View {
        Text("Total for \(viewModel.monthString): \(NumberFormatter.decimal.string(from: NSNumber(value: viewModel.runTotal)) ?? "")")
    }
    
}

struct HistorySectionView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    static var previews: some View {
        HistorySectionView(viewModel: HistorySectionViewModel(shoe: shoe, histories: shoe.runHistoriesByMonth(ascending: false)[0]))
    }
}
