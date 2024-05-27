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
    @State private var results: SearchLibrary.SearchResults?
    @State private var recentSearchTerms: [String] = []

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(text: $text, recentSearchTerms: $recentSearchTerms, onSubmit: self.actionOnSubmit)
                ZStack(alignment: .bottomLeading) {
                    Rows(
                        text: $text,
                        results: $results,
                        onSubmit: self.actionOnSubmit
                    )
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                QueryField(
                    prompt: "What can I help you find?",
                    onSubmit: self.actionOnSubmit,
                    action: .search,
                    text: $text
                )
                Spacer().frame(height: 1)
            }
            .background(Theme.cYellow)
            .onChange(of: text) {
                if text.isEmpty {
                    results?.reset()
                }
            }
        }
    }
}

extension Find {
    struct Header: View {
        @Binding public var text: String
        @Binding public var recentSearchTerms: [String]
        @State private var isPresented: Bool = false
        public var onSubmit: () -> Void

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                if text.isEmpty {
                    Text("Find")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                } else {
                    if text.count < 10 {
                        Text("Find: \(text.prefix(10))")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    } else {
                        Text("Find: \(text.prefix(10))...")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                }

                Spacer()

                if !recentSearchTerms.isEmpty {
                    Button {
                        recentSearchTerms = []
                        text = ""
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .padding(10)
                    .background(Theme.rowColour)
                    .mask(Circle())
                }

                Button {
                    isPresented.toggle()
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                }
                .padding(10)
                .background(Theme.rowColour)
                .mask(Circle())
                .sheet(isPresented: $isPresented) {
                    Find.FilterPanel(text: $text, recentSearchTerms: $recentSearchTerms, isPresented: $isPresented, onSubmit: self.onSubmit)
                }
            }
            .padding()
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
                                    ForEach(searchResults.children) { row in
                                        row.view
                                    }
                                }
                            }
                        }
                    }
                }

                Spacer()
            }
        }
    }

    struct FilterPanel: View {
        @Binding public var text: String
        @Binding public var recentSearchTerms: [String]
        @Binding public var isPresented: Bool
        public var onSubmit: () -> Void

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Filters")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    if !recentSearchTerms.isEmpty {
                        Button {
                            recentSearchTerms = []
                            text = ""
                        } label: {
                            Text("Clear recent searches")
                        }
                        .padding(10)
                        .background(Theme.rowColour)
                    }
                }
                .padding()

                List {
                    Section("Recent searches") {
                        if !recentSearchTerms.isEmpty {
                            ForEach(recentSearchTerms, id: \.self ) { term in
                                Button {
                                    text = term
                                    isPresented.toggle()
                                    self.onSubmit()
                                } label: {
                                    HStack(alignment: .center, spacing: 0) {
                                        Text(term)
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                    }
                                }
                            }
                            .listRowBackground(Theme.textBackground)
                        } else {
                            Text("None found")
                                .listRowBackground(Theme.textBackground)
                                .foregroundStyle(.gray)
                        }
                    }
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
            }
            .background(Theme.cYellow)
        }
    }
}

extension Find.Rows {
    private func actionOnAppear() -> Void {

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
