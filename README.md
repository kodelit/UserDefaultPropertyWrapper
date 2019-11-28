# UserDefault property wrapper

Property wrapper is the new feature in Swift 5.1. There are plenty of articles covering the topic about using this feature for many purposes. One of them is wrapping property around UserDefaults, which means using UserDefaults (`UserDefults.standard` in most cases but this is not the only possibility) instead of backing variable for the property.

There are so many places where you can read about Property Wrappers and using it to wrap `UserDefaults`:

- [Proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#user-defaults) - where everything started
- [NSHipster - Swift Property Wrappers](https://nshipster.com/propertywrapper/)
- [SwiftLee - Property wrappers to remove boilerplate code in Swift](https://www.avanderlee.com/swift/property-wrappers/)
- and others.

However, everyone is focusing only on the simplest cases but no one is speaking about the issues. And there are issues but more details about them you can find in my article [UserDefaults property wrapper - Issues & Solutions](https://dev.to/kodelit/userdefaults-property-wrapper-issues-solutions-4lk9).

This repo contains:

- code of the solution `UserDefaultsPropertyWrapper.swift`,
- playground with some code showing how it works and where is the issue,
- images showing errors used in the article.


## Preview of the solution

Here you can take a look on the content of the [`UserDefaultsPropertyWrapper.swift`](Source/UserDefaultsPropertyWrapper.swift)

### 1. Solution for property with Non-Optional type (improved solution form proposal)

There is another solution which allows us to use one wrapper for every mentioned case or at least make it safer.

```swift
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
```

### 2. Solution for property with Optional type

Separate wrapper for optional values

```swift
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
```

The solution is not so bad because:

- distinguishes the case where the value is optional
- there is no need to define `defautlValue` because it is not needed since we expect that the value might not be there.



### 3. What is `PlistCompatible` protocol and what types confroms to it?

```swift
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
```

## Support for `RawRepresentable` types

Sometimes we store in `UserDefaults` some representation of our custom type. To be able store and reload custom types we just need to

1. Make them conform to `RawRepresentable` protocol
2. Use one of property wrappers for types represented by raw value using attributes:

	- `@WrappedUserDefault(key:defaultValue:)`
	- `@OptionalWrappedUserDefault(key:)`

### Implementation details

#### 1. Non-optional type properties
```swift
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
```

#### 2. Optional type properties
```swift
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
```