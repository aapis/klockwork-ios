//
//  TaskDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    @State public var task: LogTask?
    @State private var completedDate: Date = Date()
    @State private var cancelledDate: Date = Date()
    @State private var content: String = ""
    @State private var created: Date = Date()
    @State private var due: Date = DateHelper.endOfDay() ?? Date()
    @State private var dueTomorrow: Date = DateHelper.endOfTomorrow() ?? Date()
    @State private var lastUpdate: Date = Date()
    @State public var job: Job?
    @State private var company: Company?
    @State private var project: Project?
    @State private var isCompleted: Bool = false
    @State private var isCancelled: Bool = false
    @State private var isJobSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    public var page: PageConfiguration.AppPage = .create
    static public let defaultContent: String = "Sample task content"

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Widget.JobSelector.FormField(
                        job: $job,
                        isJobSelectorPresented: $isJobSelectorPresented
                    )

                    TextField("What needs to be done?", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                        .listRowBackground(Theme.textBackground)

                    Section {
                        if self.isCompleted || self.isCancelled {
                            Button {
                                self.isCompleted = false
                                self.isCancelled = false
                                self.task!.completedDate = nil
                                self.task!.cancelledDate = nil

                                self.actionOnSave()
                            } label: {
                                HStack {
                                    Image(systemName: "plus")
                                        .foregroundStyle(self.state.theme.tint)
                                    Text("Reopen")
                                }
                            }
                            .listRowBackground(Theme.textBackground)
                        }
                        
                        if self.task != nil {
                            Button {
                                if let newDate = DateHelper.endOfTomorrow(self.due) {
                                    self.due = newDate
                                }
                                self.actionOnSave()
                            } label: {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundStyle(self.state.theme.tint)
                                    Text("Due tomorrow")
                                }
                            }
                            .listRowBackground(Theme.textBackground)

                            Button {
                                CoreDataTasks(moc: self.state.moc).create(
                                    content: self.content,
                                    created: Date(),
                                    due: self.due,
                                    job: self.job
                                )
                                dismiss()
                            } label: {
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                        .foregroundStyle(self.state.theme.tint)
                                    Text("Duplicate")
                                }
                            }
                            .listRowBackground(Theme.textBackground)
                        }
                    }

                    Section("Settings") {
                        DatePicker(
                            "Due",
                            selection: $due,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        
                        // Show last updated when editing
                        if self.task != nil {
                            DatePicker(
                                "Last updated",
                                selection: $lastUpdate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .disabled(true)
                        }

                        if isCompleted {
                            DatePicker(
                                "Completed on",
                                selection: $completedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .listRowBackground(Theme.cGreen)
                        } else {
                            Toggle("Completed", isOn: $isCompleted)
                        }
                        
                        if self.task != nil {
                            if isCancelled {
                                DatePicker(
                                    "Cancelled on",
                                    selection: $cancelledDate,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                            } else {
                                Toggle("Cancelled", isOn: $isCancelled)
                            }
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    if self.task != nil {
                        Button("Delete Task", role: .destructive, action: self.actionInitiateDelete)
                            .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                                Button("Yes", role: .destructive) {
                                    self.actionOnDelete()
                                }
                            } message: {
                                Text("\"\(self.content)\" will be permanently deleted.")
                            }
                            .listRowBackground(Color.red)
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .navigationTitle("Task")
            .background(self.page.primaryColour)
            .scrollContentBackground(.hidden)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
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
#endif
            .sheet(isPresented: $isJobSelectorPresented) {
                Widget.JobSelector.Single(
                    job: $job
                )
                .presentationBackground(self.page.primaryColour)
            }
        }
    }
}

extension TaskDetail {
    /// Onload handler, sets view data
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let task = self.task {
            if let coDate = task.completedDate {
                completedDate = coDate
                isCompleted = true
            }

            if let caDate = task.cancelledDate {
                cancelledDate = caDate
                isCancelled = true
            }

            if let cDate = task.created {created = cDate}
            if let dDate = task.due {due = dDate}
            if let uDate = task.lastUpdate {lastUpdate = uDate}
            if let co = task.content {content = co}
            if let jo = task.owner {job = jo}
        } else {
            self.job = self.state.job
            self.created = self.state.date
        }
    }
    
    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.task != nil {
            self.task!.content = self.content
            self.task!.owner = self.job
            self.task!.lastUpdate = Date()
            self.task!.due = self.due

            if isCancelled {
                self.task!.cancelledDate = Date()
            } else if isCompleted {
                self.task!.completedDate = Date()
            }
        } else {
            CoreDataTasks(moc: self.state.moc).create(
                content: self.content,
                created: self.created,
                due: self.due,
                job: self.job,
                saveByDefault: false
            )
        }

        self.state.job = self.job

        PersistenceController.shared.save()
        // We use 2 on purpose to close the sheet
        dismiss()
        dismiss()
    }

    /// Soft delete a Task
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.task != nil {
            self.state.moc.delete(self.task!)
        }

        PersistenceController.shared.save()
        // We use 2 on purpose to close the sheet
        dismiss()
        dismiss()
    }

    /// Opens the delete object alert
    /// - Returns: Void
    private func actionInitiateDelete() -> Void {
        self.isDeleteAlertPresented.toggle()
    }
}
