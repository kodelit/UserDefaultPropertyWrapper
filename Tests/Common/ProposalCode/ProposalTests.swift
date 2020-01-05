//
//  ProposalTests.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import XCTest

class ProposalTests: XCTestCase {

    var settings: ProposalUserSettings!

    override func setUp() {
        // We have to reset UserDefaults because the values remain between lanches
        resetUserDefaults()
        settings = ProposalUserSettings()
    }

    override func tearDown() {
        resetUserDefaults()
    }
    
    private func resetUserDefaults() {
        UserDefaults.standard.removeObject(forKey: ProposalUserSettings.Key.someFlag)
        UserDefaults.standard.removeObject(forKey: ProposalUserSettings.Key.flagWithInitialValue)
        UserDefaults.standard.removeObject(forKey: ProposalUserSettings.Key.optionalFlagDefaultTrue)
        UserDefaults.standard.removeObject(forKey: ProposalUserSettings.Key.optionalFlagDefaultNil)
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
        UserDefaults.standard.removeObject(forKey: ProposalUserSettings.Key.flagWithInitialValue)
        XCTAssert(settings.flagWithInitialValue == defaultValue, "Flag value \(String(describing: settings.flagWithInitialValue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_non_nil_as_default_value() {
        let defaultValue = true

        // property with optional value with `true` as default - should never return nil
        // but this property will not return `defaultValue` if its type is Optional
        // see: https://dev.to/kodelit/userdefaults-property-wrapper-issues-solutions-4lk9#proposal-getter-issue
        XCTAssert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
        settings.optionalFlagDefaultTrue = false
        XCTAssert(settings.optionalFlagDefaultTrue == false, "Invalid value")
        settings.optionalFlagDefaultTrue = defaultValue
        XCTAssert(settings.optionalFlagDefaultTrue == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultTrue)) is not equal to the default value \(defaultValue)")
    }

    func testProperty_optional_with_nil_as_default_value() {
        let defaultValue: Bool? = nil

        // property with optional value with `nil` as default
        XCTAssert(settings.optionalFlagDefaultNil == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultNil)) is not equal to the default value \(String(describing: defaultValue))")
        settings.optionalFlagDefaultNil = false
        XCTAssert(settings.optionalFlagDefaultNil == false, "Invalid value")

        // !!!: Follwing will crash
        // see: https://dev.to/kodelit/userdefaults-property-wrapper-issues-solutions-4lk9#proposal-setter-issue
        settings.optionalFlagDefaultNil = defaultValue
        XCTAssert(settings.optionalFlagDefaultNil == defaultValue, "Flag value \(String(describing: settings.optionalFlagDefaultNil)) is not equal to the default value \(String(describing: defaultValue))")
    }
}
