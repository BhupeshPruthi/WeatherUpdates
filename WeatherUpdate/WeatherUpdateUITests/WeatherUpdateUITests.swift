//
//  WeatherUpdateUITests.swift
//  WeatherUpdateUITests
//
//  Created by inenpruthibh1m2 on 21/07/21.
//

import XCTest

class WeatherUpdateUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testPermissionForLocationAppear() {
        let app = XCUIApplication()
        app.launch()
        let window = app.windows.firstMatch
        if window.staticTexts["Allow While Using app"].exists {
            let elementsQuery = XCUIApplication().alerts["Allow “WeatherUpdate” to use your location?"].scrollViews.otherElements
            elementsQuery.staticTexts["Allow “WeatherUpdate” to use your location?"].tap()
            elementsQuery.buttons["Allow While Using App"].tap()
        }
    }
    
    func testApplicationTitleSucess() {
        let app = XCUIApplication()
        app.launch()
        let window = app.windows.firstMatch
        
        // Test from Weather Home Page
        let weatherHomePage = window.navigationBars["Weather Update"].exists
        let weatherLocationPage = window.navigationBars["Locations"].exists
        XCTAssertTrue((weatherHomePage || weatherLocationPage), "The Home page title incorrect")
    }
    
    func testLocationSearchCitySuccess() throws {
        let app = XCUIApplication()
        app.launch()
        let window = app.windows.firstMatch
        if window.navigationBars["Weather Update"].exists {
            window.navigationBars["Weather Update"].buttons["Item"].tap()
        } else if window.navigationBars["Locations"].exists {
            // Do nothing
        } else {
            XCTAssertTrue(false, "The Home page title incorrect")
        }
        window.searchFields["City"].tap()
        window.searchFields["City"].typeText("Bengaluru")
        sleep(2)
        XCTAssertTrue(window.tables["Search results"].cells.count > 0, "Results not found for city")
    }

    func testLocationSearchCityFail() throws {
        let app = XCUIApplication()
        app.launch()
        let window = app.windows.firstMatch
        
        if window.navigationBars["Weather Update"].exists {
            window.navigationBars["Weather Update"].buttons["Item"].tap()
        } else if window.navigationBars["Locations"].exists {
            // Do nothing
        } else {
            XCTAssertTrue(false, "The Home page title incorrect")
        }

        window.searchFields["City"].tap()
        window.searchFields["City"].typeText("ABABABABABABABA")
        sleep(2)
        XCTAssertTrue(window.staticTexts["No Match Found!"].exists, "Error message for invalid city does not work")
    }
}
