//
//  Search.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI
import CoreData

class SearchLibrary {
    let term: String
    var engine: SearchEngine = SearchEngine()

    init(term: String) {
        self.term = term
        self.engine.term = term
    }

    func query() async -> SearchResults? {
        return await self.engine.query()
    }
}

extension SearchLibrary {
    struct SearchResults {
        var children: [SingleResult] = []
        var hasResults: Bool = false
    }

    struct SingleResult: Identifiable {
        typealias EntityType = PageConfiguration.EntityType

        var id: UUID = UUID()
        var type: EntityType
        var view: AnyView
    }

    struct SearchEngine {
        var term: String?
    }
}

extension SearchLibrary.SearchResults {
    mutating func add(_ entity: any View) -> Void {
        children.append(
            SearchLibrary.SingleResult(
                type: .companies,
                view: AnyView(entity)
            )
        )

        self.hasResults = !children.isEmpty
    }

    mutating func reset() -> Void {
        self.children = []
        self.hasResults = false
    }
}

extension SearchLibrary.SearchEngine {
    func query() async -> SearchLibrary.SearchResults? {
        if self.term == nil {
            return nil
        }

        var results = SearchLibrary.SearchResults()
        results.add(await CompanyEntityView(entityType: .companies, term: self.term!))
        results.add(await JobsEntityView(entityType: .jobs, term: self.term!))
        results.add(await ProjectsEntityView(entityType: .projects, term: self.term!))
        results.add(await TermEntityView(entityType: .terms, term: self.term!))
        results.add(await TasksEntityView(entityType: .tasks, term: self.term!))
        results.add(await PeopleEntityView(entityType: .people, term: self.term!))
        results.add(await NotesEntityView(entityType: .notes, term: self.term!))
        results.add(await RecordsEntityView(entityType: .records, term: self.term!))
        return results
    }

    // @TODO: consolidate these views with the Entities like Companies, Jobs, etc
    fileprivate struct CompanyEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleCompany
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Company>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(company: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataCompanies.fetchMatching(term: term)
        }
    }

    fileprivate struct JobsEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleJobLink
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Job>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(job: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataJob.fetchMatching(term: term)
        }
    }

    fileprivate struct NotesEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleNote
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Note>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(note: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataNotes.fetchMatching(term: term)
        }
    }

    fileprivate struct PeopleEntityView: View {
        typealias Row = Tabs.Content.Individual.SinglePerson
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Person>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(person: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataPerson.fetchMatching(term: term)
        }
    }

    fileprivate struct ProjectsEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleProject
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Project>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(project: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataProjects.fetchMatching(term: term)
        }
    }

    fileprivate struct RecordsEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleRecord
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<LogRecord>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(record: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataRecords.fetchMatching(term: term)
        }
    }

    fileprivate struct TasksEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleTask
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<LogTask>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(task: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataTasks.fetchMatching(term: term)
        }
    }

    fileprivate struct TermEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleTerm
        typealias EntityType = PageConfiguration.EntityType

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<TaxonomyTerm>

        var body: some View {
            if self.results.count > 0 {
                VStack(alignment: .leading, spacing: 1) {
                    TitleBar(selected: $entityType, open: $open, count: results.count)

                    if open {
                        if !results.isEmpty {
                            ForEach(results) { entity in
                                Row(term: entity)
                            }
                        }
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataTaxonomyTerms.fetchMatching(term: term)
        }
    }
}
