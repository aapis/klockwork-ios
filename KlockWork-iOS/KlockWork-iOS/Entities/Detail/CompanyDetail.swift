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

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Projects") {
                        if projects.count > 0 {
                            ForEach(projects) { project in
                                NavigationLink {
                                    ProjectDetail(project: project)
                                } label: {
                                    Text(project.name!.capitalized)
                                }
                            }
                        } else {
                            Text("No projects found")
                                .foregroundStyle(.gray)
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Settings") {
                        Toggle("Default company", isOn: $isDefault)


                        DatePicker(
                            "Created on",
                            selection: $createdDate,
                            displayedComponents: [.date]
                        )

                        DatePicker(
                            "Last updated",
                            selection: $lastUpdate,
                            displayedComponents: [.date]
                        )
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .listStyle(.grouped)
            }
            .onAppear(perform: actionOnAppear)
            .navigationTitle(company.name!.capitalized)
        }
    }
}

extension CompanyDetail {
    private func actionOnAppear() -> Void {
        projects = company.projects?.allObjects as! [Project]

        if let cDate = company.createdDate {
            createdDate = cDate
        }

        if let uDate = company.lastUpdate {
            lastUpdate = uDate
        }
    }
}
