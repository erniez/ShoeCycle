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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HOFCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDataSource()
        tableView.reloadData()
    }
    
    private func setupDataSource() {
        let allShoes = ShoeStore.default().allShoes() ?? [Shoe]()
        tableData = allShoes.filter { $0.hallOfFame == true }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HOFCell", for: indexPath)
        cell.textLabel?.text = tableData[indexPath.row].brand
        return cell
    }
}
