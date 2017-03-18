//
//  HallOfFameCell.swift
//  ShoeCycle
//
//  Created by Bob Bitchin on 2/19/17.
//
//

import Foundation


class HallOfFameCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        accessoryType = UITableViewCellAccessoryType.disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(shoe: Shoe) {
        textLabel?.text = shoe.brand
        let distanceString = UserDistanceSetting.displayDistance(shoe.totalDistance.floatValue)
        detailTextLabel?.text = "Distance: \(distanceString) \(UserDistanceSetting.unitOfMeasure())"
    }
}
