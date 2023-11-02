//  FileHelpers.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/24/23.
//  
//

import Foundation


enum FileHelpers {
    static func pathInDocumentDirectory(with filename: String) -> String? {
        let documentDirectories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        if let documentDirectory = documentDirectories.first,
            let documentsURL = URL(string: documentDirectory){
            let fullURL = documentsURL.appendingPathComponent(filename)
            return fullURL.absoluteString
        }
        return nil
    }
}
