//
//  Timestamp.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-02.
//

import SwiftUI

struct Timestamp: View {
    public let text: String

    var body: some View {
        Text(self.text)
            .padding(2)
            .background(.black.opacity(0.6))
            .foregroundStyle(.white)
            .font(.system(.caption, design: .monospaced))
    }
}
