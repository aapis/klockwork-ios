//
//  CompanyDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var company: Company?
    @State private var alive: Bool = true
    @State private var projects: [Project] = []
    @State private var isDefault: Bool = false
    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var pid: Int64 = Int64.random(in: 99999...99999999)
    @State private var abbreviation: String = ""
    @State private var hidden: Bool = false
    @State private var colour: Color = .clear
    @State private var isProjectSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    @State private var selectedCompany: Company? = nil
    private let page: PageConfiguration.AppPage = .create
    static public let defaultName: String = "Initech Inc"

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        TextField("Name", text: $name, axis: .vertical)
                        TextField("Abbreviation", text: $abbreviation, axis: .vertical)
                        ColorPicker(selection: $colour) {
                            Text("Colour")
                                .foregroundStyle(.gray)
                        }
                        .listRowBackground(colour == .clear ? Theme.textBackground : colour)
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Projects") {
                        Widget.ProjectSelector.Multi.FormField(
                            projects: $projects,
                            company: $selectedCompany,
                            isProjectSelectorPresented: $isProjectSelectorPresented,
                            orientation: .horizontal
                        )
                    }

                    Section("Settings") {
                        Toggle("Published", isOn: $alive)
                        Toggle("Default", isOn: $isDefault)
                        Toggle("Hidden", isOn: $hidden)

                        DatePicker(
                            "Created",
                            selection: $createdDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        DatePicker(
                            "Last updated",
                            selection: $lastUpdate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                    .listRowBackground(Theme.textBackground)

                    if self.company != nil {
                        Button("Delete Company", role: .destructive, action: self.actionInitiateDelete)
                            .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                                Button("Yes", role: .destructive) {
                                    self.actionOnDelete()
                                }
                            } message: {
                                Text("\"\(self.name)\" will be deleted, but is recoverable.")
                            }
                            .listRowBackground(Color.red)
                            .foregroundStyle(.white)
                    }
                }
            }
            .background(self.page.primaryColour)
            .onAppear(perform: self.actionOnAppear)
            .navigationTitle(self.company != nil ? "Company" : "New Company")
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
                }
            }
            .sheet(isPresented: $isProjectSelectorPresented) {
                Widget.ProjectSelector.Multi(
                    showing: $isProjectSelectorPresented,
                    selected: $projects
                )
                .presentationBackground(self.page.primaryColour)
            }
            .onChange(of: self.isDefault) {
                let model = CoreDataCompanies(moc: self.state.moc)
                if let company = model.findDefault() {
                    if self.isDefault == true && company != self.company {
                        model.unsetDefault()
                    }
                }
            }
        }
    }
}

extension CompanyDetail {
    /// Onload handler. Modifies view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let company = self.company {
            projects = company.projects?.allObjects as! [Project]

            if let cDate = company.createdDate {createdDate = cDate}
            if let uDate = company.lastUpdate {lastUpdate = uDate}
            if let nm = company.name {name = nm}
            if let ab = company.abbreviation {abbreviation = ab}
            if let co = company.colour {colour = Color.fromStored(co)}
            self.isDefault = company.isDefault
        } else {
            self.createdDate = self.state.date
        }
    }

    /// Callback for the Save button. Modifies an existing user, creates a new one if one cannot be found
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.company != nil {
            self.company!.name = self.name
            self.company!.colour = self.colour.toStored()
            self.company!.abbreviation = self.abbreviation
            self.company!.createdDate = self.createdDate
            self.company!.lastUpdate = Date()
            self.company!.projects = NSSet(array: self.projects)
            self.company!.alive = self.alive
            self.company!.hidden = self.hidden
            self.company!.isDefault = self.isDefault
        } else {
            CoreDataCompanies(moc: self.state.moc).create(
                name: self.name,
                abbreviation: self.abbreviation,
                colour: self.colour.toStored(),
                created: self.createdDate,
                updated: Date(),
                projects: NSSet(array: self.projects),
                isDefault: self.isDefault,
                pid: self.pid,
                alive: self.alive,
                hidden: self.hidden,
                saveByDefault: false
           )
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Soft delete a Company
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        self.alive = false
        if self.company != nil {
            self.company!.alive = self.alive
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
