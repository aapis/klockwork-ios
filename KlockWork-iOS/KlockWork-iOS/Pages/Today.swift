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
    @State private var isPresented: Bool = false
    @State private var path = NavigationPath()
    @State private var text: String = "" // @TODO: remove code that requires this
    @AppStorage("today.viewMode") private var viewMode: Int = 0
    @FocusState private var textFieldActive: Bool
    private let page: PageConfiguration.AppPage = .today
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if !inSheet {
                    Header(page: self.page, path: $path)
                }
                Divider().background(.white).frame(height: 1)
                
                switch(self.viewMode) {
                case 1:
                    Tabs.Content.List.HierarchyExplorer(inSheet: false)
                case 2:
                    Widget.ActivityCalendar(searchTerm: $text, showActivity: false)
                case 0:
                    main
                default:
                    main
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

    var main: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Tabs(inSheet: inSheet, job: $job, selected: $selected)
                if !inSheet {
                    // @TODO: each one of these could include the create entity button, but for now it's only relevant to the Records tab
                    if [.records, .terms].contains(where: {$0 == selected}) {
                        PageActionBar.Today(job: $job, isPresented: $isPresented)
                    }

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
    }
}

struct PageTitle: View {
    public let text: String

    var body: some View {
        Text(self.text).font(.title2).padding([.leading], 10).bold()
    }
}

extension Today {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = DateHelper.startOfDay()
        @State private var isCreateSheetPresented: Bool = false
        @State private var isCalendarPresented: Bool = false
        @AppStorage("today.viewMode") private var viewMode: Int = 0
        public let page: PageConfiguration.AppPage
        @Binding public var path: NavigationPath

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.2)
                        .blendMode(.softLight)
                        .frame(height: 45)

                    HStack(spacing: 8) {
                        Button {
                            self.isCalendarPresented.toggle()
                        } label: {
                            PageTitle(text: DateHelper.todayShort(self.state.date, format: "MMMM dd"))
                        }
                        .buttonStyle(.plain)
                        .opacity(self.viewMode == 0 || self.viewMode == 1 ? 1 : 0.5)

                        Spacer()
                        CreateEntitiesButton(isViewModeSelectorVisible: true, page: self.page)
                    }
                }
            }
            .onAppear(perform: {
                self.date = self.state.date
            })
            .onChange(of: self.date) {
                if self.state.date != self.date {
                    self.state.date = DateHelper.startOfDay(self.date)
                }
            }
            .onChange(of: self.isCalendarPresented) {
                if self.isCalendarPresented {
                    self.viewMode = 2
                } else {
                    self.viewMode = 0
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

extension Today.Header {
    /// Callback that fires when the CreateSheet disappears
    /// - Returns: Void
    private func actionOnCreateSheetDismissed() -> Void {
        DefaultObjects.deleteDefaultJobs()
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

struct DatePickerDateAwareTitle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Label(configuration)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.leading, .top, .bottom])
        }
    }
}
