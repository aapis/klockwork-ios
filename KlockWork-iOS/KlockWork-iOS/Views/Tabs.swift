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
            TitleBar(selected: $selected)
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
                                HStack(spacing: 5) {
                                    page.icon
                                        .frame(maxHeight: 20)
                                }
                                .padding()
                                .background(page == selected ? .white : .clear)
                                .foregroundStyle(page == selected ? Theme.cPurple : .gray)
                            } else {
                                HStack(spacing: 5) {
                                    page.icon
                                        .frame(maxHeight: 20)
                                }
                                .padding()
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
                List.Jobs(job: $job)
            case .tasks:
                List.Tasks()
            case .notes:
                List.Notes()
            case .companies:
                List.Companies()
            case .people:
                List.People()
            }
        }
    }

    struct TitleBar: View {
        @Binding public var selected: EntityType

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Text(selected.label.uppercased())
                    .font(.caption)
                Spacer()
            }
            .padding(5)
            .background(Theme.darkBtnColour)
            .foregroundStyle(.gray)
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
                _items = CoreDataRecords.fetchForDate(self.date)
            }
        }

        struct Jobs: View {
            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var job: Job?

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

            init(job: Binding<Job?>) {
                _job = job
                _items = CoreDataJob.fetchRecent()
            }
        }

        struct Tasks: View {
            @FetchRequest private var items: FetchedResults<LogTask>

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

            init() {
                _items = CoreDataTasks.fetchRecent()
            }
        }

        struct Notes: View {
            @FetchRequest private var items: FetchedResults<Note>

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

            init() {
                _items = CoreDataNotes.fetchRecentNotes()
            }
        }

        struct Companies: View {
            @FetchRequest private var items: FetchedResults<Company>

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

            init() {
                _items = CoreDataCompanies.fetchRecent()
            }
        }

        struct People: View {
            @FetchRequest private var items: FetchedResults<Person>

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

            init() {
                _items = CoreDataPerson.fetchRecent()
            }
        }

        struct Projects: View {
            var body: some View {
                Text("Projects")
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
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 5) {
                            Text(record.message!)
                                .foregroundStyle(record.job!.backgroundColor.isBright() ? .black : .white)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Text(record.timestamp!.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(record.job!.backgroundColor.isBright() ? .black : .gray)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(record.job!.backgroundColor.isBright() ? .black : .gray)

                        }
                        .padding(8)
                        .background(record.job!.backgroundColor)
                        .listRowBackground(record.job!.backgroundColor)
                    }
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
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(job.title ?? job.jid.string)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6.0)
                        Spacer()
                        Text("Set")
                            .foregroundStyle(job.backgroundColor.isBright() ? .black : .gray)
                    }
                    .padding(8)
                    .background(job.backgroundColor)
                    .listRowBackground(job.backgroundColor)
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleTask: View {
            public let task: LogTask

            var body: some View {
                NavigationLink {
                    TaskDetail(task: task)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(task.content ?? "_TASK_CONTENT")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(task.owner != nil ? task.owner!.backgroundColor.isBright() ? .black : .gray : .gray)
                    }
                    .padding(8)
                    .background(task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour)
                    .listRowBackground(task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour)
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleNote: View {
            public let note: Note

            var body: some View {
                NavigationLink {
                    NoteDetail(note: note)
                } label: {
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(note.title ?? "_NOTE_TITLE")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(note.mJob != nil ? note.mJob!.backgroundColor.isBright() ? .black : .gray : .gray)
                    }
                    .padding(8)
                    .background(note.mJob != nil ? note.mJob!.backgroundColor : Theme.rowColour)
                    .listRowBackground(note.mJob != nil ? note.mJob!.backgroundColor : Theme.rowColour)
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
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(company.name ?? "_COMPANY_NAME")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                    .background(Color.fromStored(company.colour ?? Theme.rowColourAsDouble))
                    .listRowBackground(Color.fromStored(company.colour ?? Theme.rowColourAsDouble))
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
                    HStack(alignment: .firstTextBaseline, spacing: 5) {
                        Text(person.name ?? "_PERSON_NAME")
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)
                            .padding(4)
                            .background(.black.opacity(0.3))
                            .cornerRadius(6.0)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                    .padding(8)
                    .background(Theme.rowColour)
                    .listRowBackground(Theme.rowColour)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
