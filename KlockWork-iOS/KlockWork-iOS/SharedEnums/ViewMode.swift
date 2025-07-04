//
//  ViewMode.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-29.
//

import SwiftUI

enum ViewMode: CaseIterable {
    case tabular, hierarchical, calendar

    var id: Int {
        switch(self) {
        case .hierarchical: 1
        case .tabular: 0
        case .calendar: 2
        }
    }

    var icon: String {
        switch self {
        case .hierarchical: "list.bullet.indent"
        case .tabular: "tablecells"
        case .calendar: "calendar"
        }
    }

    var label: String {
        switch(self) {
        case .hierarchical: "Hierarchical"
        case .tabular: "Tabular"
        case .calendar: "Calendar"
        }
    }

    static public func by(id: Int) -> ViewMode? {
        for mode in Self.allCases {
            if mode.id == id {
                return mode
            }
        }

        return nil
    }
}
