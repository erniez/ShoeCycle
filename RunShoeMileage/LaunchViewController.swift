//
//  LaunchViewController.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 1/16/19.
//

import Foundation
import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    @objc var onAnimationCompletion: (() -> Void)?
    @IBOutlet var centeringConstraints: [NSLayoutConstraint]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtilities.setShoeCyclePatternedBackgroundOn(view)     
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        performAnimations()
    }
    
    @objc
    func getLogoView() -> UIView {
        return logoImageView
    }
    
    func performAnimations() {
        UIView.animate(withDuration: 0.5, delay: 0.25, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .layoutSubviews, animations: {
//            self.logoImageView.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.view.removeConstraints(self.centeringConstraints)
            self.logoImageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 16.0).isActive = true
            self.logoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16.0).isActive = true
            self.view.layoutIfNeeded()
        }) { _ in
            self.onAnimationCompletion?()
        }

    }
    
    func configureViewControllers() -> UIViewController {
        // Create the tabBarController
        let tabBarController = UITabBarController()
        
        // Create viewControllers for the tabBar
        let addDistanceViewController = AddDistanceViewController(nibName: "AddDistanceViewController", bundle: nil)
        let editShoesViewController = EditShoesViewController(style: .grouped)
        let hofTableViewController = HOFTableViewController(style: .grouped)
        let setupViewController = SetupViewController()
        
        let navController = UINavigationController(rootViewController: editShoesViewController)
        let navController2 = UINavigationController(rootViewController: hofTableViewController)
        
        // Make an array containing the view controllers
        let viewControllers = [addDistanceViewController, navController, navController2, hofTableViewController, setupViewController]
        
        // Grab the nav controllers tab bar item (the rootViewController won't work).
        var tbi = navController.tabBarItem
        
        // Give it an image and center
        let image = #imageLiteral(resourceName: "tabbar-shoe")
        tbi?.title = "Add/Edit Shoes"
        tbi?.image = image
        
        // Set the tab bar for the Hall of Fame navigation controller.
        let trophy = #imageLiteral(resourceName: "trophy")
        tbi = navController2.tabBarItem
        tbi?.title = "Hall of Fame"
        tbi?.image = trophy
        
        // Attach the array to the tabBarController
        tabBarController.viewControllers = viewControllers

        let shoes = ShoeStore.default().allShoes()
        if !shoes.isEmpty {  // If this is a fresh install, we'll hold off on showing this, until they add a shoe.
            displayNewFeaturesInfo(addDistanceViewController)
        }
        return tabBarController
    }
    
    private func displayNewFeaturesInfo(_ viewController: UIViewController) {
        let newFeatures = FTUUtility.newFeatures()
        if !newFeatures.isEmpty {
            let featureText = FTUUtility.featureText(forFeatureKey: newFeatures.first)
            let alert = UIAlertController(title: "New Feature", message: featureText, preferredStyle: .alert)
            let readConfirmation = UIAlertAction(title: "Don't show again", style: .default) { action in
                FTUUtility.completeFeature(newFeatures.first!)
            }
            let done = UIAlertAction.init(title: "Done", style: .cancel, handler: nil)
            alert.addAction(readConfirmation)
            alert.addAction(done)
            viewController.present(alert, animated: true, completion: nil)
        }
    }
}
