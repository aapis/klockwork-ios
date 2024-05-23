//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    @Environment(\.managedObjectContext) var moc
    @State private var job: Job? = nil
    @State private var showJobPanel: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(job: $job, showJobPanel: $showJobPanel)
                ZStack(alignment: .bottomLeading) {
                    Content(job: $job, showJobPanel: $showJobPanel)
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                if !showJobPanel {
                    Editor()
                    .background(job != nil ? job!.backgroundColor : .clear)
                }
                Spacer()
                .frame(height: 1)
            }
            .background(Theme.cPurple)
            .onChange(of: job) {
                showJobPanel = false
            }
        }
    }
}

extension Today {
    struct Header: View {
        @Binding public var job: Job?
        @Binding public var showJobPanel: Bool

        var body: some View {
            HStack(spacing: 0) {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Button {
                    showJobPanel.toggle()
                } label: {
                    ZStack {
                        if let jerb = job {
                            jerb.backgroundColor
                        } else {
                            Color.white
                        }
                        Image(systemName: showJobPanel ? "xmark" : "hammer")
                            .foregroundStyle(job != nil ? job!.backgroundColor.isBright() ? .black : .white : .black)
                    }
                }
                .mask(Circle())
                .frame(width: 40, height: 40)
                .padding(.trailing)
            }
        }
    }

    struct Content: View {
        @FetchRequest private var records: FetchedResults<LogRecord>
        @FetchRequest private var jobs: FetchedResults<Job>
        @Binding public var job: Job?
        @Binding public var showJobPanel: Bool

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 1) {
                    if showJobPanel {
                        if jobs.count > 0 {
                            ListTitle(text: "Jobs", icon: "hammer")

                            ForEach(jobs) { jerb in
                                SingleJob(job: jerb, stateJob: $job)
                            }
                        } else {
                            StatusMessages.Warning(message: "No jobs found")
                        }
                    } else {
                        if records.count > 0 {
                            ListTitle(text: "Records", icon: "tray")

                            ForEach(records) { record in
                                SingleRecord(record: record)
                            }
                        } else {
                            StatusMessages.Warning(message: "No records found for \(Date().formatted(date: .abbreviated, time: .omitted)).\nAdd one below!")
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }

        init(job: Binding<Job?>, showJobPanel: Binding<Bool>) {
            _job = job
            _showJobPanel = showJobPanel
            _records = CoreDataRecords.fetchForDate(Date())
            _jobs = CoreDataJob.fetchAll()
        }
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
                Text(job.jid.string)
                    .foregroundStyle(job.backgroundColor.isBright() ? .black : .white)
                    .multilineTextAlignment(.leading)
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

struct ListTitle: View {
    public let text: String
    public let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
            Spacer()
        }
        .font(.footnote)
        .foregroundStyle(.gray)
        .padding()
        .background(Theme.textBackground)
    }
}

struct StatusMessages {
    struct Warning: View {
        public let message: String

        var body: some View {
            HStack {
                Text("No records found for \(Date().formatted(date: .abbreviated, time: .omitted)).\nAdd one below!")
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(8)
            .background(.yellow)
            .foregroundStyle(.black.opacity(0.6))
        }
    }
}

struct Editor: View {
    enum Field {
        // Apparently you need to use an existing UITextContentType
        case organizationName
    }

    @Environment(\.managedObjectContext) var moc
    @State private var text: String = ""
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("What are you working on?", text: $text)
                .focused($focused, equals: .organizationName)
                .textContentType(.organizationName)
                .submitLabel(.done)
                .textSelection(.enabled)
                .lineLimit(1)
                .padding()
        }
//        .background(Theme.rowColour)
//        .border(width: 2, edges: [.bottom], color: .accentColor)
        .onSubmit {
            if !text.isEmpty {
                if let job = CoreDataJob(moc: moc).byId(33.0) {
                    let _ = CoreDataRecords(moc: moc).createWithJob(job: job, date: Date(), text: text)
                    text = ""
                }
            }
        }
    }
}
