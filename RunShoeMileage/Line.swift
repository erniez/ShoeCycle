//  Line.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 6/17/23.
//  
//

import SwiftUI


struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
