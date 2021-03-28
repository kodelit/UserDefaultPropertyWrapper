//
//  UserDefaultsPropertyWrapper.swift
//  UserDefaultsPropertyWrapper
//
//  Created by Grzegorz Maciak on 12/11/2019.
//  Copyright © 2019 kodelit. All rights reserved.
//  Copyright © 2019 Andrzej Jacak. All rights reserved.
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
extension Dictionary: PlistCompatible where Key == String, Value: PlistCompatible {}

public enum PropertyKey: ExpressibleByStringLiteral {
    /// Valid and fixed String key
    case fixed(String)

    /// Key cannot be set at wrapper `init` method and have to be provided later.
    ///
    /// Example: Creating may require `self` to be constructed, therefore it cannot be passed in wrapper `init` but have to be provided later
    /// ```swift
    /// class A {
    ///     let someId: String
    ///
    ///     @UserDefault(key: .notSetYet, defaultValue: false)
    ///     var myProperty: Bool
    ///
    ///     init(someId: String) {
    ///     self.someId  = someId
    ///         _myProperty.key = .fixed("key \(someId)")
    ///     }
    ///     // ...
    /// }
    /// ```
    /// - warning: Only key with value `.notSetYet` can be set this way, and when key is set to `.fixed(String)` it cannot be changed again.
    case notSetYet

    var rawKey: String? {
        if case .fixed(let key) = self {
            return key
        }
        return nil
    }

    public init(stringLiteral value: String) {
        self = value.isEmpty ? .notSetYet : .fixed(value)
    }
}

public typealias UserDefaultPropertyKey = PropertyKey

// MARK: - UserDefault Property Wrappers

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
/// Parameter `key` is an `UserDefaults` key under which value will be stored.  If the key depends on
/// other local variables it might be set to `.notSetYet` and set later to `.fixed(String)` in `init()`,
/// but eventualy before fist use of the property it has to have fixed key.
///
/// For Optional types use `@OptionalUserDefault(key:)` instead.
///
/// - warning: Fixed key can be set only once, and cannot be change later if already set to fixed string.
/// - warning: There should be only one property for the given key in the whole application. If you need to use one UserDefaults entry in many places don't create many properties for the same key because their values will not represent the current value in UserDefaults if one of the properties will be set to the new value. Instead, create one static property and make the other properties to refer to this static value.
@propertyWrapper
public struct UserDefault<T: PlistCompatible>: UserDefaultStorageManipulating {
    public typealias Key = UserDefaultPropertyKey
    private var _key: Key
    public var key: Key {
        get {
            assert(_key.rawKey != nil, "@UserDefault(...) property key not set.")
            return _key
        }
        set {
            if _key.rawKey == nil {
                _key = newValue
            }
        }
    }

