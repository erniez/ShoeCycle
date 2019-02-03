//
//  RunHistoryViewControllerDelegate.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/2/19.
//

import Foundation

@objc
protocol RunHistoryViewControllerDelegate {
    func runHistoryDidChange(shoe: Shoe)
}
