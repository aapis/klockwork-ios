//
//  NoteDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var note: Note? = nil
    @State private var versions: [NoteVersion] = []
    @State private var current: NoteVersion? = nil
    @State private var content: String = ""
    @State private var title: String = ""
    @State public var job: Job? = nil
    @State private var starred: Bool = false
    @State private var postedDate: Date = Date()
    @State private var alive: Bool = true
    @State private var isSaveAlertPresented: Bool = false
    public var page: PageConfiguration.AppPage = .create
    static public let defaultTitle: String = "Sample Note Title"
    @FocusState private var contentFieldFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ZStack(alignment: .topLeading) {
                RadialGradient(gradient: Gradient(colors: [.black, .clear]), center: .topTrailing, startRadius: 0, endRadius: 400)
                    .opacity(0.45)
                    .blendMode(.softLight)

                ZStack {
                    VStack {
                        Editor(job: $job, title: $title)
                        HStack {
                            TextEditor(text: $content)
                                .focused($contentFieldFocused)
                                .padding()
                                .foregroundStyle(contentFieldFocused ? .white : .gray)
                            Spacer()
                        }
                        Spacer()
                        PageActionBar.Create(
                            page: self.page,
                            job: $job,
                            onSave: self.actionOnSave
                        )
                    }
                }
            }
        }
        .foregroundStyle(self.state.theme.tint)
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle(title.prefix(25))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    struct Editor: View {
        @EnvironmentObject private var state: AppState
        @Binding public var job: Job?
        @Binding public var title: String
        @FetchRequest private var recentJobs: FetchedResults<Job>
        @FetchRequest private var mostCommonJobs: FetchedResults<Job>
        @State private var fromCurrentProject: [Job] = []
        @State private var fromCurrentCompany: [Job] = []
        @FocusState private var titleFieldFocused: Bool

        var body: some View {
            VStack {
                HStack {
                    TextField("Title", text: $title)
                        .focused($titleFieldFocused)
                        .padding(.leading)
                        .foregroundStyle(titleFieldFocused ? .white : .gray)
                    Spacer()
                    Menu {
                        // A little bit of info about the current job (title and JID)
                        if self.job != nil {
                            Text("Title: \((title).prefix(25))")
                            Text("ID: \(self.job!.jid.string)")
                        } else {
                            Text("Select a job")
                        }

                        Divider()
                        
                        if !self.mostCommonJobs.isEmpty {
                            Menu("Popular", systemImage: "checkmark.seal") {
                                ForEach(mostCommonJobs) { jerb in
                                    Button {
                                        job = jerb
                                    } label: {
                                        Text(jerb.title ?? jerb.jid.string)
                                    }
                                }
                            }
                        }

                        if !self.recentJobs.isEmpty {
                            Menu("Recent", systemImage: "clock") {
                                ForEach(recentJobs) { jerb in
                                    Button {
                                        job = jerb
                                    } label: {
                                        Text(jerb.title ?? jerb.jid.string)
                                    }
                                }
                            }
                        }

                        if !self.fromCurrentProject.isEmpty {
                            Menu("From this Project", systemImage: "folder") {
                                ForEach(fromCurrentProject) { entity in
                                    Button {
                                        job = entity
                                    } label: {
                                        Text(entity.title ?? entity.jid.string)
                                    }
                                }
                            }
                        }

                        if !self.fromCurrentCompany.isEmpty {
                            Menu("From this Company", systemImage: "building.2") {
                                ForEach(fromCurrentCompany) { jerb in
                                    Button {
                                        job = jerb
                                    } label: {
                                        Text(jerb.title ?? jerb.jid.string)
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: self.job != nil ? "hammer.fill" : "hammer")
                                .frame(maxHeight: 20)
                        }
                        .padding(14)
                        .tint(self.job != nil ? self.job!.backgroundColor.isBright() ? Theme.base : self.state.theme.tint : .white)
                        .background(self.job != nil ? self.job!.backgroundColor : .red)
                    }
                }
                .frame(height: 50)
            }
            .background(Theme.textBackground)
            .border(width: 1, edges: [.bottom], color: Theme.rowColour)
            .onChange(of: self.job) {
                self.populateJobSelector()
            }
            .onAppear(perform: self.populateJobSelector)
        }

        init(job: Binding<Job?>, title: Binding<String>) {
            _job = job
            _title = title
            _recentJobs = CoreDataJob.fetchRecent(numDaysPrior: 7, limit: 7)
            _mostCommonJobs = CoreDataJob.fetchAll(limit: 7) // @TODO: use .fetchCommon instead
        }
    }

    struct Sheet: View {
        @EnvironmentObject private var state: AppState
        public var note: Note?
        public var page: PageConfiguration.AppPage = .modify
        @State private var starred: Bool = false
        @State private var alive: Bool = true
        @State private var lastUpdate: Date = Date()
        @State private var versionTitle: String = ""
        @State private var versionCreatedDate: Date = Date()
        @State private var versionSource: SaveSource = .manual

        var body: some View {
            NoteDetail(note: note, page: self.page)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            MetaData(
                                starred: $starred,
                                alive: $alive,
                                lastUpdate: $lastUpdate,
                                created: $versionCreatedDate
                            )
                        } label: {
                            HStack(spacing: 5) {
                                Text("More")
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                            .foregroundStyle(self.state.theme.tint)
                        }
                    }
                }
        }

        init(note: Note? = nil, page: PageConfiguration.AppPage = .create) {
            self.note = note
            self.page = page

            if self.note != nil {
                let versions = self.note!.versions!.allObjects as! [NoteVersion]
                if let version = versions.sorted(by: {$0.created! < $1.created!}).first {
                    starred = version.starred
                    versionTitle = version.title ?? ""
                    versionCreatedDate = version.created!
                    lastUpdate = self.note!.lastUpdate ?? Date()
                }

                if versionTitle.isEmpty {
                    if self.note!.title != nil {
                        versionTitle = self.note!.title!
                    }
                }

                if self.note!.postedDate != nil {
                    versionCreatedDate = self.note!.postedDate!
                }
            }
        }
    }

    struct MetaData: View {
        private let page: PageConfiguration.AppPage = .create
        @Binding public var starred: Bool
        @Binding public var alive: Bool
        @Binding public var lastUpdate: Date
        @Binding public var created: Date

        var body: some View {
            VStack {
                List {
                    Section("Settings") {
                        Toggle("Published", isOn: $alive)
                        Toggle("Favourite", isOn: $starred)

                        DatePicker(
                            "Created",
                            selection: $created,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        DatePicker(
                            "Last Updated",
                            selection: $lastUpdate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                    .listRowBackground(Theme.textBackground)
                }
            }
            .navigationTitle("Metadata")
            .background(self.page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
        }
    }
}

// MARK: Method definitions
extension NoteDetail {
    /// Onload handler. Gets the latest version of the note and populates the title field
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let note = self.note {
            self.title = note.title ?? ""
            self.starred = note.starred
            self.postedDate = note.postedDate ?? Date()
            self.alive = note.alive
            self.content = note.body ?? ""
            if let jerb = note.mJob {
                self.job = jerb
            }

            if let vers = note.versions {
                self.versions = vers.allObjects as! [NoteVersion]
                self.current = versions.sorted(by: {
                    if $0.created != nil && $1.created != nil {
                        return $0.created! < $1.created!
                    }
                    return false
                }).last

                if let current = self.current {
                    self.content = current.content ?? ""
                }
            }
        }

    }
    
    /// Save a new version
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.note != nil {
            CoreDataNotes(moc: self.state.moc).update(
                entity: self.note!,
                alive: self.alive,
                body: self.content,
                lastUpdate: Date(),
                postedDate: Date(),
                starred: self.starred,
                title: self.title,
                job: self.job
            )
        } else {
            CoreDataNotes(moc: self.state.moc).create(
                alive: self.alive,
                body: self.content,
                lastUpdate: Date(),
                postedDate: Date(),
                starred: self.starred,
                title: self.title,
                job: self.job
            )
        }

        isSaveAlertPresented.toggle()
    }
}

extension NoteDetail.Editor {
    /// Find related jobs for a given Job
    /// - Returns: Void
    private func populateJobSelector() -> Void {
        self.fromCurrentProject = []
        self.fromCurrentCompany = []

        if let job = self.job {
            if let project = job.project {
                self.fromCurrentProject.append(
                    contentsOf: CoreDataJob(moc: self.state.moc).byProject(project)
                )

                if let company = project.company {
                    self.fromCurrentCompany.append(
                        contentsOf: CoreDataJob(moc: self.state.moc).byCompany(company)
                    )
                }
            }
        }
    }
}
