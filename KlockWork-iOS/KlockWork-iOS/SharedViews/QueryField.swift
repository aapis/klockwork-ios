//
//  QueryField.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct QueryField: View {
    enum Field {
        // Apparently you need to use an existing UITextContentType
        case organizationName
    }

    public enum Action {
        case submit, search
    }

    public let prompt: String
    public var onSubmit: () -> Void
    public var action: Action = .submit
    @EnvironmentObject private var state: AppState
    @Binding public var text: String
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(prompt).foregroundStyle(.gray),
                    axis: self.action == .search ? .horizontal : .vertical
                )
                .disableAutocorrection(false)
                .focused($focused, equals: .organizationName)
                .textContentType(.organizationName)
                .submitLabel(action == .search ? .search : .return)
                .textSelection(.enabled)
                .padding()
                .foregroundStyle(self.state.theme.tint)

                Spacer()

                Button {
                    if action == .search {
                        text = ""
                        self.onSubmit()
                    } else {
                        if !text.isEmpty {
                            self.onSubmit()
                        }
                    }
                } label: {
                    HStack(alignment: .center, spacing: 0) {
                        if !text.isEmpty {
                            if action == .search {
                                Image(systemName: "xmark.circle.fill")
                                    .fontWeight(.bold)
                                    .font(.title)
                                    .foregroundStyle(self.state.theme.tint)
                            } else {
                                Image(systemName: "chevron.up.circle.fill")
                                    .fontWeight(.bold)
                                    .font(.title)
                                    .foregroundStyle(text.isEmpty ? .gray : self.state.theme.tint)
                            }
                        }
                    }
                }
                .padding(.trailing)
            }
            .border(width: 1, edges: [.top], color: text.isEmpty ? .gray : self.state.theme.tint)
        }
        .onSubmit(self.onSubmit)
    }
}
