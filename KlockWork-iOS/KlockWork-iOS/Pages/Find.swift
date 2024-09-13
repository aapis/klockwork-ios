//
//  Find.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct Find: View {
    @EnvironmentObject private var state: AppState
    @State private var text: String = ""
    @State private var results: SearchLibrary.SearchResults?
    @State private var recentSearchTerms: [String] = [] // @TODO: store recent searches and track as another app use metric
    private let page: PageConfiguration.AppPage = .find

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(text: $text, recentSearchTerms: $recentSearchTerms, onSubmit: self.actionOnSubmit)
                Divider().background(.white).frame(height: 1)

                ZStack(alignment: .bottomLeading) {
                    if !text.isEmpty {
                        Rows(
                            text: $text,
                            results: $results,
                            onSubmit: self.actionOnSubmit
                        )
                    } else {
                        VStack {
                            List {
                                Section("Recent Searches") {
                                    if !recentSearchTerms.isEmpty {
                                        ForEach(recentSearchTerms, id: \.self ) { term in
                                            Button {
                                                text = term
                                            } label: {
                                                HStack(alignment: .center, spacing: 0) {
                                                    Text(term)
                                                    Spacer()
                                                    Image(systemName: "chevron.right")
                                                }
                                            }
                                        }
                                        .listRowBackground(Theme.textBackground)

                                        Button {
                                            recentSearchTerms = []
                                            text = ""
                                        } label: {
                                            HStack {
                                                Text("Clear list")
                                                Spacer()
                                                Image(systemName: "xmark")
                                            }
                                        }
                                        .listRowBackground(Color.red)
                                        .foregroundStyle(.white)
                                    } else {
                                        Text("None found")
                                            .listRowBackground(Theme.textBackground)
                                            .foregroundStyle(.gray)
                                    }
                                }
                            }
                            .background(page.primaryColour)
                            .scrollContentBackground(.hidden)
                            Spacer()
                        }
                    }
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                QueryField(
                    prompt: "Search for keywords or phrases",
                    onSubmit: self.actionOnSubmit,
                    action: .search,
                    text: $text
                )
                Spacer().frame(height: 1)
            }
            .background(page.primaryColour)
            .onChange(of: text) {
                if text.isEmpty {
                    results?.reset()
                }
            }
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

extension Find {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = Date()
        @Binding public var text: String
        @Binding public var recentSearchTerms: [String]
        @State private var isPresented: Bool = false
        public var onSubmit: () -> Void

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.1)
                        .blendMode(.softLight)
                        .frame(height: 45)

                    HStack(spacing: 8) {
                        PageTitle(text: text.isEmpty ? "Find" : text.count < 10 ? "Find: \(text.prefix(10))" : "Find: \(text.prefix(10))...")
                        DateStrip(date: self.date)
                        Spacer()
                        CreateEntitiesButton()
                    }
                }
            }
            .onAppear(perform: {
                date = self.state.date
            })
            .onChange(of: date) {
                self.state.date = date
            }
        }
    }

    struct Rows: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String
        @Binding public var results: SearchLibrary.SearchResults?
        public var onSubmit: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if results != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 1) {
                            if !text.isEmpty {
                                if let searchResults = results {
                                    ForEach(searchResults.children) { row in row.view}
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
        }
    }
}

extension Find {
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
            Task {
                self.results = await SearchLibrary(term: text).query()

                if self.recentSearchTerms.count > 10 {
                    let _ = self.recentSearchTerms.popLast()
                }

                if !self.recentSearchTerms.contains(where: {$0 == text}) {
                    self.recentSearchTerms.append(text)
                }
            }
        }
    }
}
