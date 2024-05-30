//
//  Tabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct Tabs: View {
    @Environment(\.managedObjectContext) var moc
    @Binding public var job: Job?
    @Binding public var selected: EntityType
    @Binding public var date: Date
    static public let animationDuration: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Buttons(job: $job, selected: $selected)
            MiniTitleBar(selected: $selected)
                .border(width: 1, edges: [.bottom], color: .yellow)
            Content(job: $job, selected: $selected, date: $date)
                .swipe([.left, .right]) { swipe in
                    let tabs = EntityType.allCases
                    if var selectedIndex = tabs.firstIndex(of: selected) {
                        if swipe == .left {
                            if selectedIndex <= tabs.count - 2 {
                                selectedIndex += 1
                                selected = tabs[selectedIndex]
                            } else {
                                selected = tabs[0]
                            }
                        } else if swipe == .right {
                            if selectedIndex > 0 && selectedIndex <= tabs.count {
                                selectedIndex -= 1
                                selected = tabs[selectedIndex]
                            } else {
                                selected = tabs[tabs.count - 1]
                            }
                        }
                    }
                }
        }
        .background(.clear)
        .onChange(of: job) {
            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                selected = .records
            }
        }
    }
}

extension Tabs {
    struct Buttons: View {
        @Binding public var job: Job?
        @Binding public var selected: EntityType

        var body: some View {
            HStack(alignment: .center, spacing: 1) {
                ForEach(EntityType.allCases, id: \.self) { page in
                    VStack {
                        Button {
                            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                                selected = page
                            }
                        } label: {
                            if page != .jobs {
                                page.icon
                                .frame(maxHeight: 20)
                                .padding(14)
                                .background(page == selected ? .white : .clear)
                                .foregroundStyle(page == selected ? Theme.cPurple : .gray)
                            } else {
                                page.icon
                                    .frame(maxHeight: 20)
                                .padding(14)
                                .background(job == nil ? .red : page == selected ? .white : .clear)
                                .foregroundStyle(page == selected ? Theme.cPurple : job == nil ? .white : .gray)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .background(Theme.textBackground)
        }
    }

    struct Content: View {
        @Binding public var job: Job?
        @Binding public var selected: EntityType
        @Binding public var date: Date

        var body: some View {
            switch selected {
            case .records:
                List.Records(job: $job, date: date)
            case .jobs:
                List.Jobs(job: $job, date: date)
            case .tasks:
                List.Tasks(date: date)
            case .notes:
                List.Notes(date: date)
            case .companies:
                List.Companies(date: date)
            case .people:
                List.People(date: date)
            case .projects:
                List.Projects(date: date)
            }
        }
    }
}

extension Tabs.Content {
    struct List {
        struct Records: View {
            @FetchRequest private var items: FetchedResults<LogRecord>
            @Binding public var job: Job?
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { record in
                                Individual.SingleRecord(record: record)
                            }
                        } else {
                            StatusMessage.Warning(message: "No records found for \(Date().formatted(date: .abbreviated, time: .omitted)).\nAdd one below!")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(job: Binding<Job?>, date: Date) {
                _job = job
                self.date = date
                _items = CoreDataRecords.fetch(for: self.date)
            }
        }

        struct Jobs: View {
            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var job: Job?
            public var date: Date

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { jerb in
                                Individual.SingleJob(job: jerb, stateJob: $job)
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs modified within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(job: Binding<Job?>, date: Date) {
                _job = job
                self.date = date
                _items = CoreDataJob.fetchRecent(from: date)
            }
        }

        struct Tasks: View {
            @FetchRequest private var items: FetchedResults<LogTask>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { task in
                                Individual.SingleTask(task: task)
                            }
                        } else {
                            StatusMessage.Warning(message: "No tasks modified within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(date: Date) {
                self.date = date
                _items = CoreDataTasks.fetch(for: self.date)
            }
        }

        struct Notes: View {
            @FetchRequest private var items: FetchedResults<Note>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { note in
                                Individual.SingleNote(note: note)
                            }
                        } else {
                            StatusMessage.Warning(message: "No notes updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(date: Date) {
                self.date = date
                _items = CoreDataNotes.fetch(for: self.date)
            }
        }

        struct Companies: View {
            @FetchRequest private var items: FetchedResults<Company>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { item in
                                Individual.SingleCompany(company: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(date: Date) {
                self.date = date
                _items = CoreDataCompanies.fetch(for: self.date)
            }
        }

        struct People: View {
            @FetchRequest private var items: FetchedResults<Person>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { item in
                                Individual.SinglePerson(person: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No people updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(date: Date) {
                self.date = date
                _items = CoreDataPerson.fetch(for: self.date)
            }
        }

        struct Projects: View {
            @FetchRequest private var items: FetchedResults<Project>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { item in
                                Individual.SingleProject(project: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No projects updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }

            init(date: Date) {
                self.date = date
                _items = CoreDataProjects.fetch(for: self.date)
            }
        }
    }
}

extension Tabs.Content {
    struct Individual {
        struct SingleRecord: View {
            public let record: LogRecord

            var body: some View {
                NavigationLink {
                    RecordDetail(record: record)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: record.message ?? "_RECORD_CONTENT",
                        colour: record.job != nil ? record.job!.backgroundColor : Theme.rowColour,
                        extraColumn: AnyView(
                            Text(record.timestamp!.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(record.job!.backgroundColor.isBright() ? .black : .gray)
                        ),
                        highlight: false
                    )
                }
            }
        }

        struct SingleJob: View {
            public let job: Job
            @Binding public var stateJob: Job?

            var body: some View {
                Button {
                    stateJob = job
                } label: {
                    ListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleJobLink: View {
            public let job: Job

            var body: some View {
                NavigationLink {
                    JobDetail(job: job)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleTask: View {
            public let task: LogTask

            var body: some View {
                NavigationLink {
                    TaskDetail(task: task)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: task.content ?? "_TASK_CONTENT",
                        colour: task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleNote: View {
            public let note: Note

            var body: some View {
                NavigationLink {
                    NoteDetail(note: note)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: note.title ?? "_NOTE_TITLE",
                        colour: note.mJob != nil ? note.mJob!.backgroundColor : Theme.rowColour
                    )
                }
            }
        }

        struct SingleCompany: View {
            public let company: Company

            var body: some View {
                NavigationLink {
                    CompanyDetail(company: company)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: company.name ?? "_COMPANY_NAME",
                        colour: Color.fromStored(company.colour ?? Theme.rowColourAsDouble)
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SinglePerson: View {
            public let person: Person

            var body: some View {
                NavigationLink {
                    PersonDetail(person: person)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: person.name ?? "_PERSON_NAME",
                        colour: Theme.textBackground
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleProject: View {
            public let project: Project

            var body: some View {
                NavigationLink {
                    ProjectDetail(project: project)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: project.name ?? "_PROJECT_NAME",
                        colour: Color.fromStored(project.colour ?? Theme.rowColourAsDouble)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
