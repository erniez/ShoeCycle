//  UIView+Autolayout.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 7/9/22.
//  
//

import Foundation

extension UIView {
    func pinToSuperview() {
        guard let view = superview else {
            return
        }

        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
