//
//  CompanyDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct CompanyDetail: View {
    public let company: Company
    
    @State private var projects: [Project] = []
    @State private var isDefault: Bool = false
    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var abbreviation: String = ""
    @State private var hidden: Bool = false
    @State private var colour: Color = .clear
    private let page: PageConfiguration.AppPage = .create
    static public let defaultName: String = "Initech Inc"

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Settings") {
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
                        ColorPicker(selection: $colour) {
                            Text("Colour")
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Projects") {
                        if projects.count > 0 {
                            ForEach(projects) { project in
                                NavigationLink {
                                    ProjectDetail(project: project)
                                        .background(Theme.cPurple)
                                        .scrollContentBackground(.hidden)
                                } label: {
                                    Text(project.name!)
                                }
                            }
                        } else {
                            Text("No projects found")
                                .foregroundStyle(.gray)
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Name") {
                        TextField("Company name", text: $name, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Abbreviation") {
                        TextField("Company abbreviation", text: $abbreviation, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .listStyle(.grouped)
            }
            .background(page.primaryColour)
            .onAppear(perform: actionOnAppear)
            .navigationTitle("\(self.name) (\(self.abbreviation))")
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollContentBackground(.hidden)
            .toolbar {
                Button("Save") {
                    
                }
            }
        }
    }
}

extension CompanyDetail {
    private func actionOnAppear() -> Void {
        projects = company.projects?.allObjects as! [Project]

        if let cDate = company.createdDate {createdDate = cDate}
        if let uDate = company.lastUpdate {lastUpdate = uDate}
        if let nm = company.name {name = nm}
        if let ab = company.abbreviation {abbreviation = ab}
        if let co = company.colour {colour = Color.fromStored(co)}
    }
}
