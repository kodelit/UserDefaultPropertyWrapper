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
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.someFlag)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.flagWithInitialValue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalFlagDefaultTrue)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.optionalFlagDefaultNil)
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.betterOptionalFlag)

        settings = UserSettings()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNonOptionalTypeProperty() {
        let defaultValue = false

        // property wityout initial value (common case)
        assert(settings.someFlag == defaultValue, "Flag value \(String(describing: settings.someFlag)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_non_optional_with_initial_value() {
        let initialValue = true
        let defaultValue = false

        // property with initial value
        assert(settings.flagWithInitialValue == initialValue, "Flag value \(String(describing: settings.flagWithInitialValue)) is not equal to the initial value \(initialValue)")
        UserDefaults.standard.removeObject(forKey: UserSettings.Key.flagWithInitialValue)
        assert(settings.flagWithInitialValue == defaultValue, "Flag value \(String(describing: settings.flagWithInitialValue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_non_nil_as_default_value() {
        let defaultValue = true

        // property with optional value with `true` as default - should never return nil
        assert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
        settings.optionalFlagDefaultTrue = false
        assert(settings.optionalFlagDefaultTrue == false, "Invalid value")
        settings.optionalFlagDefaultTrue = nil
        assert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_nil_as_default_value() {
        let defaultValue: Bool? = nil

        // property with optional value with `nil` as default
        assert(settings.optionalFlagDefaultNil == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultNil)) is not equal to the default value \(String(describing: defaultValue))")
        settings.optionalFlagDefaultNil = false
        assert(settings.optionalFlagDefaultNil == false, "Invalid value")
        settings.optionalFlagDefaultNil = nil
        assert(settings.optionalFlagDefaultNil == nil, "Flag value \(String(describing: settings.optionalFlagDefaultNil)) is not equal to the default value \(String(describing: defaultValue))")
    }

    func testProperty_optional_without_default_value() {
        // property with optional value without default
        assert(settings.betterOptionalFlag == nil, "Invalid value")
        settings.betterOptionalFlag = true
        assert(settings.betterOptionalFlag == true, "Invalid value")
        settings.betterOptionalFlag = nil
        assert(settings.betterOptionalFlag == nil, "Invalid value")
    }
}
