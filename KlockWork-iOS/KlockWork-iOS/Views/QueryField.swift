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

    public let prompt: String
    public var onSubmit: () -> Void
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
                .submitLabel(.return)
                .textSelection(.enabled)
                .padding()
                .foregroundStyle(.yellow)

                Spacer()

                Button {
                    if !text.isEmpty {
                        self.onSubmit()
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .foregroundStyle(text.isEmpty ? .gray : .yellow)
                }
                .padding(.trailing)
            }
            .border(width: 1, edges: [.top], color: text.isEmpty ? .gray : .yellow)
        }
        .onSubmit(self.onSubmit)
    }
}
