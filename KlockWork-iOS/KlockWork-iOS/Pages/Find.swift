//
//  Find.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct Find: View {
    @Environment(\.managedObjectContext) var moc
    @State private var text: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header()
                ZStack(alignment: .bottomLeading) {
//                        Tabs(job: $job, selected: $selected, date: $date)
                    Content(text: $text)
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                Editor(text: $text)
                Spacer().frame(height: 1)
            }
            .background(Theme.cPurple)
        }
    }
}

extension Find {
    struct Header: View {
        var body: some View {
            Text("Header")
        }
    }

    struct Content: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String

        var body: some View {
            Text("Content")
                .onAppear(perform: actionOnAppear)
        }
    }

    struct Editor: View {
        enum Field {
            // Apparently you need to use an existing UITextContentType
            case organizationName
        }

        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String
        @FocusState public var focused: Field?

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text("What can I help you find?").foregroundStyle(.gray),
                        axis: .horizontal
                    )
                    .disableAutocorrection(false)
                    .focused($focused, equals: .organizationName)
                    .textContentType(.organizationName)
                    .submitLabel(.return)
                    .textSelection(.enabled)
                    .padding()
                    
                    Spacer()
                    
                    Button {
                        if !text.isEmpty {
                            self.actionOnSubmit()
                        }
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundStyle(text.isEmpty ? .gray : .yellow)
                    }
                    .padding(.trailing)
                }
                .border(width: 1, edges: [.top], color: text.isEmpty ? .gray : .yellow)
            }
            .onSubmit(self.actionOnSubmit)
        }
    }
}

extension Find.Content {
    private func actionOnAppear() -> Void {
        let parser = SearchLanguage.Parser(with: text).parse()

        if !parser.components.isEmpty {
            let results = SearchLanguage.Results(components: parser.components, moc: moc).find()
            print("DERPO results=\(results)")
        }
    }
}

extension Find.Editor {
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
        }
    }
}
