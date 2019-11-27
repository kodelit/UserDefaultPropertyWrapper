//
//  UserSettings.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import Foundation

struct CustomRawRepresentableWithIntValue: RawRepresentable {
    var rawValue: Int
}

enum CustomRawRepresentableWithStringValue: String {
    case some, other, `default` = "default_case"
}

class UserSettings {
    enum Key {
        static let someFlag = "some_flag"
        static let flagWithInitialValue = "flag_with_initial_value"
        static let optionalFlagDefaultTrue = "optional_flag_default_true"
        static let optionalFlagDefaultNil = "optional_flag_default_nil"
        static let betterOptionalFlag = "fixed_optional_flag"

        static let rawRepresentableWithIntValue = "raw_representable-int"
        static let rawRepresentableWithStringValue = "raw_representable-string"
        static let optionalRawRepresentableWithIntValue = "optional_raw_representable-int"
        static let optionalRawRepresentableWithStringValue = "optional_raw_representable-string"
    }

    @UserDefault(key: Key.someFlag, defaultValue: false)
    public var someFlag: Bool

    @UserDefault(key: Key.flagWithInitialValue, defaultValue: false)
    public var flagWithInitialValue: Bool = true

    @UserDefault(key: Key.optionalFlagDefaultTrue, defaultValue: true)
    public var optionalFlagDefaultTrue: Bool?

    @UserDefault(key: Key.optionalFlagDefaultNil, defaultValue: nil)
    public var optionalFlagDefaultNil: Bool?

    @OptionalUserDefault(key: Key.betterOptionalFlag)
    public var betterOptionalFlag: Bool?

    @UserDefault(key: Key.rawRepresentableWithIntValue, defaultValue: CustomRawRepresentableWithIntValue(rawValue: 111))
    public var rawRepresentableWithIntValue: CustomRawRepresentableWithIntValue

    @UserDefault(key: Key.rawRepresentableWithStringValue, defaultValue: CustomRawRepresentableWithStringValue.default)
    public var rawRepresentableWithStringValue: CustomRawRepresentableWithStringValue

    @UserDefault(key: Key.optionalRawRepresentableWithIntValue, defaultValue: CustomRawRepresentableWithIntValue(rawValue: 111))
    public var optionalRawRepresentableWithIntValue: CustomRawRepresentableWithIntValue?

    @UserDefault(key: Key.optionalRawRepresentableWithStringValue, defaultValue: CustomRawRepresentableWithStringValue.default)
    public var optionalRawRepresentableWithStringValue: CustomRawRepresentableWithStringValue?
}
