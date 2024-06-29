//
//  ProjectDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct ProjectDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var project: Project?
    @State private var abbreviation: String = ""
    @State private var alive: Bool = false
    @State private var colour: Color = .clear
    @State public var company: Company?
    @State private var jobs: [Job] = []
    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var pid: Int64 = 0
    @State private var isCompanySelectorPresent: Bool = false
    @State private var isJobSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    static public let defaultName: String = "A Really Good Project Name"

    private let page: PageConfiguration.AppPage = .create

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        TextField("Name", text: $name, axis: .vertical)
                        TextField("Abbreviation/Code", text: $abbreviation, axis: .vertical)
                        Widget.CompanySelector.FormField(
                            company: $company,
                            isCompanySelectorPresented: $isCompanySelectorPresent,
                            orientation: .horizontal
                        )
                        ColorPicker(selection: $colour) {
                            Text("Colour")
                                .foregroundStyle(colour == .clear ? .gray : .white)
                        }
                        .listRowBackground(colour == .clear ? Theme.textBackground : colour)
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Jobs") {
                        Widget.JobSelector.Multi.FormField(
                            jobs: $jobs,
                            isJobSelectorPresented: $isJobSelectorPresented
                        )
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Settings") {
                        Toggle("Published", isOn: $alive)
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

                    if self.project != nil {
                        Button("Delete Project", role: .destructive, action: self.actionInitiateDelete)
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
            .background(page.primaryColour)
            .onAppear(perform: actionOnAppear)
            .navigationTitle(self.project != nil ? "Project" : "New Project")
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
            .sheet(isPresented: $isCompanySelectorPresent) {
                Widget.CompanySelector.Single(
                    showing: $isCompanySelectorPresent,
                    entity: $company
                )
                .presentationBackground(self.page.primaryColour)
            }
            .sheet(isPresented: $isJobSelectorPresented) {
                Widget.JobSelector.Multi(
                    title: "Assign jobs to this project",
                    filter: .unowned,
                    showing: $isJobSelectorPresented,
                    selectedJobs: $jobs
                )
                .presentationBackground(self.page.primaryColour)
            }
        }
    }
}

extension ProjectDetail {
    /// Onload handler. Sets form field values
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let project = self.project {
            if let cDate = project.created {createdDate = cDate}
            if let uDate = project.lastUpdate {lastUpdate = uDate}
            if let nm = project.name {name = nm}
            if let ab = project.abbreviation {abbreviation = ab}
            if let co = project.colour {colour = Color.fromStored(co)}
            if let comp = project.company {company = comp}
            self.alive = project.alive
            self.pid = project.pid
            self.jobs = project.jobs?.allObjects as! [Job]
        }
    }
    
    /// Fired when the save button is tapped in the toolbar. Saves project object
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.project != nil {
            project!.abbreviation = self.abbreviation // @TODO: generate a new abbreviation
            project!.alive = self.alive
            project!.colour = self.colour.toStored()
            project!.company = self.company
            project!.lastUpdate = Date()
            project!.name = name
            project!.jobs = NSSet(array: self.jobs)
        } else {
            CoreDataProjects(moc: self.state.moc).create(
                name: self.name,
                abbreviation: self.abbreviation,
                colour: self.colour.toStored(),
                created: self.createdDate,
                pid: self.pid,
                company: self.company,
                jobs: NSSet(array: self.jobs),
                saveByDefault: false
            )
        }
        
        isSaveAlertPresented.toggle()
        PersistenceController.shared.save()
    }
    
    /// Soft delete a Project
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        self.alive = false
        if self.project != nil {
            self.project!.alive = self.alive
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
