//  DateFormatterExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 5/21/23.
//  
//

import Foundation


extension DateFormatter {
    static var shortDate: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }
}
