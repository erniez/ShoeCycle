//  TSCoordinator.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 11/9/23.
//  
//

import Foundation

class TSCoordinator: ObservableObject {
    static let shared = TSCoordinator()
    
    enum State: Int {
        case launch
        case loadDatabase
        case loadSettings
        case loadHOF
        case loadActiveShoes
        case loadAddDistance
        case finished
        
        func displayText() -> String {
            switch self {
            case .launch:
                return "Preparing to open database."
            case .loadDatabase:
                return "Database opened successfully. \nPreparing to load the settings screen."
            case .loadSettings:
                return "Settings screen opened successfully. \nPreparing to load the HOF screen."
            case .loadHOF:
                return "HOF screen opened successfully. \nPreparing to load the Active Shoes screen."
            case .loadActiveShoes:
                return "Active Shoes screen opened successfully. \nPreparing to load the Add Distance screen."
            case .loadAddDistance:
                return "Add Distance screem opened successfully. \nPreparing to use app as normal"
            case .finished:
                return "Use app as normal."
            }
        }
    }
    
    @Published var currentState: State = .launch
    @Published var secondsToNextState: Int = 0
    
    var fiveSecondTimer = SecondsCountdownTimer(intialTime: 5) { timer in
    }
    
    init(currentState: State = .launch) {
        self.currentState = currentState
    }
    
    func start() {
        secondsToNextState = 5
        fiveSecondTimer = SecondsCountdownTimer(intialTime: 5, completion: { [weak self] timer in
            guard let strongSelf = self else {
                timer.invalidate()
                return
            }
            strongSelf.secondsToNextState -= 1
            if strongSelf.secondsToNextState <= 0 {
                timer.invalidate()
                strongSelf.currentState = State(rawValue: strongSelf.currentState.rawValue + 1) ?? .finished
                strongSelf.gotoNextState()
            }
        })
        fiveSecondTimer.start()
    }
    
    private func restartTimer() {
        
    }
    
    private func gotoNextState() {
        if currentState != .finished {
            start()
        }
    }
}

class SecondsCountdownTimer {
    let intialTime: Int
    var timer: Timer
    
    
    init(intialTime: Int, completion: @escaping (Timer) -> Void) {
        self.intialTime = intialTime
        self.timer = Timer(timeInterval: 1, repeats: true, block: completion)
    }
    
    func start() {
        RunLoop.current.add(timer, forMode: .default)
    }
    
    
}
