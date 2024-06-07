//
//  ProjectDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct ProjectDetail: View {
    public let project: Project

    @State private var alive: Bool = false
    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var abbreviation: String = ""
    @State private var colour: Color = .clear
    @State private var company: Company?

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
                        }
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
                .listStyle(.grouped)
            }
            .onAppear(perform: actionOnAppear)
            .navigationTitle(project.name ?? "_PROJECT_NAME")
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                Button("Save") {

                }
            }
        }
    }
}

extension ProjectDetail {
    private func actionOnAppear() -> Void {
        if let cDate = project.created {createdDate = cDate}
        if let uDate = project.lastUpdate {lastUpdate = uDate}
        if let nm = project.name {name = nm}
        if let ab = project.abbreviation {abbreviation = ab}
        if let co = project.colour {colour = Color.fromStored(co)}
        if let comp = project.company {company = comp}
        alive = project.alive
    }
}
