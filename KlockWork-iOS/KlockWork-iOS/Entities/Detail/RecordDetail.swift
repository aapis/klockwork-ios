//
//  RecordDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct RecordDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) var openURL
    public var record: LogRecord?
    @State private var timestamp: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State public var message: String = ""
    @State public var job: Job?
    @State private var alive: Bool = true
    @State private var isJobSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var links: [Hyperlink] = []
    public var page: PageConfiguration.AppPage = .create

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Widget.JobSelector.FormField(
                        job: $job,
                        isJobSelectorPresented: $isJobSelectorPresented
                    )
                    TextField("What's on your mind?", text: $message, axis: .vertical)
                        .lineLimit(10...20)
                        .listRowBackground(Theme.textBackground)

                    if self.record?.tcType == .link && !self.links.isEmpty {
                        // Links
                        ForEach(self.links, id: \.self) { link in
                            Menu {
                                Text(StringHelper.truncate(link.uri?.absoluteString, len: 20))
                                    .lineLimit(1)
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.leading)
                                Divider()
                                Button {
                                    if let url = link.uri {
                                        self.openURL(url)
                                    }
                                } label: {
                                    Label("Open in browser", systemImage: "globe")
                                }
                                Button {
                                    UIPasteboard.general.string = link.uri?.absoluteString ?? ""
                                } label: {
                                    Label("Copy URL", systemImage: "document.on.document")
                                }
                            } label: {
                                Label("\(link.uri?.absoluteString ?? "Invalid Link")", systemImage: "link")
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .listRowBackground(Theme.lightBase)

                        if let comments = self.record?.comments?.allObjects as? [LogRecordComment] {
                            Section("Comments") {
                                ForEach(comments.sorted(by: {$0.timestamp ?? Date.now < $1.timestamp ?? Date.now}), id: \.self) { comment in
                                    HStack {
                                        Image(systemName: "bubble.left")
                                            .foregroundStyle(Theme.lightWhite)
                                        Text(comment.message ?? "nope")
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        Text("\(DateHelper.todayShort(comment.timestamp ?? Date.distantPast, format: "dd.MM.YYYY @ HH:mm"))")
                                            .foregroundStyle(Theme.lightWhite)
                                    }
                                }
                                .listRowBackground(Theme.textBackground)
                            }
                        }

                        if self.record == nil {
                            // Add mentions, update $message when person is added/removed
                            // Widget.PersonSelector.Single()
                        } else {
                            if let people = self.record?.people?.allObjects as? [Person] {
                                Section("Mentions") {
                                    ForEach(people, id: \.self) { person in
                                        Text(person.longUsername)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            }
                        }

                        Section("Settings") {
                            Toggle("Published", isOn: $alive)
                                .listRowBackground(Theme.textBackground)
                            DatePicker(
                                "Created",
                                selection: $timestamp,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .listRowBackground(Theme.textBackground)
                            DatePicker(
                                "Last updated",
                                selection: $lastUpdate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .listRowBackground(Theme.textBackground)
                            if self.record != nil {
                                Button("Delete Record", role: .destructive, action: self.actionInitiateDelete)
                                    .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                                        Button("Yes", role: .destructive) {
                                            self.actionOnDelete()
                                        }
                                    } message: {
                                        Text("This record will be permanently deleted.")
                                    }
                                    .listRowBackground(Color.red)
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    Spacer()
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(self.record != nil ? "Record" : "New Record")
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            self.message = ""
                            self.state.job = nil
                            self.job = nil
                        } label: {
                            Text("Clear")
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        // Creates new entity on tap, then sends user back to Today
                        Button {
                            self.actionOnSave()
                        } label: {
                            Text("Save")
                        }
                        .disabled(self.message == "" && self.state.job == nil)
                    }
                }
                .sheet(isPresented: $isJobSelectorPresented) {
                    Widget.JobSelector.Single(
                        job: $job
                    )
                    .presentationBackground(self.page.primaryColour)
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.job) {
                self.job = self.state.job
            }
        }
    }

    /// Onload handler. Sets timestamp and message fields.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.record != nil {
            if let tmstmp = self.record!.timestamp {
                self.timestamp = tmstmp
            }

            if let updated = self.record!.lastUpdate {
                self.lastUpdate = updated
            }

            if let msg = self.record!.message {
                self.message = msg
            }

            self.alive = self.record!.alive
            self.job = self.record!.job
            self.links = CoreDataRecords(moc: self.state.moc).linksForRecord(self.record!)
        } else {
            self.job = self.state.job
            self.timestamp = self.state.date // allows creating records for the selected date
            self.lastUpdate = self.timestamp
        }
    }

    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.record != nil {
            self.record!.message = self.message
            self.record!.job = self.job
            self.record!.alive = self.alive
            self.record!.timestamp = self.timestamp
        } else {
            CoreDataRecords(moc: self.state.moc).create(
                message: self.message,
                timestamp: self.timestamp,
                job: self.job,
                saveByDefault: false
            )
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Hard delete a Task
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.record != nil {
            self.state.moc.delete(self.record!)
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Opens the delete object alert
    /// - Returns: Void
    private func actionInitiateDelete() -> Void {
        self.isDeleteAlertPresented.toggle()
    }
}
