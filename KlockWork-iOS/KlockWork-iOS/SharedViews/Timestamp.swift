//
//  Timestamp.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-02.
//

import SwiftUI

struct Timestamp: View {
    public let text: String
    public var fullWidth: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.text)
            if fullWidth {
                Spacer()
            }
        }
        .padding(2)
        .background(.black.opacity(0.6))
        .foregroundStyle(.white)
        .font(.system(.caption, design: .monospaced))
    }
}
