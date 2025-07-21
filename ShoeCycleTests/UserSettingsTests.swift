//  UserSettingsTests.swift
//  ShoeCycleTests
//
//  Created by Claude on 7/19/25.
//  

import XCTest
@testable import ShoeCycle

final class UserSettingsTests: XCTestCase {
    
    var userSettings: UserSettings!
    var testUserDefaults: UserDefaults!
    var testSuiteName: String!
    
    override func setUp() {
        super.setUp()
        // Create unique suite name for each test instance to prevent parallel test interference
        testSuiteName = "UserSettingsTests-\(UUID().uuidString)"
        testUserDefaults = UserDefaults(suiteName: testSuiteName)!
        
        // Create UserSettings instance with test UserDefaults
        userSettings = UserSettings(userDefaults: testUserDefaults)
    }
    
    override func tearDown() {
        // Clean up the unique test suite
        testUserDefaults.removePersistentDomain(forName: testSuiteName)
        testUserDefaults = nil
        userSettings = nil
        testSuiteName = nil
        super.tearDown()
    }
    
    // MARK: - Distance Unit Tests
    
    func testDistanceUnitDefault() throws {
        // Test default value (miles)
        XCTAssertEqual(userSettings.distanceUnit, .miles, "Should default to miles")
    }
    
    func testSetDistanceUnit() throws {
        userSettings.set(distanceUnit: .km)
        
        XCTAssertEqual(userSettings.distanceUnit, .km, "Should update to kilometers")
        
        // Verify persistence
        let storedValue = testUserDefaults.integer(forKey: UserSettings.StorageKey.distanceUnit)
        XCTAssertEqual(storedValue, UserSettings.DistanceUnit.km.rawValue, "Should persist to UserDefaults")
    }
    
    func testDistanceUnitDisplayStrings() throws {
        XCTAssertEqual(UserSettings.DistanceUnit.miles.displayString(), "miles", "Miles display string should be correct")
        XCTAssertEqual(UserSettings.DistanceUnit.km.displayString(), "km", "Kilometers display string should be correct")
    }
    
    func testDistanceUnitIdentifiable() throws {
        let miles = UserSettings.DistanceUnit.miles
        let km = UserSettings.DistanceUnit.km
        
        XCTAssertEqual(miles.id, miles, "ID should be self for miles")
        XCTAssertEqual(km.id, km, "ID should be self for kilometers")
        XCTAssertNotEqual(miles.id, km.id, "Different units should have different IDs")
    }
    
    // MARK: - First Day of Week Tests
    
    func testFirstDayOfWeekDefault() throws {
        XCTAssertEqual(userSettings.firstDayOfWeek, .monday, "Should default to Monday")
    }
    
    func testSetFirstDayOfWeek() throws {
        userSettings.set(firstDayOfWeek: .sunday)
        
        XCTAssertEqual(userSettings.firstDayOfWeek, .sunday, "Should update to Sunday")
        
        // Verify persistence
        let storedValue = testUserDefaults.integer(forKey: UserSettings.StorageKey.firstDayOfWeek)
        XCTAssertEqual(storedValue, UserSettings.FirstDayOfWeek.sunday.rawValue, "Should persist to UserDefaults")
    }
    
    func testFirstDayOfWeekRawValues() throws {
        // Raw values should match Calendar weekday values
        XCTAssertEqual(UserSettings.FirstDayOfWeek.sunday.rawValue, 1, "Sunday should be 1 (Calendar standard)")
        XCTAssertEqual(UserSettings.FirstDayOfWeek.monday.rawValue, 2, "Monday should be 2 (Calendar standard)")
    }
    
    // MARK: - Strava Settings Tests
    
    func testStravaEnabledDefault() throws {
        XCTAssertFalse(userSettings.stravaEnabled, "Strava should be disabled by default")
    }
    
    func testSetStravaEnabled() throws {
        userSettings.set(stravaEnabled: true)
        
        XCTAssertTrue(userSettings.stravaEnabled, "Should enable Strava")
        
        // Verify persistence
        let storedValue = testUserDefaults.bool(forKey: UserSettings.StorageKey.stravaEnabled)
        XCTAssertTrue(storedValue, "Should persist enabled state")
        
        // Test disabling
        userSettings.set(stravaEnabled: false)
        XCTAssertFalse(userSettings.stravaEnabled, "Should disable Strava")
    }
    
    // MARK: - Graph All Shoes Tests
    
    func testGraphAllShoesDefault() throws {
        XCTAssertFalse(userSettings.graphAllShoes, "Graph all shoes should be disabled by default")
    }
    
