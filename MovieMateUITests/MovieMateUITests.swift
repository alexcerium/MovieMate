//
//  MovieMateUITests.swift
//  MovieMateUITests
//
//  Created by Aleksandr on 13.09.2024.
//

import XCTest

class MovieMateUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testFavoritesTabOpens() {
        // Переходим на вкладку "Favorites"
        let favoritesTab = app.tabBars.buttons["Favorites"]
        XCTAssertTrue(favoritesTab.exists, "Вкладка 'Favorites' должна существовать")
        favoritesTab.tap()

        // Ожидаем появления навигационного бара с заголовком "Favorite Movies"
        let navigationBar = app.navigationBars["Favorite Movies"]
        let exists = navigationBar.waitForExistence(timeout: 5)
        XCTAssertTrue(exists, "Должен отображаться экран 'Favorite Movies'")
    }
}
