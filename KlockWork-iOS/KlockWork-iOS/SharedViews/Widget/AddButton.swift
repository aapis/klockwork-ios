//
//  AddButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

struct AddButton: View {
    typealias Entity = PageConfiguration.EntityType
    @EnvironmentObject private var state: AppState

    var body: some View {
        NavigationStack {
            Menu("", systemImage: "plus") {
                NavigationLink {
                    TaskDetail()
                } label: {
                    Text(Entity.tasks.enSingular)
                    Entity.tasks.icon
                }

                NavigationLink {
                    NoteDetail.Sheet()
                } label: {
                    Text(Entity.notes.enSingular)
                    Entity.notes.icon
                }

                NavigationLink {
                    PersonDetail()
                } label: {
                    Text(Entity.people.enSingular)
                    Entity.people.icon
                }

                NavigationLink {
                    CompanyDetail()
                } label: {
                    Text(Entity.companies.enSingular)
                    Entity.companies.icon
                }

                NavigationLink {
                    ProjectDetail()
                } label: {
                    Text(Entity.projects.enSingular)
                    Entity.projects.icon
                }

                NavigationLink {
                    JobDetail()
                } label: {
                    Text(Entity.jobs.enSingular)
                    Entity.jobs.icon
                }
            }
        }
        .font(.title2)
    }
}
