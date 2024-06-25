//
//  PersonDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct PersonDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var person: Person?
    public var page: PageConfiguration.AppPage = .create
    @State private var created: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var title: String = ""
    @State public var company: Company? = nil
    @State private var isCompanySelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        TextField("Name", text: $name, axis: .vertical)
                        TextField("Title", text: $title, axis: .vertical)
                        Widget.CompanySelector.FormField(
                            company: $company,
                            isCompanySelectorPresented: $isCompanySelectorPresented,
                            orientation: .horizontal
                        )
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Settings") {
                        DatePicker(
                            "Created",
                            selection: $created,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        if self.lastUpdate != self.created {
                            DatePicker(
                                "Last updated",
                                selection: $lastUpdate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    if self.person != nil {
                        Button("Delete Person", role: .destructive, action: self.actionInitiateDelete)
                            .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                                Button("Yes", role: .destructive) {
                                    self.actionOnDelete()
                                }
                            } message: {
                                Text("\"\(self.person?.name ?? "_NAME")\" will be permanently deleted")
                            }
                            .listRowBackground(Color.red)
                            .foregroundStyle(.white)
                    }
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .navigationTitle(self.person != nil ? "Person" : "New Person")
            .background(self.page.primaryColour)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    // Creates new entity on tap, then sends user back to Today
                    Button {
                        self.actionOnSave()
                    } label: {
                        Text("Save")
                    }
                    .foregroundStyle(self.state.theme.tint)
                    .alert("Saved", isPresented: $isSaveAlertPresented) {
                        Button("OK") {
                            dismiss()
                        }
                    } message: {
                        Text("\"\(self.name)\" saved")
                    }
                }
            }
            .sheet(isPresented: $isCompanySelectorPresented) {
                Widget.CompanySelector.Single(
                    showing: $isCompanySelectorPresented,
                    entity: $company
                )
                .presentationBackground(self.page.primaryColour)
            }
        }
    }
}

extension PersonDetail {
    /// Onload handler. Modifies view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let person = self.person {
            if let cDate = person.created {created = cDate}
            if let uDate = person.lastUpdate {lastUpdate = uDate}
            if let nm = person.name {name = nm}
            if let ti = person.title {title = ti}
            if let co = person.company {company = co}
        }
    }
    
    /// Callback for the Save button. Modifies an existing user, creates a new one if one cannot be found
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.person != nil {
            self.person!.name = self.name.trimmingCharacters(in: .newlines)
            self.person!.company = self.company
            self.person!.created = self.created
            self.person!.lastUpdate = Date()
            self.person!.title = self.title.trimmingCharacters(in: .newlines)
        } else {
            CoreDataPerson(moc: self.state.moc).create(
                created: self.created,
                lastUpdate: self.lastUpdate,
                name: self.name.trimmingCharacters(in: .newlines),
                title: self.title.trimmingCharacters(in: .newlines),
                company: self.company!, // @TODO: add form validation to prevent this from causing crashes
                saveByDefault: false
           )
        }

        isSaveAlertPresented.toggle()
        PersistenceController.shared.save()
    }

    /// Hard delete a Person. Thought it would be morbid to have an "alive" property on a Person object
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.person != nil {
            self.state.moc.delete(self.person!)
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
