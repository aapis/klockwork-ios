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
            if self.fullWidth && self.alignment == .trailing {
                Spacer()
            }
            Text(self.text)
            if self.fullWidth && self.alignment == .leading {
                Spacer()
            }
        }
        .padding(2)
        .background(self.clear ? .clear : .black.opacity(0.6))
        .foregroundStyle(.white)
        .font(.system(.caption, design: .monospaced))
    }
}
