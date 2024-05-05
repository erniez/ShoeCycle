//  YearlyTotalDistance.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/5/24.
//  
//

import Foundation


struct YearlyTotalDistance: CustomStringConvertible {
    let total: Double
    let year: Int
    
    var description: String {
        "\nYear: \(year)\nTotal: \(total)\n"
    }
}
