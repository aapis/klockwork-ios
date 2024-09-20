//
//  Company.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-20.
//

import SwiftUI

extension Company {
    var backgroundColor: Color {
        if let c = self.colour {
            return Color.fromStored(c)
        }

        return Color.clear
    }
}
