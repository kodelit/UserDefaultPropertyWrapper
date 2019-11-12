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

//: ### Test of the solutions
let someFlagKey = "some_flag"
let flagWithInitialValueKey = "flag_with_initial_value"
let optionalFlagKey = "optional_flag"

// We have to reset UserDefaults because the values remain between lanches
UserDefaults.standard.removeObject(forKey: someFlagKey)
UserDefaults.standard.removeObject(forKey: flagWithInitialValueKey)
UserDefaults.standard.removeObject(forKey: optionalFlagKey)

class Some {
    @ProposalUserDefault(key: someFlagKey, defaultValue: false)
    public var someFlag: Bool

    @ProposalUserDefault(key: flagWithInitialValueKey, defaultValue: false)
    public var flagWithInitialValue: Bool = true

    @ProposalUserDefault(key: optionalFlagKey, defaultValue: false) // crashes for `nil`
    public var optionalFlag: Bool?
}

let object = Some()

// property wityout initial value (common case)
object.someFlag

// property with initial value
object.flagWithInitialValue

// property with optional value
object.optionalFlag
object.optionalFlag = true
object.optionalFlag

// any of folowing two lines will crash
//UserDefaults.standard.set(Optional(Optional<Bool>(nil)), forKey: optionalFlagKey)
object.optionalFlag = nil // comment this line to go through the following code

print(Optional<Bool>(nil) as Any)                       // nil
print(Optional<Bool?>.some(Optional<Bool>(nil)) as Any) // Optional(nil)
print(Optional<Bool?>.some(Optional<Bool>(true)) as Any)// Optional(Optional(true))

//: What is happening in the getter?
let defaultValue: Bool? = Optional<Bool>.some(false)
let udObject: Bool? = Optional<Bool>.none
let udValue: Bool?? = (Optional<Bool>.none as? Bool?) // Optional<Bool?>.some(Optional<Bool>.none)
let value: Bool? = Optional<Bool?>.some(Optional<Bool>.none) ?? defaultValue // expression returns `Optional<Bool>.none` not `defaultValue`
print("get UDObject:",      udObject        as Any,
      "UDValue:",           udValue         as Any,
      "defaultValue:",      defaultValue    as Any,
      "returned value:",    value           as Any)

//: or if you like
print("get UDObject:",      Optional<Bool?>.none                        as Any,
      "UDValue:",           Optional<Bool?>.some(Optional<Bool>.none)   as Any,
      "defaultValue:",      Optional<Bool>.some(false)                  as Any,
      "returned value:",    Optional<Bool>.none                         as Any)


//: ## Solution
//: 1. Separate wrapper for Optional types
@propertyWrapper
public struct OptionalUserDefault<T> {
    public let key: String
    public var wrappedValue: T? {
        get {
            let value = UserDefaults.standard.object(forKey: key) as? T
            print("get UDValue:", value as Any, "returned value:", value as Any)
            return value
        }
        set {
            print("set UDValue:", newValue as Any, "for key:", key)
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

//: 2. Fixed UserDefault<T> wrapper
@propertyWrapper
public struct UserDefault<T> {
    public let key: String
    public let defaultValue: T
    public var wrappedValue: T {
        get {
            let udObject = UserDefaults.standard.object(forKey: key)
            let udValue = udObject as? T
            var result: T
            switch (udValue as Any) {
            case Optional<Any>.some(let value):
                result = value as! T
            case Optional<Any>.none:
                result = defaultValue
            default:
                result = udValue ?? defaultValue
            }
            print("get UDObject:", udObject as Any, "UDValue:", udValue as Any, "defaultValue:", defaultValue, "returned value:", result)
            return result
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
            print("set UDValue:", newValue as Any, "for key:", key)
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

//: ### Test of the new solutions
let fixedOptionalFlagKey = "better_optional_flag"
let betterOptionalFlagKey = "fixed_optional_flag"

// We have to reset UserDefaults because the values remain between lanches
UserDefaults.standard.removeObject(forKey: someFlagKey)
UserDefaults.standard.removeObject(forKey: flagWithInitialValueKey)
UserDefaults.standard.removeObject(forKey: optionalFlagKey)
UserDefaults.standard.removeObject(forKey: fixedOptionalFlagKey)
UserDefaults.standard.removeObject(forKey: betterOptionalFlagKey)


class OSome {
    @UserDefault(key: someFlagKey, defaultValue: false)
    public var someFlag: Bool

    @UserDefault(key: flagWithInitialValueKey, defaultValue: false)
    public var flagWithInitialValue: Bool = true

    @UserDefault(key: fixedOptionalFlagKey, defaultValue: true)
    public var optionalFlag: Bool?

    @OptionalUserDefault(key: betterOptionalFlagKey)
    public var betterOptionalFlag: Bool?
}

let fixedObject = OSome()

// property wityout initial value (common case)
object.someFlag

// property with initial value
object.flagWithInitialValue // returns initial value
UserDefaults.standard.removeObject(forKey: flagWithInitialValueKey)
object.flagWithInitialValue // returns default value

// property with optional value
fixedObject.betterOptionalFlag
fixedObject.betterOptionalFlag = true
fixedObject.betterOptionalFlag
fixedObject.betterOptionalFlag = nil
fixedObject.betterOptionalFlag

//
fixedObject.optionalFlag
fixedObject.optionalFlag = nil

