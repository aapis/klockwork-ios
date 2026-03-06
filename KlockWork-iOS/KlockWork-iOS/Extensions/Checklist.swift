//
//  Checklist.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-26.
//

import SwiftUI

extension Checklist {
    var backgroundColour: Color {
        if let c = self.colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }
}
