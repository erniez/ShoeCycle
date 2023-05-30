//  HistoryListView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/28/23.
//  
//

import SwiftUI

struct HistoryListViewModel: Identifiable {
    var id = UUID()
    let monthDate: Date
    let runTotal: Float
    let histories: [HistoryRowViewModel]
    
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
    
    init(monthDate: Date, runTotal: Float, histories: [HistoryRowViewModel]) {
        self.monthDate = monthDate
        self.runTotal = runTotal
        self.histories = histories
    }
    
    init(histories:[History]) {
        self.monthDate = histories.first?.runDate ?? Date()
        self.runTotal = Shoe.runDistanceTotal(histories: histories)
        self.histories = histories.map { HistoryRowViewModel(history: $0) }
    }
}

struct HistoryListView: View {
    let listData: [HistoryListViewModel]
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            HStack {
                Button("Done") {
                            dismiss()
                }
                Spacer()
            }
            .padding([.horizontal], 24)
            HStack {
                Text("Run Date")
                Spacer()
                Text("Distance(\(UserDistanceSetting.unitOfMeasure()))")
            }
            .padding([.horizontal], 24)
            List {
                ForEach(listData) { sectionViewModel in
                    Section(header: Text("Total for \(sectionViewModel.monthString): \(sectionViewModel.runTotalString)")) {
                        ForEach(sectionViewModel.histories) { rowViewModel in
                            HistoryRow(viewModel: rowViewModel)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
    
    static func listData(shoe: Shoe) -> [HistoryListViewModel] {
        let monthlyHistories = shoe.runHistoriesByMonth(ascending: false)
        return monthlyHistories.map { HistoryListViewModel(histories: $0) }
    }
    
}

struct HistoryListView_Previews: PreviewProvider {
    static var listData: [HistoryListViewModel] {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        let listData = HistoryListView.listData(shoe: shoe)
        return listData
    }
    
    static var previews: some View {
        HistoryListView(listData: listData)
    }
}
