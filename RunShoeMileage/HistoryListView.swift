//  HistoryListView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/28/23.
//  
//

import SwiftUI


struct HistoryListViewModel {
    var sections: [HistorySectionViewModel] = []
    
    init(sectionViewModels: [HistorySectionViewModel]) {
        sections = sectionViewModels
    }
}

struct HistoryListView: View {
    var listData: HistoryListViewModel
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
                ForEach(listData.sections) { sectionViewModel in
                    Section(header: HistorySectionView(viewModel: sectionViewModel)) {
                        ForEach(sectionViewModel.historyViewModels) { rowViewModel in
                            HistoryRowView(viewModel: rowViewModel)
                        }
                        .onDelete { indexSet in
                            sectionViewModel.removeHistories(atOffsets: indexSet)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

struct HistoryListView_Previews: PreviewProvider {
    static var listData: HistoryListViewModel {
        let shoe = MockShoeGenerator().generateNewShoeWithData()
        let listData = HistorySectionViewModel.listData(shoe: shoe)
        return HistoryListViewModel(sectionViewModels: listData)
    }
    
    static var previews: some View {
        HistoryListView(listData: listData)
    }
}
