//
//  Tabs.Content.Posts.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2025-11-16.
//

import SwiftUI

extension Tabs.Content {
    struct Posts {
        struct Records: View {
            typealias EntityType = PageConfiguration.EntityType

            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            public var pageTitle: String = "Posts"
            @FetchRequest private var items: FetchedResults<LogRecord>
            @Binding public var job: Job?
            private var date: Date
            @State private var isPresented: Bool = false
            @State private var selected: EntityType = .records
            @FocusState private var textFieldActive: Bool

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    TaskForecast(callback: {}, daysToShow: -15)
                    MiniTitleBarCustom(title: self.pageTitle.uppercased())
                        .border(width: 1, edges: [.bottom], color: self.state.theme.tint)
                    ZStack(alignment: .bottom) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 24) {
                                if self.items.count > 0 {
                                    ForEach(self.items) { record in
                                        Individual.Post(record: record)
                                    }
                                } else {
                                    StatusMessage.Warning(message: "No posts found for \(self.state.date.formatted(date: .abbreviated, time: .omitted))")
                                        .padding(8)
                                }
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(self.items.count == 0 ? Theme.textBackground : .clear)

                        PageActionBar.Today(job: $job, isPresented: $isPresented)
                            .padding(.bottom, self.job != nil ? 50 : 0)

                        if self.job != nil {
                            LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                                .frame(height: 50)
                                .opacity(0.1)
                            Today.Editor(prompt: "What's on your mind?", job: $job, entityType: $selected, focused: _textFieldActive)
                                .background(Theme.cPurple)
                        }
                    }
                }
                .navigationTitle(self.pageTitle)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
                .onChange(of: self.job, self.actionOnChangeJob)
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool, pageTitle: String = "Posts") {
                _job = job
                self.date = date
                self.inSheet = inSheet
                self.pageTitle = pageTitle
                _items = CoreDataRecords.fetch(for: self.date)
            }
            
            /// Fires after job is changed
            /// - Returns: Void
            private func actionOnChangeJob() -> Void {
                if self.job != nil {
                    self.textFieldActive = true
                }
            }
        }
    }
}
