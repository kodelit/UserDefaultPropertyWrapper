//
//  UserDefaultsPropertyWrapper.swift
//  UserDefaultsPropertyWrapper
//
//  Created by Grzegorz Maciak on 12/11/2019.
//  Copyright © 2019 kodelit. All rights reserved.
//  This code is distributed under the terms and conditions of the MIT license.
//  See: https://opensource.org/licenses/MIT
//
//  Implementation details: https://dev.to/kodelit/userdefaults-property-wrapper-issues-solutions-4lk9

import Foundation

public protocol PlistCompatible {}

// MARK: - UserDefaults Compatibile Types

extension String: PlistCompatible {}
extension Int: PlistCompatible {}
extension Double: PlistCompatible {}
extension Float: PlistCompatible {}
extension Bool: PlistCompatible {}
extension Date: PlistCompatible {}
extension Data: PlistCompatible {}
extension Array: PlistCompatible where Element: PlistCompatible {}
extension Dictionary: PlistCompatible where Key: PlistCompatible, Value: PlistCompatible {}


/// Wrapper for the property with non-optional value which should be stored in `UserDefaults.standard`
/// under the given `key` instead of using backing variable
///
/// The value can be only property list objects: `Data`, `String`, `Double`, `Float`, `Int`,
/// `Bool`,`Date`, `Array`, or `Dictionary`. For `Array` and `Dictionary`
/// objects, their contents must also be of types above. For more details read documentation for
/// [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3)
/// class which is utilized by the wrapper.
///
/// For Optional types use `@OptionalUserDefault(key:)` instead.
@propertyWrapper
public struct UserDefault<T: PlistCompatible> : UserDefaultStorageManipulating {
    public let key: String
    public let defaultValue: T
    public var initialValue: T?
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public init(wrappedValue: T, key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.wrappedValue = wrappedValue
        self.initialValue = wrappedValue
    }
}

/// Wrapper for the property of non-optional type `T` conforming to `RawRepresentable` protocol
/// Value is represented by `rawValue` stored in `UserDefaults.standard`
/// under the given `key`
///
/// The `T.RawValue` type  has to be one of property list compatibile types:
/// `Data`, `String`, `Double`, `Float`, `Int`, `Bool`, `Date`, `Array`, or `Dictionary`.
/// For `Array` and `Dictionary` objects, their contents must also be of types above.
/// For more details read documentation for
/// [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3)
/// class which is utilized by the wrapper.
///
/// For Optional types use `@OptionalWrappedUserDefault(key:)` instead.
@propertyWrapper
public struct WrappedUserDefault<T: RawRepresentable> : UserDefaultStorageManipulating where T.RawValue: PlistCompatible {
    public let key: String
    public let defaultValue: T
    public var initialValue: T?
    public var wrappedValue: T {
        get {
            guard let value = UserDefaults.standard.object(forKey: key) as? T.RawValue else {
                return defaultValue
            }
            return T.init(rawValue: value) ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public init(wrappedValue: T, key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
        self.wrappedValue = wrappedValue
        self.initialValue = wrappedValue
    }
}

/// Wrapper for the property with optional value which should be stored in `UserDefaults.standard`
/// under the given `key` instead of using backing variable
///
/// The value can be only property list objects: `Data`, `String`, `Double`, `Float`, `Int`,
/// `Bool`,`Date`, `Array`, or `Dictionary`. For `Array` and `Dictionary`
/// objects, their contents must also be of types above. For more details read documentation for
/// [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3)
/// class which is utilized by the wrapper.
///
/// For non-optional types use `@UserDefault(key:defaultValue:)` instead.
@propertyWrapper
public struct OptionalUserDefault<T: PlistCompatible> : UserDefaultStorageManipulating {
    public let key: String
    public var initialValue: T?
    public var wrappedValue: T? {
        get {
            return UserDefaults.standard.object(forKey: key) as? T
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }

    public init(key: String) {
        self.key = key
    }

    public init(wrappedValue: T?, key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
        self.initialValue = wrappedValue
    }
}

/// Wrapper for the property of optional type `T?` conforming to `RawRepresentable` protocol
/// Value is represented by `rawValue` stored in `UserDefaults.standard`
/// under the given `key`
///
/// The `T.RawValue` type  has to be one of property list compatibile types:
/// `Data`, `String`, `Double`, `Float`, `Int`, `Bool`, `Date`, `Array`, or `Dictionary`.
/// For `Array` and `Dictionary` objects, their contents must also be of types above.
/// For more details read documentation for
/// [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3)
/// class which is utilized by the wrapper.
///
/// For non-optional types use `@WrappedUserDefault(key:defaultValue:)` instead.
@propertyWrapper
public struct OptionalWrappedUserDefault<T: RawRepresentable> : UserDefaultStorageManipulating where T.RawValue: PlistCompatible {
    public let key: String
    public var initialValue: T?
    public var wrappedValue: T? {
        get {
            guard let value = UserDefaults.standard.object(forKey: key) as? T.RawValue else {
                return nil
            }
            return T.init(rawValue: value)
        }
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: key)
        }
    }

    public init(key: String) {
        self.key = key
    }

    public init(wrappedValue: T?, key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
        self.initialValue = wrappedValue
    }
}

// MARK: - Reseting/Removing property value from UserDefaults

public protocol UserDefaultStorageManipulating {
    associatedtype T
    var key: String { get }
    var initialValue: T? { get }

    /// Overrides value in the storage with `initialValue`
    ///
    /// Rewrites `initialValue` directly to the storage (`UserDefaults.standard`).
    /// If `initialValue` was not defined (is equal `nil`) this method bahaves the same as `removeStorageValue()`
    func resetStorageValue()

    /// Removes value from the storage.
    ///
    /// Removes value directly form the storage (`UserDefaults.standard`).
    func removeStorageValue()
}

extension UserDefaultStorageManipulating where T: PlistCompatible {
    public func resetStorageValue() {
        UserDefaults.standard.set(initialValue, forKey: key)
    }
}

extension UserDefaultStorageManipulating where T: RawRepresentable {
    public func resetStorageValue() {
        UserDefaults.standard.set(initialValue?.rawValue, forKey: key)
    }
}

extension UserDefaultStorageManipulating {
    public func removeStorageValue() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
