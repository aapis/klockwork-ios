//
//  FlashcardActivity.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-18.
//

import SwiftUI

struct FlashcardActivity: View {
    @EnvironmentObject private var state: AppState
    private var page: PageConfiguration.AppPage = .explore
    @State private var isJobSelectorPresented: Bool = false
    @State private var job: Job?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            FlashcardDeck()
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center) {
                    PageActionBar.Today(
                        title: "Flashcard topic",
                        prompt: "Choose a topic",
                        job: $job,
                        isPresented: $isJobSelectorPresented,
                        page: self.page
                    )
                }
            }
        }
        .onAppear(perform: {
            if self.state.job != nil {
                self.isJobSelectorPresented = false
            } else {
                self.isJobSelectorPresented = true
            }
        })
        .background(self.page.primaryColour)
        .navigationTitle(self.state.job != nil ? self.state.job!.title ?? self.state.job!.jid.string: "Activity: Flashcard")
#if os(iOS)
        .toolbarBackground(self.state.job != nil ? self.state.job!.backgroundColor : Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
#endif
    }

    struct FlashcardDeck: View {
        @EnvironmentObject private var state: AppState
        @State private var terms: Array<TaxonomyTerm> = []
        @State private var current: TaxonomyTerm? = nil
        @State private var isAnswerCardShowing: Bool = false
        @State private var clue: String = ""
        @State private var viewed: Set<TaxonomyTerm> = []
        @State private var definitions: [TaxonomyTermDefinitions] = []
        @State private var isMenuShowing: Bool = false

        var body: some View {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Button {
                        self.isMenuShowing.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title)
                            .padding()
                    }
//                    .useDefaultHover({ _ in})
                    .buttonStyle(.plain)

                    if self.state.job != nil {
                        if let project = self.state.job?.project {
                            if let company = project.company {
                                Text("\(company.name ?? "Company")")
                                Image(systemName: "chevron.right")
                            }
                            Text("\(project.name ?? "Project")")
                            Image(systemName: "chevron.right")
                        }
                        Text("\(self.state.job!.title ?? "Job")")

                        // @TODO: maybe add this back? when final styling is in place?
//                                    if self.current != nil {
//                                        Image(systemName: "chevron.right")
//                                        Text("\(self.current!.name ?? "Current")")
//                                    }
                    } else {
                        Text("None selected")
                    }

                    Spacer()
                }
                .background(self.state.job?.backgroundColor ?? .clear)
                .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : .white)

                if self.isMenuShowing {
                    Menu(
                        isMenuShowing: $isMenuShowing,
                        isAnswerCardShowing: $isAnswerCardShowing,
                        terms: $terms,
                        current: $current
                    )
                } else {
                    Card(
                        isAnswerCardShowing: $isAnswerCardShowing,
                        definitions: $definitions,
                        current: $current,
                        clue: $clue
                    )
                    Actions(
                        isAnswerCardShowing: $isAnswerCardShowing,
                        definitions: $definitions,
                        current: $current,
                        terms: $terms,
                        viewed: $viewed
                    )
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.job) {
                self.actionOnAppear()
            }
            .onChange(of: self.current) {
                if let curr = self.current {
                    self.clue = curr.name ?? "_TERM_NAME"
                    self.viewed.insert(curr)

                    if let defs = self.current!.definitions {
                        if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                            self.definitions = ttds
                        }
                    }
                }
            }
        }

        struct Menu: View {
            @EnvironmentObject private var state: AppState
            @Binding public var isMenuShowing: Bool
            @Binding public var isAnswerCardShowing: Bool
            @Binding public var terms: [TaxonomyTerm]
            @Binding public var current: TaxonomyTerm?

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("\(self.terms.count) terms")
                                .textCase(.uppercase)
                                .font(.caption)
                                .padding(5)
                            Spacer()
                        }
                        .background(self.state.job?.backgroundColor ?? Theme.rowColour)

                        ForEach(self.terms) { term in
                            Button {
                                self.current = term
                                self.isMenuShowing = false
                                self.isAnswerCardShowing = true
                            } label: {
                                ZStack(alignment: .topLeading) {
                                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                        .frame(height: 50)
                                        .opacity(0.1)

                                    HStack {
                                        if self.current == term {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                        Text(term.name ?? "Term")
                                        Spacer()
                                    }
                                    .padding()
                                }
                                .background(self.state.job?.backgroundColor)
                                .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : .white)
//                                .useDefaultHover({ _ in})
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }
            }
        }

        struct Actions: View {
            @EnvironmentObject private var state: AppState
            @Binding public var isAnswerCardShowing: Bool
            @Binding public var definitions: [TaxonomyTermDefinitions]
            @Binding public var current: TaxonomyTerm?
            @Binding public var terms: [TaxonomyTerm]
            @Binding public var viewed: Set<TaxonomyTerm>

            var body: some View {
                ZStack(alignment: .topLeading) {
                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                        .opacity(0.06)

                    Buttons
                }
            }

            var Buttons: some View {
                HStack(alignment: .center) {
                    Button {
                        self.isAnswerCardShowing.toggle()
                    } label: {
                        ZStack(alignment: .center) {
                            LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                            Image(systemName: "rectangle.landscape.rotate")
                        }
                    }
                    .buttonStyle(.plain)
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
                    .buttonStyle(.plain)
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
                    .buttonStyle(.plain)
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))

                    Button {
                        self.isAnswerCardShowing = false

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
                    .buttonStyle(.plain)
                    .padding()
                    .mask(Circle().frame(width: 50, height: 50))
                }
                .frame(height: 90)
                .border(width: 1, edges: [.top], color: self.state.theme.tint)
            }
        }

        struct Card: View {
            @EnvironmentObject private var state: AppState
            @Binding public var isAnswerCardShowing: Bool
            @Binding public var definitions: [TaxonomyTermDefinitions] // @TODO: convert this to dict grouped by job
            @Binding public var current: TaxonomyTerm?
            @Binding public var clue: String

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    if self.isAnswerCardShowing {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text(self.clue)
                                    .font(.title2)
                                    .bold()
                                    .padding()
                                    .foregroundStyle((self.state.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)
                                    .help("\(self.definitions.count) definitions for \(self.clue)")
                                Spacer()
                            }
                            .background(self.state.job?.backgroundColor)

                            ScrollView {
                                ZStack(alignment: .topLeading) {
                                    VStack(alignment: .leading) {
                                        ForEach(Array(definitions.enumerated()), id: \.element) { idx, term in
                                            CardDefinition(term: term)
                                        }
                                    }
                                    .padding()

                                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                        .frame(height: 50)
                                        .opacity(0.1)
                                }
                            }
                        }
                        .background(Theme.lightWhite)
                    } else {
                        // Answer
                        if self.current != nil {
                            VStack(alignment: .leading, spacing: 0) {
                                Spacer()
                                VStack(alignment: .center) {
                                    Text("Clue")
                                        .foregroundStyle((self.state.job?.backgroundColor ?? Theme.rowColour).isBright() ? .white.opacity(0.75) : .gray)
                                    Text(clue)
                                        .font(.title2)
                                        .bold()
                                        .multilineTextAlignment(.center)
                                }
                                Spacer()
                            }
                        }
                    }
                    Spacer()
                }
                .onChange(of: current) {
                    if self.current != nil {
                        self.clue = current?.name ?? "Clue"

                        if let defs = self.current!.definitions {
                            if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                                self.definitions = ttds
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: FlashcardActivity.Flashcard
    struct Flashcard {
        var term: TaxonomyTerm
    }

    // MARK: FlashcardActivity.CardDefinition
    struct CardDefinition: View {
        public let term: TaxonomyTermDefinitions
        @State private var isHighlighted: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                NavigationLink {
                    DefinitionDetail(definition: self.term)
                } label: {
                    HStack(alignment: .top) {
                        Image(systemName: self.isHighlighted ? "pencil.circle.fill" : "circle")
                        Text(self.term.definition ?? "Definition not found")
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(3)
//                    .useDefaultHover({ hover in self.isHighlighted = hover })
                    .help("Edit definition")
                }
                .buttonStyle(.plain)
            }
            .background(self.term.job?.backgroundColor.opacity(self.isHighlighted ? 1 : 0.6))
            .foregroundStyle((self.term.job?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
        }
    }
}

extension FlashcardActivity.FlashcardDeck {
    /// Onload/onChangeJob handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.isAnswerCardShowing = false
        self.terms = []
        self.definitions = []
        self.current = nil
        self.clue = ""

        if let job = self.state.job {
            if let termsForJob = CoreDataTaxonomyTerms(moc: self.state.moc).byJob(job) {
                self.terms = termsForJob.sorted(by: {$0.name ?? "" < $1.name ?? ""})
            }
        }

        if !self.terms.isEmpty {
            self.current = self.terms.randomElement()
            self.clue = self.current?.name ?? "_TERM_NAME"
            self.viewed.insert(self.current!)

            if let defs = self.current!.definitions {
                if let ttds = defs.allObjects as? [TaxonomyTermDefinitions] {
                    self.definitions = ttds.sorted(by: {$0.definition ?? "" < $1.definition ?? ""})
                }
            }
        }
    }
}
