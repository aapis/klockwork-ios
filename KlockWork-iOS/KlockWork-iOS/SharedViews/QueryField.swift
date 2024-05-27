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
    @Environment(\.managedObjectContext) var moc
    @Binding public var text: String
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                TextField(
                    "",
                    text: $text,
                    prompt: Text(prompt).foregroundStyle(.gray),
                    axis: .horizontal
                )
                .disableAutocorrection(false)
                .focused($focused, equals: .organizationName)
                .textContentType(.organizationName)
                .submitLabel(action == .search ? .search : .return)
                .textSelection(.enabled)
                .padding()
                .foregroundStyle(.yellow)

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
                    if action == .search {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(text.isEmpty ? .gray : .yellow)
                    } else {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(text.isEmpty ? .gray : .yellow)
                    }
                }
                .padding(.trailing)
            }
            .border(width: 1, edges: [.top], color: text.isEmpty ? .gray : .yellow)
        }
        .onSubmit(self.onSubmit)
    }
}
