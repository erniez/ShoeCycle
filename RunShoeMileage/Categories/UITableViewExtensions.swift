//
//  UITableViewExtensions.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 12/22/17.
//

import Foundation

extension UITableView {
    static func emptyDataBackgroundView(message: String) -> UIView {
        let backgroundView = UIView()
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.text = message
        messageLabel.textColor = UIColor.shoeCycleOrange()
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.numberOfLines = 0
        backgroundView.addSubview(messageLabel)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor)
        ])
        return backgroundView
    }
}
