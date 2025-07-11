//
//  Find.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct Find: View {
    @EnvironmentObject private var state: AppState
    @State public var text: String = ""
    @State private var results: SearchLibrary.SearchResults?
    @State private var recentSearchTerms: [String] = [] // @TODO: store recent searches and track as another app use metric
    @FetchRequest private var savedSearchTerms: FetchedResults<SavedSearch>
    private let page: PageConfiguration.AppPage = .find

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(text: $text, recentSearchTerms: $recentSearchTerms, onSubmit: self.actionOnSubmit, page: self.page)
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
                                        ForEach(recentSearchTerms, id: \.self) { term in
                                            Button {
                                                self.text = term
                                                self.actionOnSubmit()
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
                                                Image(systemName: "arrow.clockwise.square.fill")
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

                                Section("Saved Searches") {
                                    ForEach(self.savedSearchTerms, id: \.self) { saved in
                                        Button {
                                            self.text = saved.term ?? "Not found"
                                            self.actionOnSubmit()
                                        } label: {
                                            HStack(alignment: .center, spacing: 0) {
                                                Text(saved.term ?? "Not found")
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                    .listRowBackground(Theme.textBackground)
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
            .onAppear(perform: {
                // Auto-submit if we passed in a $text value to show results right away
                if !self.text.isEmpty {
                    self.actionOnSubmit()
                }
            })
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
        @State public var date: Date = DateHelper.startOfDay()
        @Binding public var text: String
        @Binding public var recentSearchTerms: [String]
        @State private var isPresented: Bool = false
        public var onSubmit: () -> Void
        public var page: PageConfiguration.AppPage

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.1)
                        .blendMode(.softLight)
                        .frame(height: 45)

                    HStack(spacing: 8) {
                        PageTitle(text: text.isEmpty ? "Find" : text.count < 10 ? "Find: \(text.prefix(10))" : "Find: \(text.prefix(10))...")
                        Spacer()
                        if !self.text.isEmpty {
                            SaveTermButton(text: $text)
                        }
                        CreateEntitiesButton(page: self.page)
                    }
                }
            }
            .onAppear(perform: {
                date = self.state.date
            })
            .onChange(of: date) {
                self.state.date = DateHelper.startOfDay(self.date)
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

    struct SaveTermButton: View {
        @EnvironmentObject private var state: AppState
        @Binding public var text: String
        @FetchRequest private var matchingSavedTerms: FetchedResults<SavedSearch>

        var body: some View {
            Button {
                if self.matchingSavedTerms.count > 0 {
                    CDSavedSearch(moc: self.state.moc).destroy(self.text)
                } else {
                    CDSavedSearch(moc: self.state.moc).create(term: self.text, created: Date())
                }
            } label: {
                Image(systemName: self.matchingSavedTerms.count > 0 ? "cloud.fill" : "cloud")
            }
            .font(.title3)
            .buttonStyle(.plain)
        }
    }
}

extension Find.SaveTermButton {
    init(text: Binding<String>) {
        _text = text
        _matchingSavedTerms = CDSavedSearch.fetchMatching(term: _text.wrappedValue)
    }
}

extension Find {
    /// Init
    init(text: String? = nil) {
        if text == nil {
            self.text = ""
        } else {
            self.text = text!
        }

        // 1 year in the past
        let interval: TimeInterval = (86400*365) * -1

        _savedSearchTerms = CDSavedSearch.createdBetween(
            DateHelper.startOfMonth(for: Date().addingTimeInterval(interval)),
            DateHelper.endOfMonth(for: Date())
        )
    }
    
    /// Fires on submit
    /// - Returns: Void
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
