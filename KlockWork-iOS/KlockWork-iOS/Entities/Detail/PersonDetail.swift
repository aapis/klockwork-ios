//
//  PersonDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct PersonDetail: View {
    public let person: Person

    @State private var createdDate: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var name: String = ""
    @State private var title: String = ""
    @State private var company: Company? = nil

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Settings") {
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
                        TextField("Person name", text: $name, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Title") {
                        TextField("Person's title", text: $title, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .listStyle(.grouped)
            }
            .onAppear(perform: actionOnAppear)
            .navigationTitle("Editing: Person")
            .toolbar {
                Button("Save") {

                }
            }
        }
    }
}

extension PersonDetail {
    private func actionOnAppear() -> Void {
        if let cDate = person.created {createdDate = cDate}
        if let uDate = person.lastUpdate {lastUpdate = uDate}
        if let nm = person.name {name = nm}
        if let ti = person.title {title = ti}
        if let co = person.company {company = co}
    }
}
