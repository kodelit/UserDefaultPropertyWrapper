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
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalFlagDefaultTrue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalFlagDefaultNil)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.betterOptionalFlag)
        
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithIntValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithStringValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalRawRepresentableWithIntValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalRawRepresentableWithStringValue)
    }

    func testNonOptionalTypeProperty() {
        let defaultValue = false

        // property wityout initial value (common case)
        XCTAssert(settings.someFlag == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_non_optional_with_initial_value() {
        let initialValue = true
        let defaultValue = false

        // property with initial value
        XCTAssert(settings.flagWithInitialValue == initialValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the initial value \(initialValue)")
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.flagWithInitialValue)
        XCTAssert(settings.flagWithInitialValue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_non_nil_as_default_value() {
        let defaultValue = true

        // property with optional value with `true` as default - should never return nil
        XCTAssert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
        settings.optionalFlagDefaultTrue = false
        XCTAssert(settings.optionalFlagDefaultTrue == false, "Invalid value")
        settings.optionalFlagDefaultTrue = nil
        XCTAssert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_nil_as_default_value() {
        let defaultValue: Bool? = nil

        // property with optional value with `nil` as default
        XCTAssert(settings.optionalFlagDefaultNil == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(String(describing: defaultValue))")
        settings.optionalFlagDefaultNil = false
        XCTAssert(settings.optionalFlagDefaultNil == false, "Invalid value")
        settings.optionalFlagDefaultNil = nil
        XCTAssert(settings.optionalFlagDefaultNil == nil, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(String(describing: defaultValue))")
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
        let defaultValue = CustomRawRepresentableWithIntValue(rawValue: defaultRawValue)
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == defaultValue, "Invalid value")
        
        // check value change
        let newRawValue = 222
        let newValue = CustomRawRepresentableWithIntValue(rawValue: newRawValue)
        XCTAssert(settings.rawRepresentableWithIntValue != newValue, "New value is the same as the old one")
        settings.rawRepresentableWithIntValue = newValue
        
        XCTAssertNotNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithIntValue))
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == newRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == newValue, "Invalid value")
        
        // reset to default
//        UserDefaults.standard.set(nil, forKey: UserSettings.Key.rawRepresentableWithIntValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.rawRepresentableWithIntValue)
        
        // `UserDefaults` value not set
        XCTAssertNil(UserDefaults.standard.object(forKey: UserSettings.Key.rawRepresentableWithIntValue))
        XCTAssert(settings.rawRepresentableWithIntValue.rawValue == defaultRawValue, "Invalid value")
        XCTAssert(settings.rawRepresentableWithIntValue == defaultValue, "Invalid value")
    }
}
