//
//  Planning.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

extension PageActionBar {
    struct Planning: View {
        @EnvironmentObject private var state: AppState
        @Binding public var selectedJobs: [Job]
        @Binding public var selectedTasks: [LogTask]
        @Binding public var selectedNotes: [Note]
        @Binding public var selectedProjects: [Project]
        @Binding public var selectedCompanies: [Company]
        @Binding public var isPresented: Bool
        @State private var plan: Plan? = nil
        @State private var id: UUID = UUID()
        private let page: PageConfiguration.AppPage = .planning

        var body: some View {
            PageActionBar(
                groupView: AnyView(Group),
                sheetView: AnyView(
                    Widget.JobSelector.Multi(
                        title: "What's on your plate today?",
                        filter: .owned,
                        showing: $isPresented,
                        selectedJobs: $selectedJobs
                    )
                    .presentationBackground(self.page.primaryColour)
                ),
                isPresented: $isPresented
            )
            .id(self.id)
            .onChange(of: self.selectedJobs) { // sheet/group view are essentially static unless we manually refresh them, @TODO: fix this
                self.id = UUID()
            }
        }

        @ViewBuilder var Group: some View {
            HStack(alignment: .center, spacing: 10) {
                AddButton
                Spacer()

                if self.selectedJobs.count > 0 {
                    State
                }
            }
            .background(Theme.cOrange.opacity(0.5))
        }

        @ViewBuilder var AddButton: some View {
            Button {
                self.isPresented.toggle()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "hammer.circle.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)

                    if self.selectedJobs.count == 0 {
                        Text("Choose jobs to get started")
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
            }
            .padding(8)
        }

        @ViewBuilder var State: some View {
            HStack(spacing: 0) {
                Button {
                    self.store()
                } label: {
                    Text("Save")
                }
                .fontWeight(.bold)
                .padding(8)
                .background(.green.opacity(0.5))
                .background(.gray)

                Button {
                    self.destroyPlan()
                } label: {
                    Text("Reset")
                }
                .padding(8)
                .background(.black.opacity(0.1))
                .background(.gray)
            }
            .clipShape(.capsule(style: .continuous))
            .foregroundStyle(.white)
            .padding([.trailing], 8)
        }
    }
}

extension PageActionBar.Planning {
    /// Create a new Plan for today
    /// - Returns: Void
    private func store() -> Void {
        CoreDataPlan(moc: self.state.moc).create(
            date: Date(),
            jobs: Set(self.selectedJobs),
            tasks: Set(self.selectedTasks),
            notes: Set(self.selectedNotes),
            projects: Set(self.selectedProjects),
            companies: Set(self.selectedCompanies)
        )
    }

    /// Destroy and recreate today's plan
    /// - Returns: Void
    private func destroyPlan() -> Void {
        self.selectedJobs = []
        self.selectedNotes = []
        self.selectedTasks = []
        self.selectedProjects = []
        self.selectedCompanies = []

        if self.plan != nil {
            // Delete the old plan
            do {
                try self.plan!.validateForDelete()
                self.state.moc.delete(self.plan!)
            } catch {
                print("[error] Planning.PlanTabs Unable to delete old session due to error \(error)")
            }

            // Create a new empty plan
            self.plan = CoreDataPlan(moc: self.state.moc).createAndReturn(
                date: Date(),
                jobs: Set(),
                tasks: Set(),
                notes: Set(),
                projects: Set(),
                companies: Set()
            )
        }

        self.plan = nil
    }
}
