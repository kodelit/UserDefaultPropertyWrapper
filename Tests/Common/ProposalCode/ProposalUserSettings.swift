//
//  ProposalUserSettings.swift
//  UserDefaultPropertyWrapperTests
//
//  Created by Grzegorz Maciak on 18/11/2019.
//

import Foundation

class ProposalUserSettings {
    enum Key {
        static let someFlag = "some_flag"
        static let flagWithInitialValue = "flag_with_initial_value"
        static let optionalFlagDefaultTrue = "optional_flag_default_true"
        static let optionalFlagDefaultNil = "optional_flag_default_nil"
    }

    @ProposalUserDefault(key: Key.someFlag, defaultValue: false)
    public var someFlag: Bool

    @ProposalUserDefault(key: Key.flagWithInitialValue, defaultValue: false)
    public var flagWithInitialValue: Bool = true

    @ProposalUserDefault(key: Key.optionalFlagDefaultTrue, defaultValue: true)
    public var optionalFlagDefaultTrue: Bool?

    @ProposalUserDefault(key: Key.optionalFlagDefaultNil, defaultValue: nil)
    public var optionalFlagDefaultNil: Bool?
}