    func testSetGraphAllShoes() throws {
        userSettings.set(graphAllShoes: true)
        
        XCTAssertTrue(userSettings.graphAllShoes, "Should enable graph all shoes")
        
        // Verify persistence
        let storedValue = testUserDefaults.bool(forKey: UserSettings.StorageKey.graphAllShoesToggle)
        XCTAssertTrue(storedValue, "Should persist enabled state")
        
        // Test disabling
        userSettings.set(graphAllShoes: false)
        XCTAssertFalse(userSettings.graphAllShoes, "Should disable graph all shoes")
    }
    
    // MARK: - Selected Shoe Tests
    
    func testSelectedShoeDefault() throws {
        XCTAssertNil(userSettings.selectedShoeURL, "Should have no selected shoe by default")
    }
    
    func testSetSelectedShoe() throws {
        let testURL = URL(string: "x-coredata://test/Shoe/123")!
        
        userSettings.setSelected(shoeUrl: testURL)
        
        XCTAssertEqual(userSettings.selectedShoeURL, testURL, "Should set selected shoe URL")
        
        // Verify persistence
        let storedURL = testUserDefaults.url(forKey: UserSettings.StorageKey.selectedShoe)
        XCTAssertEqual(storedURL, testURL, "Should persist URL to UserDefaults")
    }
    
    func testClearSelectedShoe() throws {
        let testURL = URL(string: "x-coredata://test/Shoe/123")!
        userSettings.setSelected(shoeUrl: testURL)
        
        // Clear selection
        userSettings.setSelected(shoeUrl: nil)
        
        XCTAssertNil(userSettings.selectedShoeURL, "Should clear selected shoe")
        
        // Verify removal from UserDefaults
        let storedURL = testUserDefaults.url(forKey: UserSettings.StorageKey.selectedShoe)
        XCTAssertNil(storedURL, "Should remove URL from UserDefaults")
    }
    
    func testIsSelectedShoe() throws {
        let testURL1 = URL(string: "x-coredata://test/Shoe/123")!
        let testURL2 = URL(string: "x-coredata://test/Shoe/456")!
        
        userSettings.setSelected(shoeUrl: testURL1)
        
        XCTAssertTrue(userSettings.isSelected(shoeURL: testURL1), "Should identify selected shoe")
        XCTAssertFalse(userSettings.isSelected(shoeURL: testURL2), "Should not identify different shoe as selected")
        
        // Test with no selection
        userSettings.setSelected(shoeUrl: nil)
        XCTAssertFalse(userSettings.isSelected(shoeURL: testURL1), "Should return false when no shoe selected")
    }
    
    // MARK: - Favorite Distance Tests
    
    func testFavoriteDistanceDefaults() throws {
        XCTAssertEqual(userSettings.favorite1, 0.0, "Favorite 1 should default to 0")
        XCTAssertEqual(userSettings.favorite2, 0.0, "Favorite 2 should default to 0")
        XCTAssertEqual(userSettings.favorite3, 0.0, "Favorite 3 should default to 0")
        XCTAssertEqual(userSettings.favorite4, 0.0, "Favorite 4 should default to 0")
    }
    
    func testSetFavoriteDistances() throws {
        userSettings.favorite1 = 3.1
        userSettings.favorite2 = 5.0
        userSettings.favorite3 = 6.2
        userSettings.favorite4 = 10.0
        
        XCTAssertEqual(userSettings.favorite1, 3.1, "Should set favorite 1")
        XCTAssertEqual(userSettings.favorite2, 5.0, "Should set favorite 2")
        XCTAssertEqual(userSettings.favorite3, 6.2, "Should set favorite 3")
        XCTAssertEqual(userSettings.favorite4, 10.0, "Should set favorite 4")
        
        // Verify persistence
        let stored1 = testUserDefaults.double(forKey: UserSettings.StorageKey.userDefinedDistance1)
        let stored2 = testUserDefaults.double(forKey: UserSettings.StorageKey.userDefinedDistance2)
        
        XCTAssertEqual(stored1, 3.1, "Should persist favorite 1")
        XCTAssertEqual(stored2, 5.0, "Should persist favorite 2")
    }
    
    func testFavoriteDistanceProjectedValues() throws {
        userSettings.favorite1 = 3.14159
        userSettings.favorite2 = 0.0
        
        XCTAssertNotNil(userSettings.$favorite1, "Should have projected value for positive distance")
        XCTAssertNil(userSettings.$favorite2, "Should have nil projected value for zero distance")
        
        // Test the formatted string
        if let formatted = userSettings.$favorite1 {
            XCTAssertTrue(formatted.contains("3.14"), "Should format distance as string")
        }
    }
    
    func testFavoriteDistanceCount() throws {
        // All zeros
        XCTAssertEqual(userSettings.favoriteDistanceCount(), 0, "Should count 0 when all favorites are 0")
        
        // Set some values
        userSettings.favorite1 = 3.1
        userSettings.favorite3 = 6.2
        
        XCTAssertEqual(userSettings.favoriteDistanceCount(), 2, "Should count 2 non-zero favorites")
        
        // Set all values
        userSettings.favorite2 = 5.0
        userSettings.favorite4 = 10.0
        
        XCTAssertEqual(userSettings.favoriteDistanceCount(), 4, "Should count all 4 favorites")
    }
    
