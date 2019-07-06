//
//  HOFTableViewController.swift
//  ShoeCycle
//
//  Created by Ernie Zappacosta on 2/18/17.
//
//

import Foundation

class HOFTableViewController: UITableViewController {

    var tableData = [Shoe]()
    var shoeForEditing: Shoe?

    override init(style: UITableView.Style) {
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
        if let shoe = shoeForEditing {
            checkForRemoval(shoe: shoe)
            shoeForEditing = nil
        } else {
            setupDataSource()
            tableView.reloadData()
        }
    }

    private func setupDataSource() {
        let hofShoes = ShoeStore.default().hallOfFameShoes()
        tableData = hofShoes.sorted { $0.totalDistance.doubleValue > $1.totalDistance.doubleValue }
        if tableData.isEmpty {
            tableView.backgroundView = UITableView.emptyDataBackgroundView(message:
                "You have no shoes in the Hall of Fame.  To add one, please edit the shoe you want to add.")
        } else {
            tableView.backgroundView = nil
        }
    }

    private func checkForRemoval(shoe: Shoe) {
        if !shoe.hallOfFame {
            if let index = tableData.firstIndex(of: shoe) {
                CATransaction.setCompletionBlock({
                    self.setupDataSource()
                    self.tableView.reloadData()
                })
                CATransaction.begin()
                tableView.beginUpdates()
                tableData.remove(at: index)
                tableView.deleteRows(at: [IndexPath.init(row: index, section: 0)],
                                     with: UITableView.RowAnimation.automatic)
                tableView.endUpdates()
                ShoeStore.default().move(toLastPlace: shoe)
                CATransaction.commit()
            }
        }
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
        shoeForEditing = tableData[indexPath.row]
        shoeDetailViewController.shoe = shoeForEditing
        navigationController?.pushViewController(shoeDetailViewController, animated: true)
    }
}
