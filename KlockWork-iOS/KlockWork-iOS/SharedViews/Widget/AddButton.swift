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
    public var plain: Bool = true

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
        .tint(self.state.job?.backgroundColor ?? self.state.theme.tint)
        .font(.title2)
        .bold()
        .padding(10)
        .padding(.leading, 8)
        .background(
            ZStack {
                if self.plain {
                    self.state.job?.backgroundColor ?? Theme.cPurple
                } else {
                    self.state.job?.backgroundColor ?? Theme.cPurple
                    LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .blendMode(.softLight)
                }
            }
        )
        .clipShape(
            Circle()
        )
    }
}
