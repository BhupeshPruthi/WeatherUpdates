//
//  CoreDataUtils.swift
//  WeatherUpdate
//
//  Created by inenpruthibh1m2 on 10/07/21.
//

import Foundation
import CoreData

class CoreDataUtils {
    //Changes
    //Second changes
    var mainMoc: NSManagedObjectContext?
    var privateMOC: NSManagedObjectContext?
    static let sharedUtils = CoreDataUtils()
    
    // Setup inial core data settings
    // Private context created but not used
    // It can be used for up coming changes which include downloading data for all cities
    
    func setUpCoreDataBase() {
        let momdURL = Bundle.main.url(forResource: "WeatherDataModel", withExtension: "momd")
        if let url = momdURL {
            let momd = NSManagedObjectModel(contentsOf: url)
            let storeCordinator = NSPersistentStoreCoordinator(managedObjectModel: momd!)
            
            // Path for SQLight store
            let dirPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
            let fileURL = URL(string: "WeatherDataModel.sql", relativeTo: dirPath)
            print("Core data file url:: \(String(describing: fileURL?.absoluteString))")
            do {
                let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
                try storeCordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fileURL, options: options)
            } catch {
                print("!!!!!!!Core Data setup unsuccessfull with error:: \(error)")
            }
            mainMoc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            mainMoc!.persistentStoreCoordinator = storeCordinator
            mainMoc!.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyStoreTrumpMergePolicyType)
            
            privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            privateMOC?.parent  = mainMoc
        }
    }
    // Save City and weather information into DB
    func saveCity(cityModel: CityModel, weatherModel: WeatherModel) {
        if let mainMOC = mainMoc {
            mainMOC.performAndWait {
                do {
                    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
                    fetchRequest.predicate = NSPredicate(format: "cityId == %d", Int64(weatherModel.id))
                    
                    var city: CityMO?
                    if let list = try mainMOC.fetch(fetchRequest) as? [CityMO], list.count > 0 {
                        city = list.first
                    } else {
                        city = CityMO(context: mainMOC)
                        // City Details
                        city?.administrativeArea = cityModel.administrativeArea
                        city?.citySubTitle = cityModel.citySubTitle
                        city?.countryCode = cityModel.countryCode
                        city?.latitude = cityModel.latitude
                        city?.longitude = cityModel.longitude
                        city?.cityTitle = cityModel.cityTitle
                        city?.isFavourite = cityModel.isFavourite
                        city?.isDefault = cityModel.isDefault
                    }
                    
                    let weather = WeatherMO(context: mainMOC)
                    // Weather Details
                    weather.weatherDescription = weatherModel.weather.first?.description
                    weather.icon = weatherModel.weather.first?.icon
                    weather.temp = weatherModel.main.temp
                    weather.feelsLike = weatherModel.main.feelLike
                    weather.tempMin = weatherModel.main.tempMin
                    weather.tempMax = weatherModel.main.tempMax
                    weather.pressure = Int64(weatherModel.main.pressure)
                    weather.humidity = Int64(weatherModel.main.humidity)
                    weather.windSpeed = weatherModel.wind.speed
                    weather.sunset = Int64(weatherModel.sunrise.sunset)
                    weather.sunrise = Int64(weatherModel.sunrise.sunrise)
                    weather.visibility = Int64(weatherModel.visibility)
                    city?.cityId = Int64(weatherModel.id)
                    weather.cityName = weatherModel.name
                    city?.cityWeather = weather
                    do {
                        try mainMOC.save()
                    } catch {
                        print("!!!!!!!Core Data Unable to save city and weather info:: \(error)")
                    }
                } catch {
                    
                }
                
            }
        }
    }
    
    // Will fetch default city followed by favourites and the history
    func fetchCities(mocType: MOCType) -> [CityMO] {
        var mocUsed: NSManagedObjectContext?
        if mocType == MOCType.mainMOC {
            mocUsed = mainMoc
        } else {
            mocUsed = privateMOC
        }
        var cityArray = [CityMO]()
        if let moc = mocUsed {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
            fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "isDefault", ascending: false),
                                            NSSortDescriptor.init(key: "isFavourite", ascending: false) ,
                                            NSSortDescriptor.init(key: "cityTitle", ascending: true)]
            
            mocUsed?.performAndWait {
                do {
                    if let list = try moc.fetch(fetchRequest) as? [CityMO] {
                        cityArray = list
                    }
                } catch {
                    print("!!!!!!!Core Data Unable to fetch city data with error:: \(error)")
                }
            }
            return cityArray
        }
        return cityArray
    }
    
    // Fetch city for id
    func fetchCityForId(id: Int) -> CityMO? {
        var citySelected: CityMO?
        if let moc = mainMoc {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
            fetchRequest.predicate = NSPredicate(format: "cityId == %d", id)
            mainMoc?.performAndWait {
                do {
                    if let list = try moc.fetch(fetchRequest) as? [CityMO], list.count > 0 {
                        citySelected = list.first
                    }
                } catch {
                    print("!!!!!!!Core Data Unable to fetch city for id with error:: \(error)")
                }
            }
            return citySelected
        }
        return citySelected
    }
    
    // Remove City for id
    func removeCityForId(id: Int) {
        if let moc = mainMoc {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
            fetchRequest.predicate = NSPredicate(format: "cityId == %d", id)
            moc.performAndWait {
                do {
                    if let list = try moc.fetch(fetchRequest) as? [CityMO], list.count > 0, let citySelected = list.first {
                        moc.delete(citySelected)
                    }
                } catch {
                    print("!!!!!!!Core Data Unable to remove city with id with error:: \(error)")
                }
            }
        }
    }
    
    // Set new city as default city
    func setDefaultCityForId(id: Int) {
        if let moc = mainMoc {
            
            // Only one city can be default
            let fetchRequestForDefault = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
            mainMoc?.performAndWait {
                do {
                    fetchRequestForDefault.predicate = NSPredicate(format: "isDefault == YES")
                    if let list = try moc.fetch(fetchRequestForDefault) as? [CityMO], list.count > 0 {
                        for city in list {
                            city.setValue(false, forKey: "isDefault")
                            print("***** City no longer Default: \(city.cityTitle ?? "City Title")")
                        }
                        do {
                            try moc.save()
                        } catch {
                            print("!!!!!!!Core Data Unable to save reset default location with error:: \(error)")
                        }
                    }
                } catch {
                    print("!!!!!!!Core Data Unable to reset default location with error:: \(error)")
                }
            }
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityMO")
            fetchRequest.predicate = NSPredicate(format: "cityId == %d", id)
            moc.performAndWait {
                do {
                    if let list = try moc.fetch(fetchRequest) as? [CityMO], list.count > 0, let citySelected = list.first {
                        citySelected.isDefault = true
                        do {
                            try moc.save()
                        } catch {
                            print("!!!!!!!Core Data Unable to save reset default location with error:: \(error)")
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // Save main cotnext
    func saveMainContext() {
        if let mainMoc = self.mainMoc {
            do {
                try mainMoc.save()
            } catch {
                print("!!!!!!!Core Data Unable save with error:: \(error)")
            }
        }
    }
}

public enum MOCType {
    case mainMOC
    case privateMOC
}
