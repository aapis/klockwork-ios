//
//  Planning.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    @Binding public var date: Date
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

//                QueryField(prompt: "What can I help you find?", onSubmit: self.actionOnSubmit, text: $text)
                Spacer().frame(height: 1)
            }
            .background(Theme.cOrange)
        }
    }
}

extension Planning {
    struct Header: View {
        var body: some View {
            Text("Planning")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
        }
    }

    struct Content: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("Coming soon!")
                    .padding()
                    .onAppear(perform: actionOnAppear)
                Spacer()
            }
        }
    }
}

extension Planning.Content {
    private func actionOnAppear() -> Void {
        let parser = SearchLanguage.Parser(with: text).parse()

        if !parser.components.isEmpty {
            let results = SearchLanguage.Results(components: parser.components, moc: moc).find()
            print("DERPO results=\(results)")
        }
    }
}

extension Planning {
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
        }
    }
}
