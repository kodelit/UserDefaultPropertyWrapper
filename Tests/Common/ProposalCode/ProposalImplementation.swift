//
//  ProposalImplementation.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import Foundation

@propertyWrapper public struct ProposalUserDefault<T> {
    public let key: String
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            let udObject = UserDefaults.standard.object(forKey: key)
            let udValue = udObject as? T
            let value = udValue ?? defaultValue
            print("get UDObject:", udObject as Any, "UDValue:", udValue as Any, "defaultValue:", defaultValue, "returned value:", value)
            return value
        }
        set {
            print("set UDValue:", newValue as Any, "for key:", key)
            // Crashes if `T` is some optional type because `newValue` is `Optional(Optional(nil))`
            // That is why `OptionalUserDefault<T>` should be used for optional values
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        print("Property Init with key: '\(key)', defaultValue: '\(defaultValue)'")
    }

    public init(wrappedValue: T, key: String, defaultValue: T) {
        print("Property Init with initialValue: '\(wrappedValue)', for key: '\(key)', defaultValue: '\(defaultValue)'")
        self.key = key
        self.defaultValue = defaultValue
        self.wrappedValue = wrappedValue
    }
}
