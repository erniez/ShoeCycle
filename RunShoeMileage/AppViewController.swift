//
//  AppViewController.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 1/18/19.
//

import Foundation
import UIKit


class AppViewController: UIViewController {
    private var viewController: UIViewController
    
    @objc
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChild(viewController)
        if let containerView = viewController.view {
            containerView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(containerView)
            containerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
        didMove(toParent: viewController)
    }
    
    @objc
    public func transition(toViewController: UIViewController, duration: TimeInterval = 0.0, options: UIView.AnimationOptions = .layoutSubviews, animations: (() -> Void)?, completion: ((Bool) -> Void)?) {
        addChild(toViewController)
        transition(from: viewController, to: toViewController, duration: duration, options: options, animations: animations) { animationComplete in
            completion?(animationComplete)
            self.viewController.removeFromParent()
            self.viewController = toViewController
        }
        
    }
    
}
