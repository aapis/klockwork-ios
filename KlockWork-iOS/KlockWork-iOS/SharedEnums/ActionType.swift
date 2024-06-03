//
//  ActionType.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-02.
//

import SwiftUI

public enum ActionType {
    case create, interaction

    // @TODO: localize, somehow?
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

    // @TODO: localize, somehow?
    var enModifyLabel: String {
        switch self {
        case .create: "creation"
        case .interaction: "interaction"
        }
    }
}
