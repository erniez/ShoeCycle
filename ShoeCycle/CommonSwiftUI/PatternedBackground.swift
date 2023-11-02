//  PatternedBackground.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/26/23.
//  
//

import SwiftUI

struct PatternedBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .dark {
            Image("perfTile")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea(edges: [.top, .leading, .trailing])
                .onTapGesture {
                    dismissKeyboard()
                }
        }
        else {
            ZStack {
                Image("perfTile")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                Rectangle()
                    .fill(Color(white: 1, opacity: 0.30))
                    .ignoresSafeArea()
            }
        }
    }
}

extension View where Self == PatternedBackground {
    static var patternedBackground: some View { PatternedBackground() }
}
