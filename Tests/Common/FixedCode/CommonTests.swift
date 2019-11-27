//
//  CommonTests.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import XCTest

class CommonTests: XCTestCase {

    var settings: UserSettings!

    override func setUp() {
        // We have to reset UserDefaults because the values remain between lanches
        resetUserDefaults()
        settings = UserSettings()
    }

    override func tearDown() {
        resetUserDefaults()
    }
    
    private func resetUserDefaults() {
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.someFlag)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.flagWithInitialValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.arrayOfStrings)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.betterOptionalFlag)
        
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithIntValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithStringValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithDictValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalRawRepresentableWithDataValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithArrayOfDates)
    }

    func testNonOptionalTypeProperty() {
        let defaultValue = false

        // property wityout initial value (common case)
        XCTAssert(settings.someFlag == defaultValue, "Flag value \(String(describing: settings.someFlag)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_non_optional_with_initial_value() {
        let initialValue = true
        let defaultValue = false

        // property with initial value
        XCTAssert(settings.flagWithInitialValue == initialValue, "Flag value \(String(describing: settings.flagWithInitialValue)) is not equal to the initial value \(initialValue)")
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.flagWithInitialValue)
        XCTAssert(settings.flagWithInitialValue == defaultValue, "Flag value \(String(describing: settings.flagWithInitialValue)) is not equal to the default value \(defaultValue)")
    }
    
    func testProperty_array_of_strings() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.arrayOfStrings))
        
        // check is default value returned when `UserDefaults` value not set
        let defaultValue: [String] = []
        XCTAssert(settings.arrayOfStrings == defaultValue, "Invalid value")
        
        // check value change
        let newValue = ["Some value", "Some other value"]
        XCTAssert(settings.arrayOfStrings != newValue, "New value is the same as the old one")
        settings.arrayOfStrings = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.arrayOfStrings))
        XCTAssert(settings.arrayOfStrings == newValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.arrayOfStrings)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.arrayOfStrings))
        XCTAssert(settings.arrayOfStrings == defaultValue, "Invalid value")
    }

    func testProperty_optional_without_default_value() {
        // property with optional value without default
        XCTAssert(settings.betterOptionalFlag == nil, "Invalid value")
        settings.betterOptionalFlag = true
        XCTAssert(settings.betterOptionalFlag == true, "Invalid value")
        settings.betterOptionalFlag = nil
        XCTAssert(settings.betterOptionalFlag == nil, "Invalid value")
    }
    
    func testProperty_raw_representable_with_int_value() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithIntValue))
        
        // check is default value returned when `UserDefaults` value not set
        let defaultRawValue = 111
        let defaultValue = CustomRawRepresentable<Int>(rawValue: defaultRawValue)
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == defaultValue, "Invalid value")
        
        // check value change
        let newRawValue = 222
        let newValue = CustomRawRepresentable<Int>(rawValue: newRawValue)
        XCTAssert(settings.rawRepresentableWithIntValue != newValue, "New value is the same as the old one")
        settings.rawRepresentableWithIntValue = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithIntValue))
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == newRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == newValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithIntValue)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithIntValue))
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == defaultValue, "Invalid value")
    }
    
    func testProperty_raw_representable_with_string_value() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithStringValue))
        
        // check is default value returned when `UserDefaults` value not set
        let defaultRawValue = EnumWithStringAsRawValue.default.rawValue
        let defaultValue = EnumWithStringAsRawValue(rawValue: defaultRawValue)
        XCTAssertNotNil(defaultValue)
        XCTAssert(settings.rawRepresentableWithStringValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithStringValue == defaultValue, "Invalid value")
        
        // check value change
        let newRawValue = EnumWithStringAsRawValue.other.rawValue
        let newValue = EnumWithStringAsRawValue(rawValue: newRawValue)
        XCTAssertNotNil(newValue)
        XCTAssert(settings.rawRepresentableWithStringValue != newValue, "New value is the same as the old one")
        settings.rawRepresentableWithStringValue = newValue!
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithStringValue))
        XCTAssert(settings.rawRepresentableWithStringValue.rawValue == newRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithStringValue == newValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithStringValue)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithStringValue))
        XCTAssert(settings.rawRepresentableWithStringValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithStringValue == defaultValue, "Invalid value")
    }
    
    func testProperty_optional_raw_representable_with_dict_value() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithDictValue))
        
        // check is default value returned when `UserDefaults` value not set
        let defaultRawValue: [String: [Float]] = [:]
        let defaultValue = CustomRawRepresentable<[String: [Float]]>(rawValue: defaultRawValue)
        XCTAssert(settings.rawRepresentableWithDictValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithDictValue == defaultValue, "Invalid value")
        
        // check value change
        let newRawValue: [String: [Float]] = ["key1": [12.3, 55.55]]
        let newValue = CustomRawRepresentable<[String: [Float]]>(rawValue: newRawValue)

        XCTAssert(settings.rawRepresentableWithDictValue != newValue, "New value is the same as the old one")
        settings.rawRepresentableWithDictValue = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithDictValue))
        XCTAssert(settings.rawRepresentableWithDictValue.rawValue == newRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithDictValue == newValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithDictValue)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithDictValue))
        XCTAssert(settings.rawRepresentableWithDictValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithDictValue == defaultValue, "Invalid value")
    }
    
    func testProperty_optional_raw_representable_with_data_value() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.optionalRawRepresentableWithDataValue))
        
        // check is default value returned when `UserDefaults` value not set
        XCTAssertNil(settings.optionalRawRepresentableWithDataValue)
        
        // check value change
        let newRawValue = "SomeToken".data(using: .utf8)!
        let newValue = CustomRawRepresentable<Data>(rawValue: newRawValue)
        XCTAssertNotNil(newValue)
        XCTAssert(settings.optionalRawRepresentableWithDataValue?.rawValue != newRawValue, "New value is the same as the old one")
        settings.optionalRawRepresentableWithDataValue = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.optionalRawRepresentableWithDataValue))
        XCTAssert(settings.optionalRawRepresentableWithDataValue?.rawValue == newRawValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalRawRepresentableWithDataValue)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.optionalRawRepresentableWithDataValue))
        XCTAssertNil(settings.optionalRawRepresentableWithDataValue, "Invalid value")
    }
    
    func testProperty_raw_representable_with_array_of_dates() {
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithArrayOfDates))
        
        // check is default value returned when `UserDefaults` value not set
        let defaultRawValue = [Date(timeIntervalSince1970: 0)]
        let defaultValue = CustomRawRepresentable<[Date]>(rawValue: defaultRawValue)
        XCTAssert(settings.rawRepresentableWithArrayOfDates.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithArrayOfDates == defaultValue, "Invalid value")
        
        // check value change
        let newRawValue = [Date(timeIntervalSince1970: 0), Date()]
        let newValue = CustomRawRepresentable<[Date]>(rawValue: newRawValue)
        XCTAssert(settings.rawRepresentableWithArrayOfDates != newValue, "New value is the same as the old one")
        settings.rawRepresentableWithArrayOfDates = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithArrayOfDates))
        XCTAssert(settings.rawRepresentableWithArrayOfDates.rawValue == newRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithArrayOfDates == newValue, "Invalid value")
        
        // reset to default
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithArrayOfDates)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithArrayOfDates))
        XCTAssert(settings.rawRepresentableWithArrayOfDates.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithArrayOfDates == defaultValue, "Invalid value")
    }
}
