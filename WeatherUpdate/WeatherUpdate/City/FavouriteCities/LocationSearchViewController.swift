//
//  LocationSearchViewController.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

/*
 Class responsible for showing the list of cities from history
 Allow user to manage the histroy
 Show the cities in order
 1. Default address
 2. Favourite cities in asscesnding Order
 3. History in asscesnding Order
 4. Allow user to delete the data
 5. Tap on any city to see the latest weather info
 6. Set any city as default
 7. Fetch Current location
 **/

protocol LocationSearchViewControllerDelegate {
    func citySelected(cityModel: CityModel)
}

class LocationSearchViewController: UIViewController , UISearchControllerDelegate {
   
    @IBOutlet weak var searchBarViewContainer: UIView!
    @IBOutlet weak var citiesTableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!

    private let locationManager = CLLocationManager()
    private var searchResultCities : SearchResultCitiesViewController?
    private var matchingItems:[MKMapItem] = []
    private var favouriteCities = [CityMO]()
    private var citySearchController : UISearchController?
    private var isEditFavourite : Bool = false
    
    var locationsDelegate : LocationSearchViewControllerDelegate?

    override func viewDidLoad() {
        self.citiesTableView.register(UINib(nibName: "GenericMessageCell", bundle: nil), forCellReuseIdentifier: "GenericCard")
        self.citiesTableView.register(UINib(nibName: "FavouriteCityTableCell", bundle: nil), forCellReuseIdentifier: "FavouriteCityCard")
        locationManager.requestWhenInUseAuthorization()
        citiesTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //by default favourite cities list should be visible
        self.setUpSearchResultContinainer()
        self.favouriteCities = CoreDataUtils.sharedUtils.fetchCities(mocType: .MainMOC)
        self.citiesTableView.reloadData()
    }
    
    func setUpSearchResultContinainer() {
        searchResultCities = storyboard?.instantiateViewController(identifier: "SearchResultCityListVC") as? SearchResultCitiesViewController
        searchResultCities?.resultCitiesDelegate = self
        citySearchController = UISearchController(searchResultsController: searchResultCities)
        self.setUpSearchBar()
    }
    
    func setUpSearchBar() {
        if let searchController =  citySearchController {
            searchController.delegate = self
            searchController.searchBar.delegate = self
            searchController.searchResultsUpdater = searchResultCities
            searchController.searchBar.placeholder = "City"
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.translatesAutoresizingMaskIntoConstraints = true
            searchController.searchBar.barStyle = .default
            searchController.searchBar.frame = searchBarViewContainer.bounds
            searchController.searchBar.autoresizingMask = [.flexibleWidth]
            searchController.searchBar.showsBookmarkButton = true
            searchController.searchBar.setImage(UIImage(named: "currentLocation"), for: .bookmark, state: .normal)
            searchBarViewContainer.addSubview(searchController.searchBar)
            searchController.hidesNavigationBarDuringPresentation = false
            definesPresentationContext = true
        }
    }
    
    @IBAction func editFavouriteCitiesList(_ sender: Any) {
        if self.isEditFavourite {
            self.isEditFavourite = false
            self.editBarButton.title = "Edit"
            //Save the core data changes only on Done button action
        } else {
            self.isEditFavourite = true
            self.editBarButton.title = "Done"
            //Reload to show delete and Home button
        }
        CoreDataUtils.sharedUtils.saveMainContext()
        self.citiesTableView.reloadData()
    }

}


extension LocationSearchViewController : SearchResultCitiesViewControllerDelegate {
    
