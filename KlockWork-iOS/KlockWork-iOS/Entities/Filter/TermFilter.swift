//
//  TermFilter.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-16.
//

import SwiftUI

struct TermsGroupedByDate: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var definitions: [TaxonomyTermDefinitions]
}

struct GroupedTermDateRow: View {
    public let date: Date

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "calendar")
            Text(date.formatted(date: .abbreviated, time: .omitted))
            Spacer()
        }
        .padding(8)
    }
}

struct TermFilter: View {
    typealias Button = Tabs.Content.Individual.SingleTerm
    public let job: Job
    public var page: PageConfiguration.AppPage = .create
    @FetchRequest private var definitions: FetchedResults<TaxonomyTermDefinitions>
    @State private var grouped: [TermsGroupedByDate] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                ForEach(grouped.sorted(by: {$0.date > $1.date})) { group in
                    VStack(alignment: .leading, spacing: 1) {
                        GroupedTermDateRow(date: group.date)

                        ForEach(group.definitions) { definition in
                            if definition.term != nil {
                                Button(term: definition.term!)
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle("Taxonomy Terms")
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
    }

    init(job: Job) {
        self.job = job
        _definitions = CoreDataTaxonomyTerms.fetchDefinitions(job: job)
    }
}

struct TermFilterBound: View {
    typealias Button = Tabs.Content.Individual.SingleTerm
    @Binding public var job: Job
    public var page: PageConfiguration.AppPage = .create
    @FetchRequest private var definitions: FetchedResults<TaxonomyTermDefinitions>
    @State private var grouped: [TermsGroupedByDate] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                ForEach(grouped.sorted(by: {$0.date > $1.date})) { group in
                    VStack(alignment: .leading, spacing: 1) {
                        GroupedTermDateRow(date: group.date)

                        ForEach(group.definitions) { definition in
                            if definition.term != nil {
                                Button(term: definition.term!)
                            }
                        }
                    }
                }
            }
        }
        .onChange(of: job) { self.actionOnAppear() }
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle("Taxonomy Terms")
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
    }

    init(job: Binding<Job>) {
        _job = job
        _definitions = CoreDataTaxonomyTerms.fetchDefinitions(job: _job.wrappedValue)
    }
}

extension TermFilter {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.grouped = []
        if self.definitions.count > 0 {
            let sortedRecords = Array(self.definitions)
                .sliced(by: [.year, .month, .day], for: \.created!)
                .sorted(by: {$0.key > $1.key})
            let grouped = Dictionary(grouping: sortedRecords, by: {$0.key})

            for group in grouped {
                self.grouped.append(
                    TermsGroupedByDate(date: group.key, definitions: group.value.first?.value ?? [])
                )
            }
        }
    }
}

extension TermFilterBound {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.grouped = []
        if self.definitions.count > 0 {
            let sortedRecords = Array(self.definitions)
                .sliced(by: [.year, .month, .day], for: \.created!)
                .sorted(by: {$0.key > $1.key})
            let grouped = Dictionary(grouping: sortedRecords, by: {$0.key})

            for group in grouped {
                self.grouped.append(
                    TermsGroupedByDate(date: group.key, definitions: group.value.first?.value ?? [])
                )
            }
        }
    }
}
