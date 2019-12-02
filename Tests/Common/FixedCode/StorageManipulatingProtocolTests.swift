//
//  StorageManipulatingProtocolTests.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 30/11/2019.
//

import XCTest

enum Constants {
    static let languageWithInitialValueKey = "languageWithInitialValueKey"
    static let languageWithoutInitialValueKey = "languageKey"
}

enum Language: String {
    case english = "en"
    case finnish = "fi"
    case swedish = "sv"
}

struct Settings {
    @WrappedUserDefault(key: Constants.languageWithInitialValueKey, defaultValue: .english)
    var languageWithInitialValue: Language = .finnish

    @WrappedUserDefault(key: Constants.languageWithoutInitialValueKey, defaultValue: .english)
    var languageWithoutInitialValue: Language

    var defaultValueOf_languageWithInitialValue: Language {
        return _languageWithInitialValue.defaultValue
    }

    var defaultValueOf_languageWithoutInitialValue: Language {
        return _languageWithoutInitialValue.defaultValue
    }

    var initialValueOf_languageWithInitialValue: Language? {
        return _languageWithInitialValue.initialValue
    }

    var initialValueOf_languageWithoutInitialValue: Language? {
        return _languageWithoutInitialValue.initialValue
    }

    func resetStorageValues() {
        _languageWithInitialValue.resetStorageValue()
        _languageWithoutInitialValue.resetStorageValue()
    }

    func removeStorageValues() {
        _languageWithInitialValue.removeStorageValue()
        _languageWithoutInitialValue.removeStorageValue()
    }
}

// MARK: -

class StorageManipulatingProtocolTests: XCTestCase {
    private func reset() {
        UserDefaults.standard.removeObject(forKey: Constants.languageWithInitialValueKey)
        UserDefaults.standard.removeObject(forKey: Constants.languageWithoutInitialValueKey)
    }

    override func setUp() {
        reset()
    }

    override func tearDown() {
        reset()
    }

    // MARK: - Reseting and Removeing of stored value

    func testWrappedUserDefault_propertyWithInitWalue_reset_and_remove_storage_value() {
        // MARK: property with initialValue
        let key = Constants.languageWithInitialValueKey

        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        var settings = Settings()
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        let defaultValue = settings.defaultValueOf_languageWithInitialValue
        let initialValue = settings.initialValueOf_languageWithInitialValue

        var lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), initialValue)
        XCTAssertEqual(settings.languageWithInitialValue, initialValue)

        let customValue = Language.swedish
        settings.languageWithInitialValue = customValue
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), customValue)
        XCTAssertEqual(settings.languageWithInitialValue, customValue)

        // removeing of the storage value should cause that the property returns `initialValue` if was defined or `defaultValue` in other case
        settings.resetStorageValues()
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), initialValue)
        XCTAssertEqual(settings.languageWithInitialValue, initialValue)

        // removeing of the storage value should cause that the property returns `defaultValue`
        settings.removeStorageValues()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.languageWithInitialValue, defaultValue)

        settings.resetStorageValues()
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), initialValue)
        XCTAssertEqual(settings.languageWithInitialValue, initialValue)
    }

    func testWrappedUserDefault_reseting_and_removing_storage_value_property_without_initial_value() {
        // MARK: property without initialValue

        let key = Constants.languageWithoutInitialValueKey
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        var settings = Settings()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        let defaultValue = settings.defaultValueOf_languageWithoutInitialValue
        let initialValue = settings.initialValueOf_languageWithoutInitialValue
        XCTAssertNil(initialValue)

        var lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.languageWithoutInitialValue, defaultValue)

        let customValue = Language.swedish
        settings.languageWithoutInitialValue = customValue
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), customValue)
        XCTAssertEqual(settings.languageWithoutInitialValue, customValue)

        // removeing of the storage value should cause that the property returns `initialValue` if was defined or `defaultValue` in other case
        settings.resetStorageValues()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.languageWithoutInitialValue, defaultValue)

        // removeing of the storage value should cause that the property returns `defaultValue`
        settings.removeStorageValues()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.languageWithoutInitialValue, defaultValue)

        settings.resetStorageValues()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.languageWithoutInitialValue, defaultValue)
    }
}
