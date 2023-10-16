//  ViewExtensions.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/4/23.
//  
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
