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
    @State private var pid: Int64 = 0
    @State private var abbreviation: String = ""
    @State private var hidden: Bool = false
    @State private var colour: Color = .clear
    @State private var isProjectSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
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
                }
            }
            .background(self.page.primaryColour)
            .onAppear(perform: self.actionOnAppear)
            .navigationTitle(self.company != nil ? "Company" : "New Company")
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
            .sheet(isPresented: $isProjectSelectorPresented) {
                Widget.ProjectSelector.Multi(
                    showing: $isProjectSelectorPresented,
                    selected: $projects
                )
                .presentationBackground(self.page.primaryColour)
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

        isSaveAlertPresented.toggle()
        PersistenceController.shared.save()
    }
}
