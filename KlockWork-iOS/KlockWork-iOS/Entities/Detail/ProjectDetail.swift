//
//  ProjectDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct ProjectDetail: View {
    public let project: Project

    @State private var abbreviation: String = ""
    @State private var alive: Bool = false
    @State private var colour: Color = .clear
    @State private var company: Company?
    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    static public let defaultName: String = "A Really Good Project Name"

    private let page: PageConfiguration.AppPage = .create

    var body: some View {
        NavigationStack {
            VStack {
                List {
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
                        ColorPicker(selection: $colour) {
                            Text("Colour")
                                .foregroundStyle(.gray)
                        }
                        .listRowBackground(colour == .clear ? Theme.textBackground : colour)
                    }
                    .listRowBackground(Theme.textBackground)

                    if company != nil {
                        Section("Company") {
                            NavigationLink {
                                CompanyDetail(company: company!)
                                    .background(Theme.cPurple)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(company!.name!)
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }

                    Section("Name") {
                        TextField("Project name", text: $name, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Abbreviation") {
                        TextField("Project abbreviation", text: $abbreviation, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)
                }
            }
            .background(page.primaryColour)
            .onAppear(perform: actionOnAppear)
            .navigationTitle(project.name ?? "_PROJECT_NAME")
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
            .toolbar {
                Button("Save") {
                    self.actionOnSave()
                }
            }
        }
    }
}



extension ProjectDetail {
    /// Onload handler. Sets form field values
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let cDate = project.created {createdDate = cDate}
        if let uDate = project.lastUpdate {lastUpdate = uDate}
        if let nm = project.name {name = nm}
        if let ab = project.abbreviation {abbreviation = ab}
        if let co = project.colour {colour = Color.fromStored(co)}
        if let comp = project.company {company = comp}
        alive = project.alive
    }
    
    /// Fired when the save button is tapped in the toolbar. Saves project object
    /// - Returns: Void
    private func actionOnSave() -> Void {
        project.abbreviation = abbreviation
        project.alive = alive
        project.colour = colour.toStored()
        project.company = project.company
        project.lastUpdate = Date()
        project.name = name

        PersistenceController.shared.save()
    }
}


