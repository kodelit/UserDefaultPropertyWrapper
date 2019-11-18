//
//  UserDefaultPropertyWrapper.swift
//  UserDefaultPropertyWrapper
//
//  Created by Grzegorz Maciak on 12/11/2019.
//  Copyright © 2019 kodelit. All rights reserved.
//  This code is distributed under the terms and conditions of the MIT license.
//  See: https://opensource.org/licenses/MIT
//

import Foundation

//  see: https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#user-defaults

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
public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            let value = UserDefaults.standard.object(forKey: key) as? T
            // try to unwrap value
            switch (value as Any) {
            case Optional<Any>.some(let containedValue):
                // Unwrapped value is Optional and has value
                //swiftlint:disable:next force_unwrapping
                return containedValue as! T
            case Optional<Any>.none:
                // Unwrapped value is Optional and has no value
                return defaultValue
            default:
                // value is not optional
                return value ?? defaultValue
            }
        }
        set {
            // try to unwrap value
            switch (newValue as Any) {
            case Optional<Any>.some(let containedValue):
                // Unwrapped value is Optional and has value
                UserDefaults.standard.set(containedValue, forKey: key)
            case Optional<Any>.none:
                // Unwrapped value is Optional and has no value
                UserDefaults.standard.removeObject(forKey: key)
            default:
                // value is not optional
                UserDefaults.standard.set(newValue, forKey: key)
            }
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
public struct OptionalUserDefault<T> {
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

    public init(wrappedValue: T, key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
    }
}
