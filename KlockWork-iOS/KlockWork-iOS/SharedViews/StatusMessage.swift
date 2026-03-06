//
//  StatusMessage.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct StatusMessage {
    struct Warning: View {
        @EnvironmentObject private var state: AppState
        public let message: String

        var body: some View {
            HStack {
                Text(message)
                    .fontWeight(.bold)
                Spacer()
            }
            .foregroundStyle(.gray)
            .listRowBackground(Theme.textBackground)
        }
    }
}
