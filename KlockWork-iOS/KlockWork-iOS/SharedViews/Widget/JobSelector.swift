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
            @Binding public var job: Job?
            @Binding public var isJobSelectorPresented: Bool

            var body: some View {
                Section("Job") {
                    Button {
                        isJobSelectorPresented.toggle()
                    } label: {
                        if self.job == nil {
                            Text("Select...")
                        } else {
                            Text(self.job!.title ?? self.job!.jid.string)
                                .foregroundStyle(self.job!.backgroundColor.isBright() ? Theme.base : .white)
                        }
                    }
                }
                .listRowBackground(self.job == nil ? Theme.textBackground : Color.fromStored(self.job!.colour ?? Theme.rowColourAsDouble))
            }
        }

        // @TODO: implement a Hierarchical selector, where jobs are grouped with their companies and projects

        /// Allows selection of multiple jobs from the list
        struct Multi: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButtonTwoState

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
                        .listRowBackground(Theme.textBackground)
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
                        .listRowBackground(Theme.textBackground)
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
            typealias Row = Tabs.Content.Individual.SingleJobCustomButton
            
            public var title: String?
            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var showing: Bool
            @Binding public var job: Job?

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(self.title!)
                                .font(.title2)
                            Spacer()
                            Button {
                                showing.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding()

                        if items.count > 0 {
                            ForEach(items, id: \.objectID) { jerb in
                                Row(job: jerb, callback: { job in
                                    self.job = job
                                    self.showing.toggle()
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs found")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }

            init(title: String? = "What are you working on now?", showing: Binding<Bool>, job: Binding<Job?>) {
                self.title = title
                _showing = showing
                _job = job
                _items = CoreDataJob.fetchAll()
            }
        }
    }
}
