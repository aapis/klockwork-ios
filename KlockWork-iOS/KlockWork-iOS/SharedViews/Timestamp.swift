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
    public var alignment: Edge = .leading
    public var clear: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            if self.alignment == .trailing {
                Spacer()
            }
            Text(self.text)
                .padding(2)
                .background(self.clear ? .clear : .black.opacity(0.6))
                .clipShape(.rect(cornerRadius: 2))
            if self.alignment == .leading {
                Spacer()
            }
        }
        .foregroundStyle(.white)
        .font(.system(.caption, design: .monospaced))
    }
}
