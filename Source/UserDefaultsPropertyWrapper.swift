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
            switch value as Any {
                //swiftlint:disable:next syntactic_sugar
            case Optional<Any>.some(let containedValue):
                //swiftlint:disable:next force_cast
                return containedValue as! T
            case Optional<Any>.none:
                return defaultValue
            default:
                // type `T` is not optional
                return value ?? defaultValue
            }
        }
        set {
            switch newValue as Any {
                //swiftlint:disable:next syntactic_sugar
            case Optional<Any>.some(let containedValue):
                UserDefaults.standard.set(containedValue, forKey: key)
            case Optional<Any>.none:
                UserDefaults.standard.removeObject(forKey: key)
            default:
                // type `T` is not optional
                UserDefaults.standard.set(newValue, forKey: key)
            }
        }
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
}
