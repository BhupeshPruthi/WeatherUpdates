//
//  FavouriteCityTableCell.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 11/07/21.
//

import Foundation
import UIKit

protocol FavouriteCityTableCellDelegate: class {
    func reloadTableView()
}

// To show the list of favourite Cities
// Also allows user to see the way to set a city as default location
// User can see if city is default, favourite or just history
// User can delete a city by with delete button in front of cell

class FavouriteCityTableCell: UITableViewCell {
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var setDefaultButton: UIButton!
    @IBOutlet weak var imgCellType: UIImageView!

    weak var delegate: FavouriteCityTableCellDelegate?
    var cityMo: CityMO?
    
    func editFavouriteCities(isEditEnabled: Bool) {
        infoLabel.isHidden = isEditEnabled
        deleteButton.isHidden = !isEditEnabled
        setDefaultButton.isHidden = !isEditEnabled
    }
    
    @IBAction func deleteButtonAction(_ sender: Any) {
        if let citySelected  = cityMo {
            CoreDataUtils.sharedUtils.removeCityForId(id: Int(citySelected.cityId))
            self.delegate?.reloadTableView()
        }
    }
    
    @IBAction func setDefaultAction(_ sender: Any) {
        if let citySelected  = cityMo {
            CoreDataUtils.sharedUtils.setDefaultCityForId(id: Int(citySelected.cityId))
            self.delegate?.reloadTableView()
        }
    }
    
}
