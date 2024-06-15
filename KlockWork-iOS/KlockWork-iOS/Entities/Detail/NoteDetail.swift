//
//  NoteDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct NoteDetail: View {
    public let note: Note
    @Binding public var isSheetPresented: Bool
    @State private var versions: [NoteVersion] = []
    @State private var current: NoteVersion? = nil
    @State private var content: String = ""
    @State private var title: String = ""
    @State private var job: Job? = nil
    private let page: PageConfiguration.AppPage = .create
    static public let defaultTitle: String = "Sample Note Title"

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            ZStack(alignment: .topLeading) {
                RadialGradient(gradient: Gradient(colors: [.black, .clear]), center: .topTrailing, startRadius: 0, endRadius: 400)
                    .opacity(0.45)
                    .blendMode(.softLight)

                ZStack {
                    VStack {
//                        if job != nil {
                            Editor(job: $job)
//                        }

                        HStack {
                            TextEditor(text: $content)
                                .padding()
                            Spacer()
                        }
                        Spacer()
                        PageActionBar.Create(page: self.page, isSheetPresented: $isSheetPresented, job: $job)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .onAppear(perform: actionOnAppear)
        .navigationTitle(self.current != nil ? current!.title! : title)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .background(self.page.primaryColour)
//        .scrollDismissesKeyboard(.immediately) // @TODO: remove if still commented out
    }

    struct Editor: View {
        @EnvironmentObject private var state: AppState
        @Binding public var job: Job?
        @FetchRequest private var recentJobs: FetchedResults<Job>

        var body: some View {
            VStack {
                HStack {
                    Menu {
                        Text("Choose from recently used")
                        Divider()

                        ForEach(recentJobs) { jerb in
                            Button {
                                job = jerb
                            } label: {
                                Text(jerb.title ?? jerb.jid.string)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "hammer")
                                .frame(maxHeight: 20)
                            Text(self.job != nil ? "Selected: \(self.job!.title ?? self.job!.jid.string)" : "None")
                        }
                        .padding(14)
                        .tint(self.job != nil ? self.job!.backgroundColor.isBright() ? Theme.base : self.state.theme.tint : self.state.theme.tint)
                        .background(self.job != nil ? self.job!.backgroundColor : Theme.rowColour)
                    }

                    Spacer()
                }
                .frame(height: 50)
            }
            .background(Theme.textBackground)
            .border(width: 1, edges: [.bottom], color: Theme.rowColour)
        }

        init(job: Binding<Job?>) {
            _job = job
            _recentJobs = CoreDataJob.fetchRecent(numDaysPrior: 7, limit: 10)
        }
    }

    struct Sheet: View {
        public let note: Note
        public var currentVersion: NoteVersion? = nil
        @Binding public var isPresented: Bool

        var body: some View {
            NoteDetail(note: note, isSheetPresented: $isPresented)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        MetaData(note: note, version: self.currentVersion)
                    } label: {
                        HStack(spacing: 5) {
                            Text("More")
                            Image(systemName: "chevron.right")
                                .font(.headline)
                        }
                    }
                }
            }
        }

        init(note: Note, isPresented: Binding<Bool>) {
            self.note = note
            _isPresented = isPresented

            let versions = note.versions!.allObjects as! [NoteVersion]
            if let version = versions.sorted(by: {$0.created! < $1.created!}).first {
                self.currentVersion = version
            }
        }
    }

    struct MetaData: View {
        public let note: Note
        public let version: NoteVersion?
        private let page: PageConfiguration.AppPage = .create
        @State private var starred: Bool = false
        @State private var alive: Bool = true
        @State private var lastUpdate: Date = Date()
        @State private var versionTitle: String = ""
        @State private var versionCreatedDate: Date = Date()
        @State private var versionSource: SaveSource = .manual

        var body: some View {
            VStack {
                List {
                    Section("Settings") {
                        Toggle("Published", isOn: $alive)

                        if version != nil {
                            DatePicker(
                                "Created",
                                selection: $versionCreatedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )

                            DatePicker(
                                "Last Updated",
                                selection: $lastUpdate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    if version != nil {
                        Section("Title") {
                            TextField("Title", text: $versionTitle)
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
                .listStyle(.grouped)
            }
            .navigationTitle("Metadata")
            .background(self.page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
            .onAppear(perform: self.actionOnAppear)
        }
    }
}

// MARK: Method definitions
extension NoteDetail {
    /// Onload handler. Gets the latest version of the note and populates the title field
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let vers = note.versions {
            versions = vers.allObjects as! [NoteVersion]
            current = versions.sorted(by: {
                if $0.created != nil && $1.created != nil {
                    return $0.created! < $1.created!
                }
                return false
            }).first

            if let jerb = self.note.mJob {
                job = jerb
            }

            if let curr = current {
                title = curr.title ?? "_NOTE_TITLE"
                content = curr.content ?? "_NOTE_CONTENT"
            }
        } else if let body = note.body {
            title = note.title ?? "_NOTE_TITLE"
            content = body
        }
    }
}

extension NoteDetail.MetaData {
    /// Onload handler. Sets all the required fields
    /// - Returns: Void
    public func actionOnAppear() -> Void {
        self.alive = self.note.alive
        self.versionCreatedDate = self.version!.created!
        self.versionTitle = self.version!.title!
    }
}