    // MARK: - Legacy Support Tests
    
    func testLegacySelectedShoe() throws {
        // Set legacy value in test UserDefaults
        testUserDefaults.set(42, forKey: UserSettings.StorageKey.legacySelectedShoe)
        
        let settings = UserSettings(userDefaults: testUserDefaults)
        
        XCTAssertEqual(settings.legacySelectedShoe, 42, "Should read legacy selected shoe value")
    }
    
    // MARK: - Storage Key Tests
    
    func testStorageKeyUniqueness() throws {
        let keys = [
            UserSettings.StorageKey.distanceUnit,
            UserSettings.StorageKey.userDefinedDistance1,
            UserSettings.StorageKey.userDefinedDistance2,
            UserSettings.StorageKey.userDefinedDistance3,
            UserSettings.StorageKey.userDefinedDistance4,
            UserSettings.StorageKey.selectedShoe,
            UserSettings.StorageKey.legacySelectedShoe,
            UserSettings.StorageKey.healthKitEnabled,
            UserSettings.StorageKey.stravaEnabled,
            UserSettings.StorageKey.firstDayOfWeek,
            UserSettings.StorageKey.graphAllShoesToggle,
            UserSettings.StorageKey.stravaAccessToken,
            UserSettings.StorageKey.stravaToken
        ]
        
        let uniqueKeys = Set(keys)
        XCTAssertEqual(keys.count, uniqueKeys.count, "All storage keys should be unique")
    }
    
    func testStorageKeyNaming() throws {
        // Verify key naming conventions to catch typos
        XCTAssertTrue(UserSettings.StorageKey.distanceUnit.contains("DistanceUnit"), "Distance unit key should be descriptive")
        XCTAssertTrue(UserSettings.StorageKey.selectedShoe.contains("SelectedShoe"), "Selected shoe key should be descriptive")
        XCTAssertTrue(UserSettings.StorageKey.stravaEnabled.contains("Strava"), "Strava key should be descriptive")
    }
    
    // MARK: - Edge Cases and Error Handling
    
    func testInvalidDistanceUnitFallback() throws {
        // Set invalid raw value in test UserDefaults
        testUserDefaults.set(999, forKey: UserSettings.StorageKey.distanceUnit)
        
        let settings = UserSettings(userDefaults: testUserDefaults)
        
        XCTAssertEqual(settings.distanceUnit, .miles, "Should fallback to miles for invalid distance unit")
    }
    
    func testInvalidFirstDayOfWeekFallback() throws {
        // Set invalid raw value in test UserDefaults
        testUserDefaults.set(999, forKey: UserSettings.StorageKey.firstDayOfWeek)
        
        let settings = UserSettings(userDefaults: testUserDefaults)
        
        XCTAssertEqual(settings.firstDayOfWeek, .monday, "Should fallback to monday for invalid first day")
    }
    
    func testZeroFavoriteDistances() throws {
        userSettings.favorite1 = 0.0
        userSettings.favorite2 = -5.0 // Negative value
        
        XCTAssertNil(userSettings.$favorite1, "Zero distance should have nil projected value")
        XCTAssertNil(userSettings.$favorite2, "Negative distance should have nil projected value")
    }
    
    func testVeryLargeFavoriteDistances() throws {
        let largeDistance = Double.greatestFiniteMagnitude
        userSettings.favorite1 = largeDistance
        
        XCTAssertEqual(userSettings.favorite1, largeDistance, "Should handle very large distances")
        XCTAssertNotNil(userSettings.$favorite1, "Should format very large distances")
    }
    
    // MARK: - ObservableObject Behavior Tests
    
    func testSettingsIsObservableObject() throws {
        XCTAssertTrue(userSettings is (any ObservableObject), "UserSettings should conform to ObservableObject")
    }
    
    func testPublishedPropertiesUpdate() throws {
        let expectation = XCTestExpectation(description: "Published value should update")
        
        // This is challenging to test without UI, but we can verify the properties are @Published
        // by checking they trigger objectWillChange
        var changeCount = 0
        let cancellable = userSettings.objectWillChange.sink {
            changeCount += 1
            if changeCount == 1 {
                expectation.fulfill()
            }
        }
        
        userSettings.set(distanceUnit: .km)
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertGreaterThan(changeCount, 0, "Should trigger objectWillChange")
        
        cancellable.cancel()
    }
    
    // MARK: - Singleton Behavior Tests
    
    func testSingletonBehavior() throws {
        let settings1 = UserSettings.shared
        let settings2 = UserSettings.shared
        
        XCTAssertTrue(settings1 === settings2, "Should return same instance (singleton)")
    }
}
