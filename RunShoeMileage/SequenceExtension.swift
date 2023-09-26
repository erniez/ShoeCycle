//  SequenceExtension.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/26/23.
//  
//

import Foundation


extension Sequence {
    func total<T: Numeric>(initialValue: T, for keyPath: KeyPath<Element, T>) -> T {
        return reduce(0) { total, element in
            total + element[keyPath: keyPath]
        }
    }
}
