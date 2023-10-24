//  HistoryRowView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/28/23.
//  
//

import SwiftUI

struct HistoryRowViewModel: Identifiable {
    let id = UUID()
    
    let runDate: Date
    let runDistance: NSNumber
    
    private let distanceUtility = DistanceUtility()

    var runDateString: String {
        DateFormatter.shortDate.string(from: runDate)
    }
    var runDistanceString: String {
        distanceUtility.displayString(for: runDistance)
    }
    
    init(runDate: Date, runDistance: NSNumber) {
        self.runDate = runDate
        self.runDistance = runDistance
    }
    
    init(history: History) {
        runDate = history.runDate
        runDistance = history.runDistance
    }
}

struct HistoryRowView: View {
    let viewModel: HistoryRowViewModel
    var body: some View {
        HStack {
            Text(viewModel.runDateString)
            Spacer()
            Text(viewModel.runDistanceString)
        }
    }
}

struct HistoryRow_Previews: PreviewProvider {
    static let viewModel = HistoryRowViewModel(runDate: Date(), runDistance: NSNumber(value: 3.14))
        
    static var previews: some View {
        HistoryRowView(viewModel: viewModel)
    }
}
