//
//  HOFTableViewController.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/18/17.
//
//

import Foundation


class HOFTableViewController: UITableViewController {
    
    var tableData = [Shoe]()
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        // Get tab bar item
        let tbi = tabBarItem
        
        // Give it a label
        let image = UIImage(named: "tabbar-add.png")
        tbi?.title = "Hall of Fame"
        tbi?.image = image
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtilities.setShoeCyclePatternedBackgroundOn(view)
    }
}
