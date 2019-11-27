//
//  UserSettings.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import Foundation

public struct CustomRawRepresentable<T>: RawRepresentable {
    public var rawValue: T
    
    public init(rawValue: T) {
        self.rawValue = rawValue
    }
}

public enum EnumWithStringAsRawValue: String {
    case some, other, `default` = "default_case"
}

public class UserSettings {
    enum Key {
        static let someFlag = "some_flag"
        static let flagWithInitialValue = "flag_with_initial_value"
        static let arrayOfStrings = "array_of_strings"
        static let betterOptionalFlag = "fixed_optional_flag"

        static let rawRepresentableWithIntValue = "raw_representable-int"
        static let rawRepresentableWithStringValue = "raw_representable-string"
        static let rawRepresentableWithDictValue = "raw_representable-dict"
        static let optionalRawRepresentableWithDataValue = "optional_raw_representable-data"
        static let rawRepresentableWithArrayOfDates = "raw_representable-ArrayOfDates"
    }

    @UserDefault(key: Key.someFlag, defaultValue: false)
    public var someFlag: Bool

    @UserDefault(key: Key.flagWithInitialValue, defaultValue: false)
    public var flagWithInitialValue: Bool = true
    
    @UserDefault(key: Key.arrayOfStrings, defaultValue: [])
    public var arrayOfStrings: [String]

    @OptionalUserDefault(key: Key.betterOptionalFlag)
    public var betterOptionalFlag: Bool?

    @WrappedUserDefault(key: Key.rawRepresentableWithIntValue, defaultValue: CustomRawRepresentable<Int>(rawValue: 111))
    public var rawRepresentableWithIntValue: CustomRawRepresentable<Int>

    @WrappedUserDefault(key: Key.rawRepresentableWithStringValue, defaultValue: EnumWithStringAsRawValue.default)
    public var rawRepresentableWithStringValue: EnumWithStringAsRawValue

    @WrappedUserDefault(key: Key.rawRepresentableWithDictValue, defaultValue: CustomRawRepresentable<[String: [Float]]>(rawValue: [:]))
    public var rawRepresentableWithDictValue: CustomRawRepresentable<[String: [Float]]>

    @OptionalWrappedUserDefault(key: Key.optionalRawRepresentableWithDataValue)
    public var optionalRawRepresentableWithDataValue: CustomRawRepresentable<Data>?
    
    @WrappedUserDefault(key: Key.rawRepresentableWithArrayOfDates, defaultValue: CustomRawRepresentable<[Date]>(rawValue: [Date(timeIntervalSince1970: 0)]))
    public var rawRepresentableWithArrayOfDates: CustomRawRepresentable<[Date]>
    
    public init() {}
}
