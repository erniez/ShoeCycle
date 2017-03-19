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
        title = "Hall of Fame"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIUtilities.setShoeCyclePatternedBackgroundOn(view)
        let nib = UINib.init(nibName: "EditShoesCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EditShoesCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDataSource()
        tableView.reloadData()
    }
    
    private func setupDataSource() {
        let hofShoes = ShoeStore.default().hallOfFameShoes() ?? [Shoe]()
        tableData = hofShoes.sorted { $0.totalDistance.doubleValue > $1.totalDistance.doubleValue }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EditShoesCell", for: indexPath)
        if let cell = cell as? EditShoesCell {
            cell.configure(for: tableData[indexPath.row])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let shoeDetailViewController = ShoeDetailViewController()
        shoeDetailViewController.shoe = tableData[indexPath.row]
        navigationController?.pushViewController(shoeDetailViewController, animated: true)
    }
}
