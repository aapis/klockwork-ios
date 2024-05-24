//
//  StatusMessage.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct StatusMessage {
    struct Warning: View {
        public let message: String

        var body: some View {
            HStack {
                Text(message)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(8)
            .background(.yellow)
            .foregroundStyle(.black.opacity(0.6))
        }
    }
}
