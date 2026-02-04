//
//  Posts.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2025-11-16.
//


struct Posts {
        struct Records: View {
            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            public var pageTitle: String = "Posts"
            @FetchRequest private var items: FetchedResults<LogRecord>
            @Binding public var job: Job?
            private var date: Date

            var body: some View {
                SwiftUI.List {
                    if self.items.count > 0 {
                        ForEach(self.items) { record in
                            Individual.SingleRecordDetailedLink(record: record)
                        }
                    } else {
                        StatusMessage.Warning(message: "No posts found for \(self.state.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle(self.pageTitle)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool, pageTitle: String = "Posts") {
                _job = job
                self.date = date
                self.inSheet = inSheet
                self.pageTitle = pageTitle
                _items = CoreDataRecords.fetch(for: self.date)
            }
        }
    }