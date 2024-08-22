//
//  DefinitionDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-22.
//

import SwiftUI

struct DefinitionDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var definition: TaxonomyTermDefinitions?
    @State private var created: Date = Date()
    @State private var job: Job?
    @State private var title: String = ""
    @State private var alive: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var isJobSelectorPresented: Bool = false
    public var page: PageConfiguration.AppPage = .create

    var body: some View {
        VStack {
            List {
                Widget.JobSelector.FormField(
                    job: $job,
                    isJobSelectorPresented: $isJobSelectorPresented
                )

                Section("Definition") {
                    TextField("Definition", text: $title, axis: .vertical)
                }
                .listRowBackground(Theme.textBackground)

                Section("Settings") {
                    Toggle("Published", isOn: $alive)
                    DatePicker(
                        "Created",
                        selection: $created,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    // @TODO: implement JobPicker as a sheet
                }
                .listRowBackground(Theme.textBackground)

                if self.definition != nil {
                    Button("Delete Definition", role: .destructive, action: self.actionInitiateDelete)
                        .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                            Button("Yes", role: .destructive) {
                                self.actionOnDelete()
                            }
                        } message: {
                            Text("This definition will be permanently deleted.")
                        }
                        .listRowBackground(Color.red)
                        .foregroundStyle(.white)
                }
            }
            Spacer()
        }
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollContentBackground(.hidden)
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
                showing: $isJobSelectorPresented,
                job: $job
            )
            .presentationBackground(self.page.primaryColour)
        }
    }
}

extension DefinitionDetail {
    /// Onload handler. Sets timestamp and message fields.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        var dc = DateComponents()
        dc.year = 1969
        dc.month = 12
        dc.day = 31

        title = self.definition?.definition ?? "_DEFINITION_TITLE"
        alive = self.definition?.alive ?? false
        created = self.definition?.created ?? Calendar.autoupdatingCurrent.date(from: dc)!
        job = self.definition?.job
    }

    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.definition != nil {
            self.definition!.alive = alive
            self.definition!.lastUpdate = Date()
            self.definition!.definition = title
            self.definition!.job = job
        } else {
            // Create a new one
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Soft delete a Task
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.definition != nil {
            self.state.moc.delete(self.definition!)
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
