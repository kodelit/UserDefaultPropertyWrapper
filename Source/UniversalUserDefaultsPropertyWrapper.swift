//
//  UniversalUserDefaultsPropertyWrapper.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 28/03/2021.
//

import Foundation

@propertyWrapper
public struct UniversalUserDefault<T>: UserDefaultStorageManipulating {
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
}

extension UniversalUserDefault where T == Optional<PlistCompatible> {
    public init(key: Key, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.defaultValue = nil
        self.userDefaults = userDefaults ?? UserDefaults.standard
    }
}

extension UniversalUserDefault where T: PlistCompatible {
    public init(key: Key, defaultValue: T, userDefaults: UserDefaults? = nil) {
        self._key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults ?? UserDefaults.standard
    }
}
