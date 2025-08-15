//  HallOfFameSelector.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/7/23.
//  
//

import SwiftUI

struct HallOfFameSelector: View {
    @Binding var hallOfFameBinding: Bool
    private let analytics = AnalyticsFactory.sharedAnalyticsLogger()
    
    var body: some View {
        HStack {
            Text("🏆")
            Group {
                if hallOfFameBinding == true {
                    Text("Remove from Hall of Fame")
                        .onTapGesture {
                            hallOfFameBinding = false
                        }
                }
                else {
                    Text("Add to Hall of Fame")
                        .onTapGesture {
                            hallOfFameBinding = true
                        }
                }
            }
        }
        .animation(.default, value: hallOfFameBinding)
        .onChange(of: hallOfFameBinding) { _, newValue in
            if newValue == true {
                analytics.logEvent(name: AnalyticsKeys.Event.addToHOFEvent, userInfo: nil)
            }
            else {
                analytics.logEvent(name: AnalyticsKeys.Event.removeFromHOFEvent, userInfo: nil)
            }
        }
    }
}

