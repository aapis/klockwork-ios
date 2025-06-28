//
//  JobSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-08.
//

import SwiftUI

extension Widget {
    struct JobSelector {
        /// Selector view
        struct FormField: View {
            typealias C = Tabs.Content
            typealias SelectedJob = C.Individual.SingleJobDetailedCustomButton

            @Binding public var job: Job?
            @Binding public var isJobSelectorPresented: Bool

            var body: some View {
                Button {
                    job = nil
                    isJobSelectorPresented.toggle()
                } label: {
                    if self.job == nil {
                        Text("Select Job...")
                    } else {
                        SelectedJob(job: job)
                    }
                }
                .listRowBackground(
                    C.Common.TypedListRowBackground(colour: (self.job?.backgroundColor ?? Theme.rowColour), type: .jobs)
                )
            }
        }

        // @TODO: implement a Hierarchical selector, where jobs are grouped with their companies and projects

        /// Allows selection of multiple jobs from the list
        struct Multi: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButtonTwoState

            @EnvironmentObject private var state: AppState
            public let title: String
            public let filter: ResultsFilter
            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var showing: Bool
            @Binding private var selectedJobs: [Job]

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(self.title)
                                .font(.title2)
                            Spacer()
                            Button {
                                showing.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding()

                        HStack(alignment: .center, spacing: 5) {
                            Spacer()
                            Text("Selected: \(selectedJobs.count)")
                        }
                        .padding()

                        if items.count > 0 {
                            ForEach(items, id: \.objectID) { jerb in
                                HStack(alignment: .center, spacing: 0) {
                                    Row(job: jerb, alreadySelected: self.jobIsSelected(jerb), callback: { job, action in
                                        if action == .add {
                                            selectedJobs.append(job)
                                        } else if action == .remove {
                                            if let index = selectedJobs.firstIndex(where: {$0 == job}) {
                                                selectedJobs.remove(at: index)
                                            }
                                        }
                                    })
                                }
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs found")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }

            init(title: String, filter: ResultsFilter, showing: Binding<Bool>, selectedJobs: Binding<[Job]>) {
                self.title = title
                self.filter = filter
                _showing = showing
                _selectedJobs = selectedJobs

                switch self.filter {
                case .unowned:
                    _items = CoreDataJob.fetchUnowned()
                case .recent:
                    _items = CoreDataJob.fetchRecent()
                default:
                    _items = CoreDataJob.fetchAll()
                }
            }

            /// Determine if a given job is already within the selectedJobs list
            /// - Parameter job: Job
            /// - Returns: Bool
            private func jobIsSelected(_ job: Job) -> Bool {
                return selectedJobs.firstIndex(where: {$0 == job}) != nil
            }

            /// Selector for interacting with the multi-select field
            struct FormField: View {
                typealias Row = Tabs.Content.Individual.SingleJobCustomButtonMultiSelectForm

                @Binding public var jobs: [Job]
                @Binding public var isJobSelectorPresented: Bool
                public var orientation: FieldOrientation = .vertical

                var body: some View {
                    if jobs.filter({$0.alive == true}).isEmpty {
                        Button {
                            self.isJobSelectorPresented.toggle()
                        } label: {
                            HStack {
                                Text("Select...")
                                Spacer()
                            }
                        }
                        .listRowBackground(
                            Tabs.Content.Common.TypedListRowBackground(colour: Theme.rowColour, type: .jobs)
                        )
                    } else {
                        ForEach(jobs.filter({$0.alive == true}), id: \.objectID) { entity in
                            Row(job: entity, alreadySelected: self.isSelected(entity), callback: { job, action in
                                if action == .add {
                                    self.jobs.append(job)
                                } else if action == .remove {
                                    if let index = self.jobs.firstIndex(where: {$0 == job}) {
                                        self.jobs.remove(at: index)
                                    }
                                }
                            })
                        }

                        Button {
                            self.isJobSelectorPresented.toggle()
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add")
                            }
                        }
                        .listRowBackground(
                            Tabs.Content.Common.TypedListRowBackground(colour: Theme.rowColour, type: .jobs)
                        )
                    }
                }

                /// Determine if a given project has been selected
                /// - Parameter project: Project
                /// - Returns: Bool
                private func isSelected(_ job: Job) -> Bool {
                    return self.jobs.firstIndex(where: {$0 == job}) != nil
                }
            }
        }

        /// Allows selection of a single job from the list
        struct Single: View {
            typealias Row = Tabs.Content.Individual.SingleJobDetailedCustomButton

            @EnvironmentObject private var state: AppState
            @Environment(\.dismiss) private var dismiss
            public var title: String?
            @FetchRequest private var items: FetchedResults<Job>
            @FetchRequest private var recentItems: FetchedResults<Job>
            @Binding public var job: Job?

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Text(self.title!)
                            .font(.title2)
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    .padding()

                    if items.count > 0 {
                        // @TODO: this should be a NEW inline search widget
//                        SearchBar(placeholder: "Find", items: self.items, type: .jobs)
//                            .padding()
                        List {
                            HStack {
                                Spacer()
                                SectionTitle(label: "Recent (\(self.recentItems.count))")
                            }
                            ForEach(self.recentItems, id: \.objectID) { jerb in
                                Row(job: jerb, callback: { job in
                                    self.job = job
                                    self.state.job = job
                                    dismiss()
                                })
                                .background(
                                    Tabs.Content.Common.TypedListRowBackground(colour: jerb.backgroundColor, type: .jobs)
                                )
                            }
                            HStack {
                                Spacer()
                                SectionTitle(label: "All (\(self.items.count))")
                            }
                            ForEach(self.items, id: \.objectID) { jerb in
                                Row(job: jerb, callback: { job in
                                    self.job = job
                                    self.state.job = job
                                    dismiss()
                                })
                                .background(
                                    Tabs.Content.Common.TypedListRowBackground(colour: jerb.backgroundColor, type: .jobs)
                                )
                            }
                        }
                        .listStyle(.plain)
                        .listRowInsets(.none)
                        .listRowSpacing(.none)
                        .listRowSeparator(.hidden)
                        .listSectionSpacing(0)
                        .scrollContentBackground(.hidden)
                    } else {
                        StatusMessage.Warning(message: "No jobs found")
                    }
                }
            }

            init(title: String? = "What are you working on now?", job: Binding<Job?>) {
                self.title = title
                _job = job
                _items = CoreDataJob.fetchAll()
                _recentItems = CoreDataJob.fetchRecent()
            }
        }
    }
}
