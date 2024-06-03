//
//  ActionType.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-02.
//

import SwiftUI

public enum ActionType {
    case create, interaction

    var label: String {
        switch self {
        case .create: "Create"
        case .interaction: "Interaction"
        }
    }

    // @TODO: localize, somehow?
    var enPlural: String {
        switch self {
        case .create: "created"
        case .interaction: "interaction(s)"
        }
    }

    // @TODO: localize, somehow?
    var enSingular: String {
        switch self {
        case .create: "created"
        case .interaction: "interaction"
        }
    }
}
