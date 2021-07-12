//
//  CityItemTableCell.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation
import UIKit
import MapKit

//Allow users to select a city from search results
//Also allow users to make a city favourite dirctly by clicking star icon

protocol CityItemTableCellDelegate {
    func favouriteButtonAction(searchObj: MKLocalSearchCompletion)
}

class CityItemTableCell: UITableViewCell {
    
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var favouriteButton: UIButton!
    
    var localSearchObject : MKLocalSearchCompletion?
    var delegate: CityItemTableCellDelegate?
    
    @IBAction func favouriteButtonAction(_ sender: Any) {
        delegate?.favouriteButtonAction(searchObj: self.localSearchObject!)
    }

}
