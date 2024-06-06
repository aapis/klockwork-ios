//
//  JobDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDetail: View {
    public let job: Job
    
    @State private var alive: Bool = false
    @State private var colour: Color = .clear
    @State private var created: Date = Date()
    @State private var jid: Double = 0.0
    @State private var lastUpdate: Date = Date()
    @State private var overview: String = ""
    @State private var shredable: Bool = false
    @State private var title: String = ""
    @State private var url: URL? = nil
    @State private var project: Project? = nil
    @State private var company: Company? = nil

    var body: some View {
        VStack {
            List {
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
                    ColorPicker(selection: $colour) {
                        Text("Colour")
                    }
                }
                .listRowBackground(Theme.textBackground)

                if let project = self.project {
                    if let company = self.company {
                        Section("Company") {
                            NavigationLink {
                                CompanyDetail(company: company)
                                    .background(Theme.cPurple)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(company.name!)
                            }
                            .listRowBackground(Theme.textBackground)
                        }
                    }

                    Section("Project") {
                        NavigationLink {
                            ProjectDetail(project: project)
                                .background(Theme.cPurple)
                                .scrollContentBackground(.hidden)
                        } label: {
                            Text(project.name!)
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
            }
            .listStyle(.grouped)
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(job.title != nil ? job.title!.capitalized : "Job #\(job.jid.string)")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            Button("Save") {

            }
        }
    }
}

extension JobDetail {
    private func actionOnAppear() -> Void {
        self.alive = job.alive
        self.colour = job.colour_from_stored()
        self.created = job.created ?? Date()
        self.jid = job.jid
        self.lastUpdate = job.lastUpdate ?? Date()
        self.overview = job.overview ?? ""
        self.shredable = job.shredable
        self.title  = job.title ?? ""

        if let project = job.project {
            self.project = project
            if let company = project.company {
                self.company = company
            }
        }

        if let link = job.uri {
            self.url = link
        }
    }
}
