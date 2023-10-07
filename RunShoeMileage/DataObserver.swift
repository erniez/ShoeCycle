//  DataObserver.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/6/23.
//  
//

import Foundation
import Combine


/**
 Read only data observer. The source object being observed is not accessible to client code except through
 the completion block in the `startObserving` function. If the backing source object gets deleted
 elsewhere in code, then the subscribing code will never fire. If we use the source object directly,
 then it could be nil at point of use and cause a crash. You could use nil coalescers, but that is a code
 smell(IMHO). You could subscribe to each property in the ObservableObject individually, but it is not as clean.
 */
class DataObserver<T: ObservableObject> {
    @Published private var sourceObject: T
    private var objectCancellable: AnyCancellable?
    
    init(object: T) {
        self.sourceObject = object
    }
    
    func startObserving(action: @escaping (T) -> Void) {
        objectCancellable = $sourceObject.sink(receiveValue: { object in
            action(object)
        })
    }
}
