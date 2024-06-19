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
    public var page: PageConfiguration.AppPage = .create
    @State private var alive: Bool = false
    @State private var colour: Color = .clear
    @State private var company: Company? = nil
    @State private var created: Date = Date()
    @State private var jid: Double = 0.0
    @State private var lastUpdate: Date = Date()
    @State private var overview: String = ""
    @State private var shredable: Bool = false
    @State private var title: String = ""
    @State private var url: String = "https://"
    @State private var project: Project? = nil
    static public let defaultTitle: String = "Descriptive job title"

    var body: some View {
        VStack {
            List {
                Section("Title") {
                    TextField("Title", text: $title)
                }
                .listRowBackground(Theme.textBackground)

                Section("URL") {
                    TextField("URL", text: $url)
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
                            } label: {
                                Text(company.name!)
                            }
                            .listRowBackground(Theme.textBackground)
                        }
                    }

                    Section("Project") {
                        NavigationLink {
                            ProjectDetail(project: project)
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
        .navigationTitle(self.jid == 0.0 ? "New Job" : job.title != nil ? job.title!.capitalized : "Job #\(job.jid.string)")
        .background(page.primaryColour)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
    }
    
    /// Default initializer
    /// - Parameter job: Job
    init(job: Job? = nil) {
        if job == nil {
            self.job = DefaultObjects.job
        } else {
            self.job = job!
        }
    }
}

extension JobDetail {
    /// Onload handler. Sets state variables
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.alive = job.alive
        self.colour = job.colour_from_stored()
        if let cDate = job.created {
            self.created = cDate
        }
        self.jid = job.jid
        self.lastUpdate = Date()
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
            self.url = link.absoluteString
        }
    }
}

extension JobDetail {
    struct Sheet: View {
        public var job: Job? = nil
        public var page: PageConfiguration.AppPage = .create
        public var standalone: Bool = false
        @Binding public var isPresented: Bool

        var body: some View {
            JobDetail(job: self.job)
            .toolbar {
                if self.standalone {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            self.isPresented.toggle()
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        self.actionOnSave()
                        self.isPresented.toggle()
                    }
                }
            }
        }
    }
}

extension JobDetail.Sheet {
    /// Save handler, fires when the Save button is tapped in navTopBar. Relies on other methods to modify self.job for this to work
    /// - Returns: Void
    private func actionOnSave() -> Void {

//        print("DERPO job=\(self.job!.jid.string)")
//        PersistenceController.shared.save()
    }
}