    func downloadLocalCityInformationCompleted(cityModel: CityModel) {
        //If Location Search is root controller , delay as search bar should animate before navigation animation
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
            if self.navigationController?.viewControllers.count == 1 {
                let weatherHomePage = self.storyboard?.instantiateViewController(identifier: "WeatherHomePage") as! WeatherHomePageViewController
                var weatherVM = WeatherViewModel()
                weatherVM.cityModel = cityModel
                weatherHomePage.weatherVM = weatherVM
                self.navigationController?.setViewControllers([weatherHomePage], animated: true)
            } else {
                self.locationsDelegate?.citySelected(cityModel: cityModel)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func cancelSearchBar() {
        self.citySearchController?.isActive = false
        self.favouriteCities = CoreDataUtils.sharedUtils.fetchCities(mocType: .MainMOC)
        self.citiesTableView.reloadData()
    }
}


extension LocationSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        citySearchController?.isActive = false
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isEditFavourite = false
        self.editBarButton.title = "Edit"
        self.citiesTableView.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        var currentLocation: CLLocation!
        
        if locationManager.authorizationStatus != .denied && locationManager.authorizationStatus != .restricted  {
            currentLocation = locationManager.location
            print("Current Location Coordinates latitude:: \(currentLocation.coordinate.latitude)")
            print("Current Location Coordinates longitude:: \(currentLocation.coordinate.longitude)")
            let cityModel = CityModel(citySubTitle: "", administrativeArea: "", countryCode: "", cityTitle: "My Location", latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, id: 0, isFavourite: true, isDefault: false)
            self.locationsDelegate?.citySelected(cityModel: cityModel)
            self.navigationController?.popViewController(animated: true)
        } else {
            let alert = UIAlertController(title: "Enable Location" , message: "Location services are not enabled!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
    }
}

extension LocationSearchViewController : UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteCities.count > 0 ? favouriteCities.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if favouriteCities.count == 0 {
            let genericCell = tableView.dequeueReusableCell(withIdentifier: "GenericCard", for: indexPath) as! GenericMessageCell
            genericCell.headerLabel.text = "Your favourite locations list if empty! Find your current location using Naviator button or Search for a location manually to use the app."
            return genericCell
        } else {
            let favouriteCityCell = tableView.dequeueReusableCell(withIdentifier: "FavouriteCityCard", for: indexPath) as! FavouriteCityTableCell
            let city = favouriteCities[indexPath.row]
            favouriteCityCell.cityMo = city
            favouriteCityCell.delegate = self
            favouriteCityCell.titleLabel.text = city.cityTitle
            favouriteCityCell.subTitleLabel.text = city.citySubTitle
            let weather = city.cityWeather
            let celsiusTemp = (weather?.temp ?? 273.15) - 273.15
            favouriteCityCell.infoLabel.text = String(format: "%.2f%@", celsiusTemp, "\u{00B0}")
            favouriteCityCell.editFavouriteCities(isEditEnabled: isEditFavourite)
            favouriteCityCell.titleLabel.textColor = .label
            favouriteCityCell.subTitleLabel.textColor = .label
            favouriteCityCell.infoLabel.textColor = .label
            
            if city.isDefault {
                favouriteCityCell.imgCellType.image = UIImage(systemName: "house")
                favouriteCityCell.imgCellType.isHidden = false
            } else if city.isFavourite {
                favouriteCityCell.imgCellType.image = UIImage(systemName: "star")
                favouriteCityCell.imgCellType.isHidden = false

            } else {
                favouriteCityCell.imgCellType.isHidden = true
            }
            return favouriteCityCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard favouriteCities.count > indexPath.row else {
            return
        }
        
        let city = favouriteCities[indexPath.row]
        let cityModel = CityModel(citySubTitle: city.citySubTitle ?? "", administrativeArea: city.administrativeArea ?? "", countryCode: city.countryCode ?? "", cityTitle: city.cityTitle ?? "", latitude: city.latitude, longitude: city.longitude, id: city.cityId, isFavourite: city.isFavourite, isDefault: city.isDefault)
        self.locationsDelegate?.citySelected(cityModel: cityModel)
        self.navigationController?.popViewController(animated: true)
    }
}

extension LocationSearchViewController : FavouriteCityTableCellDelegate {
    func reloadTableView() {
        self.favouriteCities = CoreDataUtils.sharedUtils.fetchCities(mocType: .MainMOC)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.25) {
            self.citiesTableView.reloadData()
        }
    }
}
