//
//  TermDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-16.
//

import SwiftUI

struct TermDetail: View {
    typealias DefinitionLink = Tabs.Content.Individual.SingleDefinitionLink

    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var term: TaxonomyTerm?
    @State private var created: Date = Date()
    @State private var name: String = ""
    @State private var definitions: [TaxonomyTermDefinitions] = []
    @State private var alive: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    public var page: PageConfiguration.AppPage = .create

    var body: some View {
        VStack {
            List {
                Section("Term") {
                    TextField("Name", text: $name, axis: .vertical)
                }
                .listRowBackground(Theme.textBackground)

                Section("Definitions") {
                    ForEach(self.definitions, id: \TaxonomyTermDefinitions.objectID) { definition in
                        if definition.job != nil {
                            DefinitionLink(definition: definition)
                        }
                    }
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

                if self.term != nil {
                    Button("Delete Term", role: .destructive, action: self.actionInitiateDelete)
                        .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                            Button("Yes", role: .destructive) {
                                self.actionOnDelete()
                            }
                        } message: {
                            Text("This term will be permanently deleted.")
                        }
                        .listRowBackground(Color.red)
                        .foregroundStyle(.white)
                }
            }
            Spacer()
        }
        .background(self.page.primaryColour)
        .onAppear(perform: actionOnAppear)
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
    }
}

extension TermDetail {
    /// Onload handler. Sets timestamp and message fields.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.term != nil {
            if let tmstmp = self.term!.created {
                self.created = tmstmp
            }

            if let name = self.term!.name {
                self.name = name
            }

            if let def = self.term!.definitions {
                self.definitions = def.allObjects as! [TaxonomyTermDefinitions]
            }

            self.alive = self.term!.alive
        }
    }

    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.term != nil {
            self.term!.name = self.name
            self.term!.alive = self.alive
            self.term!.definitions = NSSet(array: self.definitions)
        } else {
//            CoreDataTaxonomyTerms(moc: self.state.moc).create(
//                message: self.message,
//                timestamp: self.timestamp,
//                job: self.job,
//                saveByDefault: false
//            )
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Soft delete a Task
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.term != nil {
            self.state.moc.delete(self.term!)
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
