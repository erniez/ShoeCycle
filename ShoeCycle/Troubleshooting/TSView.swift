//  TSView.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/9/23.
//  
//

import SwiftUI

struct TSView: View {
    @ObservedObject var tsCoordinator: TSCoordinator
    
    init(coordinator: TSCoordinator, shoeStore: ShoeStore? = nil) {
        self.tsCoordinator = coordinator
    }
    
    var body: some View {
        VStack {
            Text(tsCoordinator.currentState.displayText())
                .multilineTextAlignment(.center)
                .padding([.bottom], 16)
            Text("Time to next state:")
            Text("\(tsCoordinator.secondsToNextState)")
        }
        
    }
}

