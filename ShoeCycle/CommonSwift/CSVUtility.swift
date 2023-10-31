//
//  CSVUtility.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/26/16.
//
//

import Foundation

struct CSVUtility {
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()

    func createCSVData(fromShoe shoe: Shoe) -> NSString {
        var returnString: String
        returnString = createHeaderString()
        let shoeHistory: [History] = shoe.history.sortHistories(ascending: false)
        for history in shoeHistory {
            let distanceString = String(format: "%.2f", history.runDistance.floatValue)
            returnString += "\(formatter.string(from: history.runDate)), \(distanceString)\n"
        }
        return returnString as NSString
    }

    private func createHeaderString() -> String {
        let headerString = "Run Date, Distance\n"
        return headerString
    }
}
