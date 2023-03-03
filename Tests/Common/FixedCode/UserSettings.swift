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

extension PropertyKey {
    static let someFlag: PropertyKey = "some_flag"
    static let flagWithInitialValue: PropertyKey = "flag_with_initial_value"
    static let arrayOfStrings: PropertyKey = "array_of_strings"
    static let betterOptionalFlag: PropertyKey = "fixed_optional_flag"

    static let rawRepresentableWithIntValue: PropertyKey = "raw_representable-int"
    static let rawRepresentableWithStringValue: PropertyKey = "raw_representable-string"
    static let rawRepresentableWithDictValue: PropertyKey = "raw_representable-dict"
    static let optionalRawRepresentableWithDataValue: PropertyKey = "optional_raw_representable-data"
    static let rawRepresentableWithArrayOfDates: PropertyKey = "raw_representable-ArrayOfDates"
}

public typealias Wrapper = UniversalUserDefault

public class UserSettings {
    @Wrapper(key: .someFlag, defaultValue: false)
    public var someFlag: Bool
    
    @Wrapper(key: .arrayOfStrings, defaultValue: [])
    public var arrayOfStrings: [String]

    @Wrapper(key: .betterOptionalFlag)
    public var betterOptionalFlag: Bool?

    @WrappedUserDefault(key: .rawRepresentableWithIntValue, defaultValue: CustomRawRepresentable<Int>(rawValue: 111))
    public var rawRepresentableWithIntValue: CustomRawRepresentable<Int>

    @WrappedUserDefault(key: .rawRepresentableWithStringValue, defaultValue: EnumWithStringAsRawValue.default)
    public var rawRepresentableWithStringValue: EnumWithStringAsRawValue

    @WrappedUserDefault(key: .rawRepresentableWithDictValue, defaultValue: CustomRawRepresentable<[String: [Float]]>(rawValue: [:]))
    public var rawRepresentableWithDictValue: CustomRawRepresentable<[String: [Float]]>

    @OptionalWrappedUserDefault(key: .optionalRawRepresentableWithDataValue)
    public var optionalRawRepresentableWithDataValue: CustomRawRepresentable<Data>?
    
    @WrappedUserDefault(key: .rawRepresentableWithArrayOfDates, defaultValue: CustomRawRepresentable<[Date]>(rawValue: [Date(timeIntervalSince1970: 0)]))
    public var rawRepresentableWithArrayOfDates: CustomRawRepresentable<[Date]>
    
    public init() {}
}
