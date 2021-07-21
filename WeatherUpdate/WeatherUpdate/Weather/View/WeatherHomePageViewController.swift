//
//  WeatherHomePageViewController.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation
import UIKit

/*
 Home Page for Weather Update
 The page is only for view and not user input is allowed on the screen

 */

class WeatherHomePageViewController: UIViewController, LocationSearchViewControllerDelegate {
  
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var searchRightBarItem: UIBarButtonItem!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var weatherDescLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var weatherImg: UIImageView!
    @IBOutlet weak var sunsetLabel: UILabel!
    @IBOutlet weak var sunriseLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var feelsLikeLabel: UILabel!
    
    var weatherVM: WeatherViewModel?
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        weatherVM!.getWeatherDataFor(completion: { (cityMO, error) in
            DispatchQueue.main.async {
                if let city = cityMO {
                    self.weatherVM?.cityMo = city
                    self.setupUI(city: city)
                }
                
                // In case API not responding, show the error
                if let err = error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "\(err.httpStatus)", message: err.message, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
            }
        })
    }
    
    func setupUI(city: CityMO) {
        if let weather = city.cityWeather {
            if city.cityTitle == "My Location" {
                self.cityLabel.text = String(format: "%@(%@)", (city.cityTitle) ?? "", weather.cityName ?? "")
            } else {
                self.cityLabel.text = city.cityTitle ?? ""
            }
            
            let celsiusTemp = weather.temp - 273.15
            self.tempLabel.text = String(format: "%.2f%@", celsiusTemp, "\u{00B0}")
            
            let celsiusFeelsLikeTemp = weather.feelsLike - 273.15
            self.feelsLikeLabel.text = String(format: "Feels like: %.2f%@", celsiusFeelsLikeTemp, "\u{00B0}")
            self.weatherDescLabel.text = weather.weatherDescription?.capitalized ?? ""
            self.pressureLabel.text = String(format: "Pressure: %d hPa", weather.pressure)
            self.humidityLabel.text = String(format: "Humidity: %d %%", weather.humidity)
            self.windLabel.text = String(format: "Wind: %.2f kph", weather.windSpeed)
            
            let sunriseTime = Date(timeIntervalSince1970: Double(weather.sunrise))
            let sunriseTimeString = Date.getHourlyFrom(date: sunriseTime)
            self.sunriseLabel.text = String(format: "%@", sunriseTimeString)
            
            let sunsetTime = Date(timeIntervalSince1970: Double(weather.sunset))
            let sunsetTimeString = Date.getHourlyFrom(date: sunsetTime)
            self.sunsetLabel.text = String(format: "%@", sunsetTimeString)
            
            if let imageName = weather.icon {
                let img = UIImage(named: imageName)
                self.weatherImg.image = img
            }
            
        }
    }
    
    @IBAction func navigationBarLeftItemAction(_ sender: Any) {
        let locationSearch = storyboard?.instantiateViewController(identifier: "LocationSearchVC") as! LocationSearchViewController
        locationSearch.locationsDelegate = self
        self.navigationController?.pushViewController(locationSearch, animated: true)
    }
    
    func citySelected(cityModel: CityModel) {
        self.weatherVM?.cityModel = cityModel
        
    }
}

extension Date {
    static func getHourlyFrom(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: date)
    }
}
