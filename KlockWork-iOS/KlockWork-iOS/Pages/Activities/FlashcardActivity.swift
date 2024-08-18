//
//  FlashcardActivity.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-18.
//

import SwiftUI

struct FlashcardActivity: View {
    private var page: PageConfiguration.AppPage = .intersitial
    @State private var isJobSelectorPresented: Bool = true
    @State private var job: Job?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.job == nil {
                Widget.JobSelector.Single(
                    showing: $isJobSelectorPresented,
                    job: $job
                )
            } else {
//                FlashcardList(job: self.job!)
                FlashcardDeck(job: self.job!)
            }
        }
        .foregroundStyle(Theme.base)
        .background(.gray)
        .navigationTitle(job != nil ? self.job!.title ?? self.job!.jid.string: "Flashcard")
        .toolbarBackground(job != nil ? self.job!.backgroundColor : Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    struct FlashcardDeck: View {
        public var job: Job
        @FetchRequest private var terms: FetchedResults<TaxonomyTerm>
        @State private var current: TaxonomyTerm? = nil
        @State private var isAnswerCardShowing: Bool = false
        @State private var clue: String = ""

        var body: some View {
            VStack(alignment: .center, spacing: 0) {
//                JobIndicator(job: self.job)
                ZStack(alignment: .center) {
                    LinearGradient(colors: [.black.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                    HStack(alignment: .center) {
                        if self.current != nil {
                            Button {
                                self.isAnswerCardShowing.toggle()
                            } label: {
                                Text(self.clue)
                                    .multilineTextAlignment(.center)
                                    .padding(50)
                            }


                        }
                    }
                    .frame(maxWidth: 300, maxHeight: 200)
                    .background(.white.opacity(0.8))
                    .cornerRadius(5)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 3, y: 3)
                }
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    if self.isAnswerCardShowing && self.current != nil {
                        ForEach(self.current!.definitions!.allObjects as! [TaxonomyTermDefinitions], id: \.objectID) { term in
                            Text("1. \(term.definition ?? "Definition not found")")
                        }
                    } else {
                        Text("Tap card to reveal")
                    }
                }

                Divider()
                HStack(alignment: .center) {
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
                            Image(systemName: "sparkle")
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
                        let next = self.terms.randomElement()
                        if next != current {
                            current = next
                            clue = current!.name ?? "_TERM_NAME"
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

                Spacer()
            }
            .onAppear(perform: self.actionOnAppear)
        }

        init(job: Job) {
            self.job = job
            _terms = CoreDataTaxonomyTerms.fetch(job: self.job)
        }
    }

    struct FlashcardList: View {
        public var job: Job
        @FetchRequest private var terms: FetchedResults<TaxonomyTerm>

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(self.terms) { term in
                    VStack {
                        Text(term.name ?? "_NAME")
                    }
                }
            }
        }

        init(job: Job) {
            self.job = job
            _terms = CoreDataTaxonomyTerms.fetch(job: self.job)
        }
    }

    struct Flashcard {
        var term: TaxonomyTerm
    }

    struct JobIndicator: View {
        public var job: Job

        var body: some View {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "chevron.right")
                Text(self.job.title ?? self.job.jid.string)
                Spacer()
            }
            .padding()
            .background(self.job.backgroundColor)
            .foregroundStyle(self.job.backgroundColor.isBright() ? .black : .white)
        }
    }
}

extension FlashcardActivity.FlashcardDeck {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.current = self.terms.randomElement()
        self.clue = self.current!.name ?? "_TERM_NAME"
    }
}
