//
//  CSVUtility.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/26/16.
//
//

import Foundation

class CSVUtility: NSObject {
    let formatter = DateFormatter()

    override init() {
        super.init()
        formatter.dateFormat = "MM-dd-yyyy"
    }

    @objc
    func createCSVData(fromShoe shoe: Shoe) -> NSString {
        var returnString: String
        returnString = createHeaderString()
        let shoeHistory: [History] = shoe.sortedRunHistoryAscending(false)
        for history in shoeHistory {
            let distanceString = String(format: "%.2f", history.runDistance.floatValue)
            returnString += "\(formatter.string(from: history.runDate)), \(distanceString)\n"
        }
        return returnString as NSString
    }

    func createHeaderString() -> String {
        let headerString = "Run Date, Distance\n"
        return headerString
    }
}
