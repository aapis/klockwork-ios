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

                QueryField(prompt: "What can I help you find?", onSubmit: self.actionOnSubmit, text: $text)
                Spacer().frame(height: 1)
            }
            .background(Theme.cYellow)
        }
    }
}

extension Find {
    struct Header: View {
        var body: some View {
            Text("Find")
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
                Text("Content")
                    .onAppear(perform: actionOnAppear)
                Spacer()
            }
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

extension Find {
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
        }
    }
}
