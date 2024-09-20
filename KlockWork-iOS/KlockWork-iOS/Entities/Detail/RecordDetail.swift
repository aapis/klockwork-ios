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
    public var record: LogRecord?
    @State private var timestamp = Date()
    @State private var message: String = ""
    @State public var job: Job?
    @State private var alive: Bool = true
    @State private var isJobSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    public var page: PageConfiguration.AppPage = .create

    var body: some View {
        VStack {
            List {
                Widget.JobSelector.FormField(
                    job: $job,
                    isJobSelectorPresented: $isJobSelectorPresented
                )

                TextField("Record content", text: $message, axis: .vertical)
                    .lineLimit(5...10)
                    .listRowBackground(Theme.textBackground)
                
                Section("Settings") {
                    Toggle("Published", isOn: $alive)
                }
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
            Spacer()
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(self.record != nil ? "Record" : "New Record")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Creates new entity on tap, then sends user back to Today
                Button {
                    self.actionOnSave()
                } label: {
                    Text("Save")
                }
                .foregroundStyle(self.state.theme.tint)
            }
        }
        .sheet(isPresented: $isJobSelectorPresented) {
            Widget.JobSelector.Single(
                job: $job
            )
            .presentationBackground(self.page.primaryColour)
        }
    }
}

extension RecordDetail {
    /// Onload handler. Sets timestamp and message fields.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.record != nil {
            if let tmstmp = self.record!.timestamp {
                self.timestamp = tmstmp
            }

            if let msg = self.record!.message {
                self.message = msg
            }

            self.alive = self.record!.alive
            self.job = self.record!.job
        }
    }

    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.record != nil {
            self.record!.message = self.message
            self.record!.job = self.job
            self.record!.alive = self.alive
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

    /// Soft delete a Task
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
