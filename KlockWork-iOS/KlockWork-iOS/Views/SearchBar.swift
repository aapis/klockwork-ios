//
//  SearchBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-24.
//

import SwiftUI
import CoreData

struct SearchBar: View {
    enum Field {
        // Apparently you need to use an existing UITextContentType
        case organizationName
    }

    public let items: [NSManagedObject]
    public let type: EntityType

    @State private var text: String = ""
    @State private var sheetPresented: Bool = false
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Bar(text: $text, sheetPresented: $sheetPresented, focused: _focused)
            }
        }
        .sheet(isPresented: $sheetPresented, onDismiss: actionOnDismiss, content: {Sheet(text: $text, items: items, type: type)})
    }
}

extension SearchBar {
    private func actionOnDismiss() -> Void {
        focused = nil
        text = ""
    }
}

extension SearchBar {
    struct Bar: View {
        @Binding public var text: String
        @Binding public var sheetPresented: Bool
        @FocusState public var focused: Field?

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text("ACME, Contoso, Initech...")
                    )
                    .focused($focused, equals: SearchBar.Field.organizationName)
                    .textContentType(.organizationName)
                    .submitLabel(.search)
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .onSubmit(actionOnSubmit)

                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.yellow)
                }
            }
            .listRowBackground(Theme.textBackground)
        }
    }

    struct Sheet: View {
        @Binding public var text: String
        public var items: [NSManagedObject]
        public var type: EntityType
        @State public var sheetPresented: Bool = true

        var body: some View {
            VStack {
                List {
                    Section("Searching: \(type.label)") {
                        Bar(text: $text, sheetPresented: $sheetPresented)
                    }

                    Section("Results") {
                        Text("Search results not implemented")
                            .listRowBackground(Theme.textBackground)
                    }
                }
            }
            .background(Theme.cGreen)
            .scrollContentBackground(.hidden)
        }
    }
}

extension SearchBar.Bar {
    private func actionOnSubmit() -> Void {
        sheetPresented = (focused == .organizationName)
    }
}
