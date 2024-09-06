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
        @State private var isResetAlertPresented: Bool = false
        private let page: PageConfiguration.AppPage = .planning

        var body: some View {
            PageActionBar(
                page: self.page,
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
            .alert("Reset plan. Are you sure?", isPresented: $isResetAlertPresented) {
                Button("Yes", role: .destructive) {
                    self.destroyPlan()
                }
                Button("No", role: .cancel) {}
            }
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
            .background(
                ZStack {
                    Theme.cOrange
                    Color.white.blendMode(.softLight)
                }
            )
        }

        @ViewBuilder var AddButton: some View {
            Button {
                self.isPresented.toggle()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "hammer.circle.fill")
                        .font(.largeTitle)

                    if self.selectedJobs.count == 0 {
                        Text("Choose jobs to get started")
                            .multilineTextAlignment(.leading)
                    } else {
                        Text("Add or remove jobs")
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
            }
            .fontWeight(.bold)
            .padding(8)
        }

        @ViewBuilder var State: some View {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    self.store()
                } label: {
                    Image(systemName: "circle.hexagongrid.circle.fill")
                }
                .help("Save plan")
                .clipShape(Circle())

                if self.plan != nil {
                    Button {
                        self.isResetAlertPresented.toggle()
                    } label: {
                        Image(systemName: "hexagon.fill")
                            .font(.largeTitle)
                    }
                    .help("Clear plan and start over")
                    .foregroundStyle(Theme.cOrange)
                    .clipShape(Circle())
                }
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding([.trailing], 8)
        }
    }
}

extension PageActionBar.Planning {
    /// Create a new Plan for today
    /// - Returns: Void
    private func store() -> Void {
        self.state.plan = CoreDataPlan(moc: self.state.moc).createAndReturn(
            date: Date(),
            jobs: Set(self.selectedJobs),
            tasks: Set(self.selectedTasks),
            notes: Set(self.selectedNotes),
            projects: Set(self.selectedProjects),
            companies: Set(self.selectedCompanies)
        )
        self.plan = self.state.plan
        self.id = UUID()
    }

    /// Destroy and recreate today's plan
    /// - Returns: Void
    private func destroyPlan() -> Void {
        self.selectedJobs = []
        self.selectedNotes = []
        self.selectedTasks = []
        self.selectedProjects = []
        self.selectedCompanies = []
        self.plan = nil
        self.state.plan = nil
        self.id = UUID()

        // Delete the old plans
        CoreDataPlan(moc: self.state.moc).deleteAll(for: self.state.date)
    }
}
