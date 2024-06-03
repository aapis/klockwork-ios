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
        results.add(await NotesEntityView(entityType: .notes, term: self.term!))
        results.add(await PeopleEntityView(entityType: .people, term: self.term!))
        results.add(await ProjectsEntityView(entityType: .projects, term: self.term!))
        results.add(await RecordsEntityView(entityType: .records, term: self.term!))
        results.add(await TasksEntityView(entityType: .tasks, term: self.term!))
        return results
    }

    // @TODO: consolidate these views with the Entities like Companies, Jobs, etc
    fileprivate struct CompanyEntityView: View {
        typealias Row = Tabs.Content.Individual.SingleCompany

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Company>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(company: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No companies matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Job>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(job: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No jobs matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(note: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No notes matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Person>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(person: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No people matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<Project>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(project: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No projects matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<LogRecord>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(record: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No records matched")
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

        @State public var entityType: EntityType
        @State private var open: Bool = true
        @FetchRequest public var results: FetchedResults<LogTask>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                TitleBar(selected: $entityType, open: $open, count: results.count)

                if open {
                    if !results.isEmpty {
                        ForEach(results) { entity in
                            Row(task: entity)
                        }
                    } else {
                        StatusMessage.Warning(message: "No tasks matched")
                    }
                }
            }
        }

        init(entityType: EntityType, term: String) {
            self.entityType = entityType
            _results = CoreDataTasks.fetchMatching(term: term)
        }
    }
}
