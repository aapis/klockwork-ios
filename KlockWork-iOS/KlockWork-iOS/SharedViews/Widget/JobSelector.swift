//
//  JobSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-08.
//

import SwiftUI

extension Widget {
    struct JobSelector {
        /// Allows selection of multiple jobs from the list
        struct Multi: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButtonTwoState

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
                            Text("What's on your plate today?")
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
                            ForEach(items) { jerb in
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

            init(showing: Binding<Bool>, selectedJobs: Binding<[Job]>) {
                _showing = showing
                _selectedJobs = selectedJobs
                _items = CoreDataJob.fetchAll()
            }

            /// Determine if a given job is already within the selectedJobs list
            /// - Parameter job: Job
            /// - Returns: Bool
            private func jobIsSelected(_ job: Job) -> Bool {
                return selectedJobs.firstIndex(where: {$0 == job}) != nil
            }
        }

        /// Allows selection of a single job from the list
        struct Single: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButton

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
                            Text("What are you working on now?")
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
                            ForEach(items) { jerb in
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

            init(showing: Binding<Bool>, job: Binding<Job?>) {
                _showing = showing
                _job = job
                _items = CoreDataJob.fetchAll()
            }
        }
    }
}
