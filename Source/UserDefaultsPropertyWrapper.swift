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
extension Array: PlistCompatible where Element: PlistCompatible {}
extension Dictionary: PlistCompatible where Key: PlistCompatible, Value: PlistCompatible {}
extension Data: PlistCompatible {}

/// Wrapper for property with non-optional value which should be stored in `UserDefaults.standard`
/// under the given `key` instead of using backing variable
///
/// The value can be only property list objects: `NSData`, `NSString`, `NSNumber`, `NSDate`,
/// `NSArray`, or `NSDictionary` or their equivalents in Swift. For `NSArray` and `NSDictionary`
/// objects, their contents must be property list objects. For more information, see
/// [What is a Property List?](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html#//apple_ref/doc/uid/10000048i-CH3-54303)
/// in
/// [Property List Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048i)
/// or about [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3) class which is utilized
/// by the wrapper.
///
/// For Optional types use `@OptionalUserDefault(key:)` instead.
@propertyWrapper
public struct UserDefault<T: PlistCompatible> {
    public let key: String
    public let defaultValue: T
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
    }
}

@propertyWrapper
public struct WrappedUserDefault<T: RawRepresentable> where T.RawValue: PlistCompatible {
    public let key: String
    public let defaultValue: T
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
    }
}

/// Wrapper for property with optional value which should be stored in `UserDefaults.standard`
/// under the given `key` instead of using backing variable
///
/// The value can be only property list objects: `NSData`, `NSString`, `NSNumber`, `NSDate`,
/// `NSArray`, or `NSDictionary` or their equivalents in Swift. For `NSArray` and `NSDictionary`
/// objects, their contents must be property list objects. For more information, see
/// [What is a Property List?](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/AboutPropertyLists/AboutPropertyLists.html#//apple_ref/doc/uid/10000048i-CH3-54303)
/// in
/// [Property List Programming Guide](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/PropertyLists/Introduction/Introduction.html#//apple_ref/doc/uid/10000048i)
/// or about [set(_:forKey:)](apple-reference-documentation://hsvd8Er378)
/// fo the [UserDefaults](apple-reference-documentation://hsARFaqWd3) class which is utilized
/// by the wrapper.
///
/// For non-optional types use `@UserDefault(key:defaultValue:)` instead.
@propertyWrapper
public struct OptionalUserDefault<T: PlistCompatible> {
    public let key: String
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
    }
}

@propertyWrapper
public struct OptionalWrappedUserDefault<T: RawRepresentable> where T.RawValue: PlistCompatible {
    public let key: String
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
    }
}


