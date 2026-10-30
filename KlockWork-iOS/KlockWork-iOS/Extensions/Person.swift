//
//  Person.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-20.
//

import SwiftUI

extension Person {
    /// @UserName
    var shortUsername: String {
        if self.name != nil && self.company != nil {
            return String(format: "@%@", self.name?.replacingOccurrences(of: " ", with: "") ?? "Invalid")
        }

        return "@nobody"
    }

    /// @Company/UserName
    var longUsername: String {
        if self.name != nil && self.company != nil {
            return String(format: "@%@/%@", self.company!.abbreviation ?? ".", self.name?.replacingOccurrences(of: " ", with: "") ?? "Invalid")
        }

        return "@IT/nobody"
    }
}
