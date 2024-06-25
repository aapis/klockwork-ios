//
//  JobDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var job: Job?
    public var page: PageConfiguration.AppPage = .create
    @State private var alive: Bool = true
    @State private var colour: Color = .clear
    @State private var company: Company? = nil
    @State private var created: Date = Date()
    @State private var jid: String = ""
    @State private var lastUpdate: Date = Date()
    @State private var overview: String = ""
    @State private var shredable: Bool = false
    @State private var title: String = ""
    @State private var url: String = "https://"
    @State private var project: Project? = nil
    @State private var isCompanySelectorPresented: Bool = false
    @State private var isProjectSelectorPresented: Bool = false
    @State private var isSaveAlertPresented: Bool = false
    static public let defaultTitle: String = "Descriptive job title"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        if !title.isEmpty {
                            Text("Title")
                                .foregroundStyle(.gray)
                        }
                        TextField("Title", text: $title)
                        Spacer()
                    }

                    HStack {
                        if !jid.isEmpty {
                            Text("JID")
                                .foregroundStyle(.gray)
                        }
                        TextField("Job ID", text: $jid)
                        Spacer()
                    }

                    HStack {
                        if !url.isEmpty {
                            Text("URL")
                                .foregroundStyle(.gray)
                        }
                        TextField("URL", text: $url)
                        Spacer()
                    }

                    Widget.CompanySelector.FormField(
                        company: $company,
                        isCompanySelectorPresented: $isCompanySelectorPresented,
                        orientation: .horizontal
                    )

                    // Evaluating self.company here seems to trigger a view refresh that we need to make this combo selector thing work
                    if self.company != nil {
                        Widget.ProjectSelector.FormField(
                            project: $project,
                            company: $company,
                            isProjectSelectorPresented: $isProjectSelectorPresented,
                            orientation: .horizontal
                        )
                    }

                    ColorPicker(selection: $colour) {
                        Text("Colour")
                            .foregroundStyle(.gray)
                    }
                    .listRowBackground(colour == .clear ? Theme.textBackground : colour)
                }
                .listRowBackground(Theme.textBackground)

                Section("Overview") {
                    TextEditor(text: $overview).lineLimit(3...)
                }
                .listRowBackground(Theme.textBackground)

                Section("Settings") {
                    Toggle("Published", isOn: $alive)
                    DatePicker(
                        "Created",
                        selection: $created,
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
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle("Job")
        .background(page.primaryColour)
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
                    Text("\"\(self.title)\" saved")
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
        .sheet(isPresented: $isProjectSelectorPresented) {
            if let corpo = self.company {
                Widget.ProjectSelector.Single(
                    showing: $isProjectSelectorPresented,
                    entity: $project,
                    company: corpo
                )
                .presentationBackground(self.page.primaryColour)
            } else {
                ErrorView.MissingCompany(isPresented: $isProjectSelectorPresented)
            }
        }
    }
}

extension JobDetail {
    /// Onload handler. Sets state variables
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.job != nil {
            self.alive = self.job!.alive
            self.colour = self.job!.colour_from_stored()
            if let cDate = self.job!.created {
                self.created = cDate
            }
            self.jid = self.job!.jid.string
            if let uDate = self.job!.lastUpdate {
                self.lastUpdate = uDate
            }
            self.overview = self.job!.overview ?? ""
            self.shredable = self.job!.shredable
            self.title  = self.job!.title ?? ""

            if let project = self.job!.project {
                self.project = project
                if let company = project.company {
                    self.company = company
                }
            }

            if let link = self.job!.uri {
                self.url = link.absoluteString
            }
        }
    }
    
    /// Callback that fires when the save button is tapped
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.job != nil {
            self.job!.alive = self.alive
            self.job!.colour = self.colour == .clear ? Color.randomStorable() : self.colour.toStored()
            self.job!.jid = Double(self.jid) ?? 0.0
            self.job!.lastUpdate = Date()
            self.job!.overview = self.overview
            self.job!.shredable = self.shredable
            self.job!.title = self.title
            if let project = self.project  {
                self.job!.project = project
            }
            self.job!.uri = URL(string: self.url)
        } else {
            CoreDataJob(moc: self.state.moc).create(
                alive: self.alive,
                colour: self.colour == .clear ? Color.randomStorable() : self.colour.toStored(),
                jid: Double(self.jid) ?? 0.0,
                overview: self.overview,
                shredable: self.shredable,
                title: self.title,
                uri: URL(string: self.url)!.absoluteString,
                project: self.project == nil ? DefaultObjects.project : self.project,
                saveByDefault: false
            )
        }
        
        isSaveAlertPresented.toggle()
        PersistenceController.shared.save()
    }
}
