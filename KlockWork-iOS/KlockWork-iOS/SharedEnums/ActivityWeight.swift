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

    var label: String {
        switch self {
        case .empty: "Clear"
        case .light: "Light"
        case .medium: "Busy"
        case .heavy: "At Capacity"
        case .significant: "Overloaded"
        }
    }
}
