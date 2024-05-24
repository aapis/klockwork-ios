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
    @Binding public var selected: Page
    static public let animationDuration: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Buttons(job: $job, selected: $selected)
            Content(job: $job, selected: $selected)
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
    enum Page: CaseIterable {
        case records, jobs, tasks, notes
        
        /// Interface-friendly representation
        var label: String {
            switch self {
            case .records: "Records"
            case .jobs: "Jobs"
            case .tasks: "Tasks"
            case .notes: "Notes"
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .records: Image(systemName: "tray")
            case .jobs: Image(systemName: "hammer")
            case .tasks: Image(systemName: "checklist")
            case .notes: Image(systemName: "note.text")
            }
        }
    }

    struct Buttons: View {
        @Binding public var job: Job?
        @Binding public var selected: Page

        var body: some View {
            HStack(alignment: .center, spacing: 1) {
                ForEach(Page.allCases, id: \.self) { page in
                    Button {
                        withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                            selected = page
                        }
                    } label: {
                        if page != .jobs {
                            HStack(spacing: 5) {
                                page.icon
                                    .frame(maxHeight: 20)
                                if page == selected {
                                    Text(page.label)
                                }
                            }
                            .padding()
                            .background(page == selected ? .white : .clear)
                            .foregroundStyle(page == selected ? Theme.cPurple : .gray)
                        } else {
                            HStack(spacing: 5) {
                                page.icon
                                    .frame(maxHeight: 20)
                                if page == selected {
                                    Text(page.label)
                                }
                            }
                            .padding()
                            .background(job == nil ? .red : page == selected ? .white : .clear)
                            .foregroundStyle(page == selected ? Theme.cPurple : job == nil ? .white : .gray)
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer()
            }
            .background(Theme.textBackground)
        }
    }

    struct Content: View {
        @Binding public var job: Job?
        @Binding public var selected: Page

        var body: some View {
            switch selected {
            case .records:
                Records(job: $job)
            case .jobs:
                Jobs(job: $job)
            case .tasks:
                Tasks()
            case .notes:
                Notes()
            }
        }
    }
}

extension Tabs.Content {
    struct Records: View {
        @FetchRequest private var items: FetchedResults<LogRecord>
        @Binding public var job: Job?

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    if items.count > 0 {
                        ForEach(items) { record in
                            SingleRecord(record: record)
                        }
                    } else {
                        StatusMessage.Warning(message: "No records found for \(Date().formatted(date: .abbreviated, time: .omitted)).\nAdd one below!")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }

        init(job: Binding<Job?>) {
            _job = job
            _items = CoreDataRecords.fetchForDate(Date())
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
                            SingleJob(job: jerb, stateJob: $job)
                        }
                    } else {
                        StatusMessage.Warning(message: "No jobs found")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }

        init(job: Binding<Job?>) {
            _job = job
            _items = CoreDataJob.fetchAll()
        }
    }

    struct Tasks: View {
        @FetchRequest private var items: FetchedResults<LogTask>

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    if items.count > 0 {
                        ForEach(items) { task in
                            SingleTask(task: task)
                        }
                    } else {
                        StatusMessage.Warning(message: "No tasks found for \(Date().formatted(date: .abbreviated, time: .omitted))")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }

        init() {
            _items = CoreDataTasks.recentTasksWidgetData()
        }
    }

    struct Notes: View {
        @FetchRequest private var items: FetchedResults<Note>

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    if items.count > 0 {
                        ForEach(items) { note in
                            SingleNote(note: note)
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
                    Image(systemName: "chevron.right")
                        .foregroundStyle(job.backgroundColor.isBright() ? .black : .gray)
                }
                .padding(8)
                .background(job.backgroundColor)
                .listRowBackground(job.backgroundColor)
            }
            .buttonStyle(.plain)
        }
    }
}
