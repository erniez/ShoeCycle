//  HistorySectionView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/6/23.
//  
//

import SwiftUI


struct HistorySectionViewModel: Identifiable, Equatable {
    static func == (lhs: HistorySectionViewModel, rhs: HistorySectionViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    let id = UUID()
    let monthDate: Date
    let runTotal: Double
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
        self.runTotal = histories.total(initialValue: 0.0, for: \.runDistance.doubleValue)
        self.histories = histories
        self.historyViewModels = histories.map { HistoryRowViewModel(history: $0) }
    }
}

struct HistorySectionView: View {
    var viewModel: HistorySectionViewModel
    let distanceUtility = DistanceUtility()
    
    var runTotalString: AttributedString {
        var runTotal = AttributedString(distanceUtility.displayString(for: viewModel.runTotal))
        runTotal.font = .title3
        runTotal.foregroundColor = .shoeCycleOrange
        return runTotal
    }
    
    var monthTotalString: AttributedString {
        var monthTotalString = AttributedString("Total for \(viewModel.monthString):  ")
        monthTotalString.font = .subheadline
        monthTotalString.foregroundColor = .shoeCycleOrange
        return monthTotalString
    }

    var body: some View {
        Text(monthTotalString + runTotalString)
    }
    
}

struct HistorySectionView_Previews: PreviewProvider {
    static let shoe = MockShoeGenerator().generateNewShoeWithData()
    static var previews: some View {
        HistorySectionView(viewModel: HistorySectionViewModel(shoe: shoe, histories: shoe.history.historiesByMonth(ascending: false)[0]))
    }
}
