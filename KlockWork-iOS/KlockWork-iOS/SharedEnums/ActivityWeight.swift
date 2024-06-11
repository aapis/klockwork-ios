//
//  ActivityWeight.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

/// Levels representing an amount of work
public enum ActivityWeight: CaseIterable {
    case empty, light, medium, heavy, significant

    var colour: Color {
        switch self {
        case .empty: .clear
        case .light: Theme.rowColour
        case .medium: Theme.cYellow
        case .heavy: Theme.cRed
        case .significant: .black
        }
    }

    var colourOpacity: Double {
        switch self {
        case .light: 0.2
        default: 1.0
        }
    }

    var label: String {
        switch self {
        case .empty: "Clear"
        case .light: "Light"
        case .medium: "Busy"
        case .heavy: "At Capacity"
        case .significant: "Overloaded"
        }
    }

    var defaultValue: Int64 {
        switch self {
        case .empty: 0
        case .light: 5
        case .medium: 10
        case .heavy: 15
        case .significant: 20
        }
    }
}
