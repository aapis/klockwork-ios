//
//  LegendLabel.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-06.
//

import SwiftUI

struct LegendLabel: View {
    public let label: String
    public let icon: String? = nil

    var body: some View {
        HStack(spacing: 5) {
            if icon != nil {
                Image(systemName: icon!)
            }

            Text(label)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            Spacer()
        }
    }
}
