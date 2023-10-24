//  SequenceExtension.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 9/26/23.
//  
//

import Foundation


extension Sequence {
    func total<T: AdditiveArithmetic>(initialValue: T, for keyPath: KeyPath<Element, T>) -> T {
        return reduce(initialValue) { total, element in
            total + element[keyPath: keyPath]
        }
    }
}
