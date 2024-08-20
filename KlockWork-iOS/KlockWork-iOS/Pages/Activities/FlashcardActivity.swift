//
//  FlashcardActivity.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-18.
//

import SwiftUI

struct FlashcardActivity: View {
    private var page: PageConfiguration.AppPage = .explore
    @State private var isJobSelectorPresented: Bool = true
    @State private var job: Job?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlashcardDeck(job: $job)

            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center) {
                    PageActionBar.Today(title: "Flashcard topic:", job: $job, isPresented: $isJobSelectorPresented)
                }
            }
        }
        .background(self.page.primaryColour)
        .navigationTitle(job != nil ? self.job!.title ?? self.job!.jid.string: "Choose a topic")
        .toolbarBackground(job != nil ? self.job!.backgroundColor : Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    struct FlashcardDeck: View {
        @EnvironmentObject private var state: AppState
        @Binding public var job: Job?
        @State private var terms: Array<TaxonomyTerm> = []
        @State private var current: TaxonomyTerm? = nil
        @State private var isAnswerCardShowing: Bool = false
        @State private var clue: String = ""
        @State private var viewed: Set<TaxonomyTerm> = []
        @State private var definitions: [TaxonomyTermDefinitions] = []

        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                Card(
                    isAnswerCardShowing: $isAnswerCardShowing,
                    definitions: $definitions,
                    current: $current
                )
                Divider()
                Actions(
                    isAnswerCardShowing: $isAnswerCardShowing,
                    definitions: $definitions,
                    current: $current,
                    terms: $terms,
                    viewed: $viewed
                )
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: job) {
                self.actionOnAppear()
            }
        }

        struct Actions: View {
            @Binding public var isAnswerCardShowing: Bool
            @Binding public var definitions: [TaxonomyTermDefinitions]
            @Binding public var current: TaxonomyTerm?
            @Binding public var terms: [TaxonomyTerm]
            @Binding public var viewed: Set<TaxonomyTerm>

            var body: some View {
                HStack(alignment: .center) {
                    Button {
                        self.isAnswerCardShowing.toggle()
                    } label: {
                        ZStack(alignment: .center) {
                            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                            Image(systemName: "rectangle.landscape.rotate")
                        }
                    }
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))

                    Button {
                        self.isAnswerCardShowing = false
                    } label: {
                        ZStack(alignment: .center) {
                            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                            Image(systemName: "hand.thumbsup.fill")
                        }
                    }
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))

                    Button {
                        self.isAnswerCardShowing = false
                    } label: {
                        ZStack(alignment: .center) {
                            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                            Image(systemName: "hand.thumbsdown.fill")
                        }
                    }
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))

                    Button {
                        self.isAnswerCardShowing = false

                        // @TODO: delete the randomly selected item from self.terms
                        if let next = self.terms.randomElement() {
                            if next != current {
                                // Pick another random element if we've seen the next item already
                                if !self.viewed.contains(next) {
                                    current = next
                                } else {
                                    current = self.terms.randomElement()
                                }
                            }
                        }

                        if self.current != nil {
                            viewed.insert(self.current!)
                        }
                    } label: {
                        ZStack(alignment: .center) {
                            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))
                }
                .frame(height: 100)
            }
        }

        struct Card: View {
            @Binding public var isAnswerCardShowing: Bool
            @Binding public var definitions: [TaxonomyTermDefinitions]
            @Binding public var current: TaxonomyTerm?
            @State private var clue: String = ""
            @State private var initialDefinitionIndex: Int = 1

            var body: some View {
                ZStack(alignment: .center) {
                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                    VStack(alignment: .center, spacing: 0) {
                        VStack(alignment: .center, spacing: 0) {
                            ZStack {
                                // Line grid
                                VStack(spacing: 13) {
                                    Divider().background(.red)
                                    ForEach(1...10, id: \.self) { _ in
                                        Divider().background(.blue)
                                    }
                                }

                                if self.isAnswerCardShowing {
                                    VStack(alignment: .leading) {
                                        // Definitions
                                        ScrollView(showsIndicators: false) {
                                            ForEach(Array(definitions.enumerated()), id: \.element) { idx, term in
                                                HStack(alignment: .center) {
                                                    Text("\(idx). \(term.definition ?? "Definition not found")")
                                                        .foregroundStyle(Theme.base)
                                                    Spacer()
                                                }
                                                .padding([.leading, .trailing], 10)
                                            }
                                        }
                                    }
                                    .padding(.top, 30)
                                } else {
                                    // Answer
                                    HStack(alignment: .center) {
                                        if self.current != nil {
                                            Text(clue)
                                                .font(.title2)
                                                .bold()
                                                .foregroundStyle(Theme.base)
                                                .multilineTextAlignment(.center)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                        .background(.white.opacity(0.95))
                        .cornerRadius(3)
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 3, y: 3)
                    }
                    .padding()
                }
                .onChange(of: current) {
                    clue = current?.name ?? "Clue"

                    if let defs = self.current!.definitions {
                        if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                            definitions = ttds
                        }
                    }
                }
            }
        }
    }

    struct Flashcard {
        var term: TaxonomyTerm
    }
}

extension FlashcardActivity.FlashcardDeck {
    /// Onload/onChangeJob handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.job != nil {
            if let termsForJob = CoreDataTaxonomyTerms(moc: self.state.moc).byJob(self.job!) {
                terms = termsForJob
            }
        }

        if !self.terms.isEmpty {
            self.current = self.terms.randomElement()
            self.clue = self.current?.name ?? "_TERM_NAME"
            self.viewed.insert(self.current!)
            self.definitions = []

            if let defs = self.current!.definitions {
                if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                    self.definitions = ttds
                }
            }
        }
    }
}
