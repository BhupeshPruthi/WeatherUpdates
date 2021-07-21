//
//  SearchResultCitiesViewController.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation
import UIKit
import MapKit

protocol SearchResultCitiesViewControllerDelegate: class {
    func collectedCityInformationFor(cityModel: CityModel)
    func deactivateSearch()
}

class SearchResultCitiesViewController: UIViewController {
    @IBOutlet weak var citySelectionTable: UITableView!
    @IBOutlet weak var viewErrorMessage: UIView!
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var viewModel = SearchResultCitiesViewModel()
    
    weak var resultCitiesDelegate: SearchResultCitiesViewControllerDelegate?
    
    override func viewDidLoad() {
        self.citySelectionTable.register(UINib(nibName: "CityItemTableCell", bundle: nil), forCellReuseIdentifier: "CityNameCard")
        citySelectionTable.tableFooterView = UIView()
        
        viewModel.cityList.bind { [weak self] _ in
            DispatchQueue.main.async {
                if let cityList = self?.viewModel.cityList.value, cityList.count > 0 {
                    self?.viewErrorMessage.isHidden = true
                } else {
                    self?.viewModel.cityList.value.removeAll()
                    self?.viewErrorMessage.isHidden = false
                }
                self?.citySelectionTable.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewErrorMessage.isHidden = true
    }

}

// Extension to be used for getting the input string of UISearchBar
extension SearchResultCitiesViewController: UISearchResultsUpdating, MKLocalSearchCompleterDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else { return }
        searchCompleter.delegate = self
        searchCompleter.region = MKCoordinateRegion(.world)
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])
        searchCompleter.queryFragment = searchBarText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.viewModel.cityList.value = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("completer has failed with error:: \(error.localizedDescription)")
    }
}

extension SearchResultCitiesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.cityList.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityNameCard", for: indexPath) as! CityItemTableCell
        cell.cityName.text = "\(self.viewModel.cityList.value[indexPath.row].title), \(self.viewModel.cityList.value[indexPath.row].subtitle)"
        cell.localSearchObject = self.viewModel.cityList.value[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        downloadLocalSearchDetailsFor(title: self.viewModel.cityList.value[indexPath.row].title, subTitle: self.viewModel.cityList.value[indexPath.row].subtitle, isFavourite: false)
    }
}

extension SearchResultCitiesViewController: CityItemTableCellDelegate {
    
    func favouriteButtonAction(searchObj: MKLocalSearchCompletion) {
        downloadLocalSearchDetailsFor(title: searchObj.title, subTitle: searchObj.subtitle, isFavourite: true)
    }
    
    // Download the lat and long for a given city name and city subtitle
    // Pass lat and long to the WeatherViewModel for downloading the weather information
    func downloadLocalSearchDetailsFor(title: String, subTitle: String, isFavourite: Bool) {
        // Cancel search bar, let user see the current selection
        self.resultCitiesDelegate?.deactivateSearch()
        
        let areaInfo = "\(title) , \(subTitle)"
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = areaInfo
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            if let item = response.mapItems.first {
                var cityModel = CityModel(latitude: item.placemark.coordinate.latitude, longitude: item.placemark.coordinate.longitude, id: 0, isFavourite: isFavourite, isDefault: false)
                cityModel.citySubTitle = subTitle
                cityModel.administrativeArea = item.placemark.administrativeArea ?? ""
                cityModel.countryCode = item.placemark.countryCode ?? ""
                cityModel.cityTitle = title
                
                self.resultCitiesDelegate?.collectedCityInformationFor(cityModel: cityModel)
            }
        }
    }
}
