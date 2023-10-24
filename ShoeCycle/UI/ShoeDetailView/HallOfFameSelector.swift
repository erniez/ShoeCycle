//  HallOfFameSelector.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/7/23.
//  
//

import SwiftUI

struct HallOfFameSelector: View {
    @ObservedObject var viewModel: ShoeDetailViewModel
    private let analytics = AnalyticsFactory.sharedAnalyticsLogger()
    
    var body: some View {
        HStack {
            Text("🏆")
            Group {
                if viewModel.hallOfFame == true {
                    Text("Remove from Hall of Fame")
                        .onTapGesture {
                            viewModel.hallOfFame = false
                            viewModel.hasChanged = true
                        }
                }
                else {
                    Text("Add to Hall of Fame")
                        .onTapGesture {
                            viewModel.hallOfFame = true
                            viewModel.hasChanged = true
                        }
                }
            }
        }
        .animation(.default, value: viewModel.hallOfFame)
        .onChange(of: viewModel.hallOfFame) { newValue in
            if newValue == true {
                analytics.logEvent(name: AnalyticsKeys.Event.addToHOFEvent, userInfo: nil)
            }
            else {
                analytics.logEvent(name: AnalyticsKeys.Event.removeFromHOFEvent, userInfo: nil)
            }
        }
    }
}

