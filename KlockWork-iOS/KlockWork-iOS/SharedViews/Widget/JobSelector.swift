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
                                .lineLimit(1)
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
            @State public var isSheetPresented: Bool = false
            @State private var searchText: String = ""
            @FetchRequest private var items: FetchedResults<Job>
            @FetchRequest private var recentItems: FetchedResults<Job>
            @Binding public var job: Job?

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ZStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 0) {
                        if items.count > 0 {
                            VStack(alignment: .leading, spacing: 0) {
                                if !self.searchText.isEmpty {
                                    UI.FilteredList(items: self.items, text: self.$searchText)
                                } else {
                                    List {
                                        Section {
                                            ForEach(self.recentItems, id: \.objectID) { jerb in
                                                Row(job: jerb, callback: { job in
                                                    self.job = job
                                                    self.state.job = job
                                                    dismiss()
                                                })
                                                .listRowInsets(.none)
                                                .listRowSpacing(.none)
                                                .listRowSeparator(.hidden)
                                            }
                                        } header: {
                                            Text("Recent (\(self.recentItems.count))")
                                        }
                                        .listSectionSpacing(0)
                                        Section {
                                            ForEach(self.items, id: \.objectID) { jerb in
                                                Row(job: jerb, callback: { job in
                                                    self.job = job
                                                    self.state.job = job
                                                    dismiss()
                                                })
                                                .listRowInsets(.none)
                                                .listRowSpacing(.none)
                                                .listRowSeparator(.hidden)
                                            }
                                        } header: {
                                            Text("All (\(self.items.count))")
                                        }
                                        .listSectionSpacing(0)
                                    }
                                    .listStyle(.inset)
                                    .scrollContentBackground(.hidden)
                                }
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs found")
                        }
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 50)
                            .opacity(0.1)
                        SearchBar.Bar(placeholder: "Type to filter...", text: self.$searchText, sheetPresented: self.$isSheetPresented)
                            .padding()
                            .background(Theme.cPurple)
                            .border(width: 1, edges: [.top], color: self.searchText.count > 0 ? self.state.theme.tint : .gray)
                    }
                }
            }

            init(title: String? = "What are you working on?", job: Binding<Job?>) {
                self.title = title
                _job = job
                _items = CoreDataJob.fetchAll(sort: [NSSortDescriptor(keyPath: \Job.title, ascending: true)])
                _recentItems = CoreDataJob.fetchRecent(limit: 8)
            }
        }

        struct UI {
            struct FilteredList: View {
                typealias Row = Tabs.Content.Individual.SingleJobDetailedCustomButton
                @EnvironmentObject private var state: AppState
                @Environment(\.dismiss) private var dismiss
                public var items: FetchedResults<Job>
                @AppStorage("home.tabLocation") public var tabLocation: Int = 0
                @Binding public var text: String
                @State private var jobs: [Job] = []

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        List {
                            Section {
                                if self.jobs.count > 0 {
                                    ForEach(self.jobs) { job in
                                        Row(job: job, callback: { job in
                                            self.state.job = job
                                            dismiss()
                                        })
                                        .listRowInsets(.none)
                                        .listRowSpacing(.none)
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            } header: {
                                Text("\(self.jobs.count) result(s) for \"\(self.text)\"")
                                    .foregroundStyle(Theme.lightWhite)
                            }
                            .listSectionSpacing(0)
                        }
                        .listStyle(.inset)
                        .scrollContentBackground(.hidden)
                    }
                    .onAppear(perform: self.actionOnChangeInput)
                    .onChange(of: self.text) {
                        self.actionOnChangeInput()
                    }
                }
                
                /// Fires when self.text changes
                /// - Returns: Void
                private func actionOnChangeInput() -> Void {
                    self.jobs = items.filter {
                        $0.titleOrId().lowercased().contains(self.text.lowercased()) ||
                        ($0.overview ?? "").lowercased().contains(self.text.lowercased())
                    }
                    .sorted(by: {$0.titleOrId() < $1.titleOrId()})
                }
            }
        }
    }
}
