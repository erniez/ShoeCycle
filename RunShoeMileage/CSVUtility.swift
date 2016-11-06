//
//  CSVUtility.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/26/16.
//
//

import Foundation

class CSVUtility: NSObject {
    let formatter = DateFormatter()
    
    override init() {
        super.init()
        formatter.dateFormat = "MM-dd-yyyy"
    }
    
    func createCSVData(fromShoe shoe: Shoe) -> NSString {
        var returnString: String
        returnString = createHeaderString()
        let shoeHistory: Array<History> = shoe.sortedRunHistory()
        for history in shoeHistory{
            returnString = returnString + "\(formatter.string(from: history.runDate)), \(history.runDistance.intValue)\n"
        }
        return returnString as NSString
    }
    
    func createHeaderString() -> String {
        let headerString = "Run Date, Distance\n"
        return headerString
    }
}
