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

Here you can take a look on the content of the `UserDefaultsPropertyWrapper.swift`

### 1. Solution for property with Optional type

Simple option and maybe preferred by some people is to use separate wrapper for optional values

```
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
```

The solution is not so bad because:

- distinguishes the case where the value is optional
- there is no need to define `defautlValue` because it is not needed since we expect that the value might not be there.

However **it does not guaranty that nobody will use `@UserDefault(key:defaultValue:)` attribute to a property with Optional type**.

That's why we should fix the proposal code.

### 2. Improved solution form proposal

There is another solution which allows us to use one wrapper for every mentioned case or at least make it safer.

```
@propertyWrapper
public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            let value = UserDefaults.standard.object(forKey: key) as? T
            switch (value as Any) {
            case Optional<Any>.some(let containedValue):
                //swiftlint:disable:next force_unwrapping
                return containedValue as! T
            case Optional<Any>.none:
                return defaultValue
            default:
                // type `T` is not optional
                return value ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
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
```
