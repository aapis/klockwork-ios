//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records
    @State private var jobs: [Job] = []
    @State private var isSheetPresented: Bool = false
    @FocusState private var textFieldActive: Bool
    private let page: PageConfiguration.AppPage = .today

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if !inSheet {
                    Header(page: self.page)
                }

                ZStack(alignment: .bottomLeading) {
                    Tabs(inSheet: inSheet, job: $job, selected: $selected)
                    if !inSheet {
                        PageActionBar.Today(job: $job, isSheetPresented: $isSheetPresented)
                        if job != nil {
                            LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                                .frame(height: 50)
                                .opacity(0.1)
                        }
                    }
                }

                if !inSheet {
                    if selected == .records {
                        Editor(job: $job, entityType: $selected, focused: _textFieldActive)
                    }

                    Spacer().frame(height: 1)
                }
            }
            .background(page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: self.job) {self.actionOnJobChange()}
        }
    }
}

extension Today {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = Date()
        public let page: PageConfiguration.AppPage

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(Calendar.autoupdatingCurrent.isDateInToday(date) ? "Today" : date.formatted(date: .abbreviated, time: .omitted))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.leading, .top, .bottom])
                        .overlay {
                            DatePicker(
                                "Date picker",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .contentShape(Rectangle())
                            .opacity(0.011)
                        }
                    Image(systemName: "chevron.right")

                    if self.state.isToday() {
                        Spacer()
                        LargeDateIndicator(page: self.page)
                    }
                }
                Spacer()
            }
            .onAppear(perform: {
                self.date = self.state.date
            })
            .onChange(of: self.date) {
                if self.state.date != self.date {
                    self.state.date = self.date
                }
            }
        }
    }

    struct Editor: View {
        @EnvironmentObject private var state: AppState
        @Binding public var job: Job?
        @Binding public var entityType: EntityType
        @FocusState public var focused: Bool
        @State private var text: String = ""

        var body: some View {
            if job != nil {
                QueryField(
                    prompt: "What are you working on?",
                    onSubmit: self.actionOnSubmit,
                    text: $text
                )
                .focused($focused)
            }
        }
    }
}

extension Today {
    /// Handler for callback when self.job changes value
    /// - Returns: Void
    private func actionOnJobChange() -> Void {
        if self.job != nil {
            self.textFieldActive = true
        }
    }
}

extension Today.Editor {
    /// Form action
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
            if let job = self.job {
                CoreDataRecords(moc: self.state.moc).createWithJob(
                    job: job,
                    date: Date(),
                    text: text
                )
                text = ""
            }
        }
    }
}
