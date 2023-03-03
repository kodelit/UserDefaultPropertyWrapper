//
//  StorageManipulatingProtocolTests.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 30/11/2019.
//

import XCTest

extension PropertyKey {
    static let languageKey: PropertyKey = "languageKey"
}

enum Language: String {
    case english = "en"
    case finnish = "fi"
    case swedish = "sv"
}

struct Settings {
    @WrappedUserDefault(key: .languageKey, defaultValue: .english)
    var language: Language

    var defaultValueOf_language: Language {
        return _language.defaultValue
    }

    func removeStorageValues() {
        _language.removeStorageValue()
    }
}

// MARK: -

class StorageManipulatingProtocolTests: XCTestCase {
    private func reset() {
        UserDefaults.standard.removeObject(forKey: PropertyKey.languageKey.rawKey ?? "")
    }

    override func setUp() {
        reset()
    }

    override func tearDown() {
        reset()
    }

    // MARK: - Reseting and Removeing of stored value

    func testWrappedUserDefault_reseting_and_removing_storage_value_property_without_initial_value() {
        // MARK: property without initialValue

        let key = PropertyKey.languageKey.rawKey ?? ""
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        var settings = Settings()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        let defaultValue = settings.defaultValueOf_language

        var lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.language, defaultValue)

        let customValue = Language.swedish
        settings.language = customValue
        XCTAssertNotNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNotNil(lang)
        XCTAssertEqual(Language(rawValue: lang!), customValue)
        XCTAssertEqual(settings.language, customValue)

        // removeing of the storage value should cause that the property returns `defaultValue`
        settings.removeStorageValues()
        XCTAssertNil(UserDefaults.standard.object(forKey: key))

        lang = UserDefaults.standard.object(forKey: key) as? Language.RawValue
        XCTAssertNil(lang)
        XCTAssertEqual(settings.language, defaultValue)
    }
}
