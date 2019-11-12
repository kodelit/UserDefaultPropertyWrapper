# UserDefaults property wrapper

Skip the boring: [Solution for property with Optional type](#optional-user-default) | [Improved solution form proposal](#improved-user-default)

Property wrapper is the new feature in Swift 5.1. There are plenty of articles covering the topic about using this feature for many purposes. One of them is wrapping property around UserDefaults, which means using UserDefaults (`UserDefults.standard` in most cases but this is not the only possibility) instead of backing variable for the property.

I do not want to duplicate the topic when there are so many other places where this is described very well:

- [Proposal](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md#user-defaults) - where every thing started
- [NSHipster - Swift Property Wrappers](https://nshipster.com/propertywrapper/)
- [SwiftLee - Property wrappers to remove boilerplate code in Swift](https://www.avanderlee.com/swift/property-wrappers/)
- and others.

However, everyone is focusing only on the simplest cases but no one is speaking about the issues.

## What if...

Let's take some example implementation of the property wrapper:

```
@propertyWrapper public struct UserDefault<T> {
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
}
```

All seams to look good and it works in the most common cases like:

```
@UserDefault(key: "some_flag", defaultValue: false)
public var someFlag: Bool
```

Maybe sometimes there will be a need to set also initial value despite we have the `defaultValue`, then we have to add following two initializers:

```
public init(key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
}

public init(wrappedValue: T, key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
    self.wrappedValue = wrappedValue
}
```

now we can use it also like this:

```
@UserDefault(key: "some_flag", defaultValue: false)
public var someFlag: Bool = true
```

### But what if the type of the property will be Optional value type?

This generic struct might be adopted in such case. What happens then?
To find out I'm going to use the [playgraound file](UserDefaultPropertyWrapper.playground) where

#### 1. Property wrapper is modified like this:

```
@propertyWrapper public struct UserDefault<T> {
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
            UserDefaults.standard.set(newValue as Any, forKey: key)
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
```

#### 2. Property is defined as the following:

```
class Some {
	@UserDefault(key: "optional_flag", defaultValue: false)
	public var optionalFlag: Bool?
}
```

#### 3. Let's test getter and setter:

```
let object = Some()

object.optionalFlag
object.optionalFlag = true
object.optionalFlag
object.optionalFlag = nil
```

Console:
	
```
Property Init with key: 'optional_flag', defaultValue: 'Optional(false)'
get UDObject: nil UDValue: Optional(nil) defaultValue: Optional(false) returned value: nil
set UDValue: Optional(true) for key: optional_flag
get UDObject: Optional(1) UDValue: Optional(Optional(true)) defaultValue: Optional(false) returned value: Optional(true)
set UDValue: nil for key: optional_flag
libc++abi.dylib: terminating with uncaught exception of type NSException
```
This is quite tricky.
First get a fix on the fact that `print(...)` method used to print console logs unwraps values, so for `Optional<Bool>(nil)` or if you will `Optional<Bool>.none` it will print `nil`, and for `Optional<Bool?>(value)` will print `Optional(value)`.

As we can see in console log line 2: UDValue is not `nil` but in fact `Optional(nil)` which means that it is wrapped twice. It is even more visible in line 4 of the console log above.

It can be simply confirmed by printing:

```
print(Optional<Bool>(nil))                       // nil
print(Optional<Bool?>.some(Optional<Bool>(nil))) // Optional(nil)
print(Optional<Bool?>.some(Optional<Bool>(true)))// Optional(Optional(true))
```

Why is that? Because we use conditional cast on Optional type: `as? T` where `T` is `Bool?` so we do something like this `as? Bool?` which returns `Bool??`

### So what is happening?

#### 1. The getter

When stored value is `nil` (simply not set in `UserDefaults`) we have:

```
let defaultValue: Bool? = Optional<Bool>.some(false)
let udObject: Bool? = Optional<Bool>.none
let udValue: Bool?? = (Optional<Bool>.none as? Bool?) // Optional<Bool?>.some(Optional<Bool>.none)
let value: Bool? = Optional<Bool?>.some(Optional<Bool>.none) ?? defaultValue // expression returns `Optional<Bool>.none` not `defaultValue`
print("get UDObject:", udObject, "UDValue:", udValue, "defaultValue:", defaultValue, "returned value:", value)
```

So what we see here?

1. getter will never return `defaultValue` if type of the property `T` is `Optional` type
2. returned value will be `nil` which is a valid value for `Bool?` type

The same case is with concrete value
As long as this issue causes only some unexpected behavior, there is a much worse issue.

#### 2. The setter

When we try to set `nil` to the property with Optional type the setter crashes:

![error-on-setter-crush](setter-crash-on-nil.png)
	
Long story short this is also caused by the Optional in the Optional, and the same same error occurs if you write:
`UserDefaults.standard.set(Optional(Optional<Bool>(nil)), forKey: "optional_flag")`
![error-on-setter-crush](user-defaults-setter-crash.png)

## What we can do?

<a name="optional-user-default"></a>
### 1. Solution for property with Optional type [↩](#)

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

<a name="improved-user-default"></a>
### 2. Improved solution form proposal [↩](#)

There is another solution which allows us to use one wrapper for every mentioned case or at least make it safer.

```
@propertyWrapper
public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            let udValue = UserDefaults.standard.object(forKey: key) as? T
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                return value as! T
            case Optional<Any>.none:
                return defaultValue
            default:
                return udValue ?? defaultValue
            }
        }
        set {
            switch (newValue as Any) {
            case Optional<Any>.some(let value):
                UserDefaults.standard.set(value, forKey: key)
            case Optional<Any>.none:
                UserDefaults.standard.removeObject(forKey: key)
            default:
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
```

And that's it.
