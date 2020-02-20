//
//  UserSettings.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import Foundation

class UserSettings {
    enum Key {
        static let someFlag = "some_flag"
        static let flagWithInitialValue = "flag_with_initial_value"
        static let optionalFlagDefaultTrue = "optional_flag_default_true"
        static let optionalFlagDefaultNil = "optional_flag_default_nil"
        static let betterOptionalFlag = "fixed_optional_flag"
    }

    @UserDefault(key: Key.someFlag, defaultValue: false)
    public var someFlag: Bool

    @UserDefault(key: Key.flagWithInitialValue, defaultValue: false)
    public var flagWithInitialValue: Bool// = true

    @UserDefault(key: Key.optionalFlagDefaultTrue, defaultValue: true)
    public var optionalFlagDefaultTrue: Bool?

    @UserDefault(key: Key.optionalFlagDefaultNil, defaultValue: nil)
    public var optionalFlagDefaultNil: Bool?

    @OptionalUserDefault(key: Key.betterOptionalFlag)
    public var betterOptionalFlag: Bool?
}
