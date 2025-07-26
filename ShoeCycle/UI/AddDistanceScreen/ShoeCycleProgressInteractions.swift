//  ShoeCycleProgressInteractions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/25.
//  
//

import SwiftUI

struct ShoeCycleProgressState {
    var bounceState: Bool = false
    
    init() {}
}

struct ShoeCycleProgressInteractor {
    
    enum Action {
        case bounceTriggered
        case bounceStateChanged(Bool)
    }
    
    func handle(state: inout ShoeCycleProgressState, action: Action) {
        switch action {
        case .bounceTriggered:
            state.bounceState.toggle()
            
        case .bounceStateChanged(let newBounceState):
            state.bounceState = newBounceState
        }
    }
}