    public var isReadOnly = false
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            guard let key = _key.rawKey else { return defaultValue }
            return userDefaults.object(forKey: key) as? T ?? defaultValue
        }
        set {
            guard !isReadOnly, let key = _key.rawKey else { return }
            userDefaults.set(newValue, forKey: key)
        }
    }

    public private(set) var userDefaults: UserDefaults

    public init(key: Key, defaultValue: T, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults ?? UserDefaults.standard
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
/// Parameter `key` is an `UserDefaults` key under which value will be stored.  If the key depends on
/// other local variables it might be set to `.notSetYet` and set later to `.fixed(String)` in `init()`,
/// but eventualy before fist use of the property it has to have fixed key.
///
/// For Optional types use `@OptionalWrappedUserDefault(key:)` instead.
///
/// - warning: Fixed key can be set only once, and cannot be change later if already set to fixed string.
/// - warning: There should be only one property for the given key in the whole application. If you need to use one UserDefaults entry in many places don't create many properties for the same key because their values will not represent the current value in UserDefaults if one of the properties will be set to the new value. Instead, create one static property and make the other properties to refer to this static value.
@propertyWrapper
public struct WrappedUserDefault<T: RawRepresentable>: UserDefaultStorageManipulating where T.RawValue: PlistCompatible {
    public typealias Key = UserDefaultPropertyKey
    private var _key: Key
    public var key: Key {
        get {
            assert(_key.rawKey != nil, "@WrappedUserDefault(...) property key not set.")
            return _key
        }
        set {
            if _key.rawKey == nil {
                _key = newValue
            }
        }
    }

    public var isReadOnly = false
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            guard let key = _key.rawKey,
                let value = userDefaults.object(forKey: key) as? T.RawValue else {
                return defaultValue
            }
            return T.init(rawValue: value) ?? defaultValue
        }
        set {
            guard !isReadOnly, let key = _key.rawKey else { return }
            userDefaults.set(newValue.rawValue, forKey: key)
        }
    }

    public private(set) var userDefaults: UserDefaults

    public init(key: Key, defaultValue: T, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults ?? UserDefaults.standard
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
/// Parameter `key` is an `UserDefaults` key under which value will be stored.  If the key depends on
/// other local variables it might be set to `.notSetYet` and set later to `.fixed(String)` in `init()`,
/// but eventualy before fist use of the property it has to have fixed key.
///
/// For non-optional types use `@UserDefault(key:defaultValue:)` instead.
///
/// - warning: Fixed key can be set only once, and cannot be change later if already set to fixed string.
/// - warning: There should be only one property for the given key in the whole application. If you need to use one UserDefaults entry in many places don't create many properties for the same key because their values will not represent the current value in UserDefaults if one of the properties will be set to the new value. Instead, create one static property and make the other properties to refer to this static value.
@propertyWrapper
public struct OptionalUserDefault<T: PlistCompatible>: UserDefaultStorageManipulating {
    public typealias Key = UserDefaultPropertyKey
    private var _key: Key
    public var key: Key {
        get {
            assert(_key.rawKey != nil, "@OptionalUserDefault(...) property key not set.")
            return _key
        }
        set {
            if _key.rawKey == nil {
                _key = newValue
            }
        }
    }

    public var isReadOnly = false
    public var wrappedValue: T? {
        get {
            guard let key = _key.rawKey else { return nil }
            return userDefaults.object(forKey: key) as? T
        }
        set {
            guard !isReadOnly, let key = _key.rawKey else { return }
            userDefaults.set(newValue, forKey: key)
        }
    }

    public private(set) var userDefaults: UserDefaults

    public init(key: Key, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.userDefaults = userDefaults ?? UserDefaults.standard
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
/// Parameter `key` is an `UserDefaults` key under which value will be stored.  If the key depends on
/// other local variables it might be set to `.notSetYet` and set later to `.fixed(String)` in `init()`,
/// but eventualy before fist use of the property it has to have fixed key.
///
/// For non-optional types use `@WrappedUserDefault(key:defaultValue:)` instead.
///
/// - warning: Fixed key can be set only once, and cannot be change later if already set to fixed string.
/// - warning: There should be only one property for the given key in the whole application. If you need to use one UserDefaults entry in many places don't create many properties for the same key because their values will not represent the current value in UserDefaults if one of the properties will be set to the new value. Instead, create one static property and make the other properties to refer to this static value.
@propertyWrapper
public struct OptionalWrappedUserDefault<T: RawRepresentable>: UserDefaultStorageManipulating where T.RawValue: PlistCompatible {
    public typealias Key = UserDefaultPropertyKey
    private var _key: Key
    public var key: Key {
        get {
            assert(_key.rawKey != nil, "@OptionalWrappedUserDefault(...) property key not set.")
            return _key
        }
        set {
            if _key.rawKey == nil {
                _key = newValue
            }
        }
    }

    public var isReadOnly = false
    public var wrappedValue: T? {
        get {
            guard let key = _key.rawKey,
                let value = userDefaults.object(forKey: key) as? T.RawValue else {
                return nil
            }
            return T.init(rawValue: value)
        }
        set {
            guard !isReadOnly, let key = _key.rawKey else { return }
            userDefaults.set(newValue?.rawValue, forKey: key)
        }
    }

    public private(set) var userDefaults: UserDefaults

    public init(key: Key, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.userDefaults = userDefaults ?? UserDefaults.standard
    }
}

// MARK: - Reseting/Removing property value from UserDefaults

public protocol UserDefaultStorageManipulating {
    //swiftlint:disable:next type_name
    associatedtype T
    var key: UserDefaultPropertyKey { get set }
    var userDefaults: UserDefaults  { get }

    /// Removes value from the storage.
    ///
    /// Removes value directly form the storage (`UserDefaults.standard`).
    func removeStorageValue()
}

extension UserDefaultStorageManipulating {
    public func removeStorageValue() {
        guard let key = key.rawKey else { return }
        userDefaults.removeObject(forKey: key)
    }
}
