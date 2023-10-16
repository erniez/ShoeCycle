//  Obfuscation.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 10/14/23.
//  
//

import Foundation

protocol SecretDeobfuscator: AnyObject {
    init()
    func getClearString() -> String
}

final class DefaultDeobfuscator: SecretDeobfuscator {
    func getClearString() -> String {
        return "ThisIsNotAValidSecretKey"
    }
}

/**
 Generates a clear string for a given deobfuscator type.
 */
enum SecretKeyFactory {
    case strava
    
    private var moduleName: String {
        return Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    }
    
    /**
     Creates a clear string from the deobfuscator called out by case. If a deobfuscator is not found, then the clear
     string from DefaultDeobfuscator is used.
     - Returns: Clear string
     */
    func getClearString() -> String {
        var deobfuscator: SecretDeobfuscator = DefaultDeobfuscator()
        switch self {
            // Deobfuscators are generated using NSClassFromString so that this repo will compile without the desired deobfuscator. This way
            // I can keep the concrete deobfuscator file untracked, and someone can download this repo and use it without modification.
        case .strava:
            if let stravaSecretKeyDeobfuscator = NSClassFromString("\(moduleName).StravaSecretKeyDeobfuscator") as? SecretDeobfuscator.Type {
                deobfuscator = stravaSecretKeyDeobfuscator.init()
            }
        }
        return deobfuscator.getClearString()
    }
}
