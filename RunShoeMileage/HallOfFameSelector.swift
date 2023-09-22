//  HallOfFameSelector.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/7/23.
//  
//

import SwiftUI

struct HallOfFameSelector: View {
    @ObservedObject var viewModel: ShoeDetailViewModel
    private let logger = AnalyticsFactory.sharedAnalyticsLogger()
    
    var body: some View {
        HStack {
            Text("🏆")
            Group {
                if viewModel.shoe.hallOfFame == true {
                    Text("Remove from Hall of Fame")
                        .onTapGesture {
                            viewModel.shoe.hallOfFame = false
                            viewModel.hasChanged = true
                        }
                }
                else {
                    Text("Add to Hall of Fame")
                        .onTapGesture {
                            viewModel.shoe.hallOfFame = true
                            viewModel.hasChanged = true
                        }
                }
            }
        }
        .animation(.default, value: viewModel.shoe.hallOfFame)
        .onChange(of: viewModel.shoe.hallOfFame) { newValue in
            if newValue == true {
                logger.logEvent(name: AnalyticsKeys.Event.addToHOFEvent, userInfo: nil)
            }
            else {
                logger.logEvent(name: AnalyticsKeys.Event.removeFromHOFEvent, userInfo: nil)
            }
        }
    }
}

