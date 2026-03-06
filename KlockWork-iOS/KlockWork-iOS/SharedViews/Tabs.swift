//
//  Tabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI
import CoreData

// @TODO: refactor into one that supports any PageConfiguration enum
struct Tabs: View {
    typealias EntityType = PageConfiguration.EntityType
    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @Binding public var job: Job?
    @Binding public var selected: EntityType
    public var content: AnyView? = nil
    public var buttons: AnyView? = nil
    public var title: AnyView? = nil
    public var mode: TabsViewMode = .read
    static public let animationDuration: Double = 0.2
    @AppStorage("home.tabLocation") public var tabLocation: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.mode == .read {
                Divider().background(.white).frame(height: 1)
            }
            // @TODO: only allowing top/bottom tabs to work on create mode for now don't @ me
            if self.mode == .create {
                switch self.tabLocation {
                case 1:
                    self.contentRow
                    self.miniTitleRow
                    self.buttonRow
                default:
                    self.buttonRow
                    self.miniTitleRow
                    self.contentRow
                }
            } else {
                self.buttonRow
                self.miniTitleRow
                self.contentRow
            }
        }
        .background(.clear)
    }

    @ViewBuilder private var miniTitleRow: some View {
        if title == nil {
            MiniTitleBar(selected: $selected)
                .border(width: 1, edges: [.bottom], color: self.state.theme.tint)
        } else {
            title
        }
    }

    @ViewBuilder private var contentRow: some View {
        if content == nil {
            switch self.mode {
            case .create:
                Tabs.TVMCreate(selected: self.$selected)
            case .read:
                Tabs.Content(inSheet: self.inSheet, job: self.$job, selected: self.$selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            case .update:
                Tabs.TVMUpdate()
            case .delete:
                Tabs.TVMDelete()
            case .dashboard:
                Tabs.TVMDashboard(selected: self.$selected)
            }
        } else {
            content
        }
    }

    @ViewBuilder private var buttonRow: some View {
        if buttons == nil {
            switch self.state.today.tableButtonMode {
            case .actions:
                HStack(alignment: .center, spacing: 8) {
                    Home.QuickCreateWidget.AddButton()
                        .frame(width: 50, height: 45)
                        .background(Theme.darkBtnColour)
                    ViewModeSelector()
                }
            case .items:
                Buttons(inSheet: inSheet, job: $job, selected: $selected, tabLocation: self.$tabLocation, mode: self.mode)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            }

        } else {
            buttons
        }
    }
}

extension Tabs {
    /// Callback that fires when a swipe event is triggered
    /// - Parameter swipe: Swipe
    /// - Returns: Void
    public func actionOnSwipe(_ swipe: Swipe) -> Void {
        let tabs = EntityType.allCases
        if var selectedIndex = (tabs.firstIndex(of: self.selected)) {
            if swipe == .left {
                if selectedIndex <= tabs.count - 2 {
                    selectedIndex += 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[0]
                }
            } else if swipe == .right {
                if selectedIndex > 0 && selectedIndex <= tabs.count {
                    selectedIndex -= 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[tabs.count - 1]
                }
            }
        }
    }
}

extension Tabs {
    enum TabsViewMode {
        case create, read, update, delete, dashboard
    }

    struct Buttons: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType
        @Binding public var tabLocation: Int
        public var mode: TabsViewMode
        @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(EntityType.allCases, id: \.self) { page in
                            Button {
                                selected = page
                            } label: {
                                (page == selected ? page.selectedIcon : page.icon)
                                    .frame(maxHeight: 20)
                                    .padding(14)
                                    .background(
                                        ZStack(alignment: .bottom) {
                                            (page == selected ? self.state.theme.tint : .clear)
                                            VStack {
                                                Spacer()
                                                LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                                                    .blendMode(.softLight)
                                                    .opacity(page == self.selected ? 1 : 0)
                                                    .frame(height: 15)
                                            }
                                        }
                                    )
                                    .foregroundStyle(
                                        .linearGradient(colors: [page == self.selected ? Theme.base : self.shouldUseWPImage ? Theme.lightWhite : .gray, page == self.selected ? Theme.cPurple : self.shouldUseWPImage ? Theme.lightWhite : .gray], startPoint: .top, endPoint: .bottom)
                                    )
                            }
                            .buttonStyle(.plain)
                            .clipShape(
                                .rect(
                                    bottomLeadingRadius: self.mode == .create && self.tabLocation == 1 ? 8 : 0,
                                    bottomTrailingRadius: self.mode == .create && self.tabLocation == 1 ? 8 : 0
                                )
                            )
                            .shadow(radius: page == selected ? 4 : 0)
                        }
                        Spacer()
                    }
                }
            }
            .background(
                ZStack(alignment: .top) {
                    VStack {
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .opacity(0.4)
                            .frame(height: 15)
                        Spacer()
                    }
                }
            )
        }
    }

    struct Content: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType

        var body: some View {
            switch self.selected {
            case .records:
                List.Records(job: $job, date: self.state.date, inSheet: self.inSheet)
            case .jobs:
                List.Jobs(job: $job, date: self.state.date, inSheet: self.inSheet)
            case .tasks:
                List.Tasks(date: self.state.date, inSheet: self.inSheet)
            case .notes:
                List.Notes(date: self.state.date, inSheet: self.inSheet)
            case .companies:
                List.Companies(date: self.state.date, inSheet: self.inSheet)
            case .people:
                List.People(date: self.state.date, inSheet: self.inSheet)
            case .projects:
                List.Projects(date: self.state.date, inSheet: self.inSheet)
            case .terms:
                if self.job != nil {
                    List.Terms(inSheet: self.inSheet, entity: self.job!)
                } else {
                    VStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("No terms found for query")
                            Spacer()
                        }
                        .padding()
                        .background(Theme.textBackground)
                        .clipShape(.rect(cornerRadius: 16))
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }

    struct TVMCreate: View {
        @EnvironmentObject private var state: AppState
        @Binding public var selected: EntityType

        var body: some View {
            switch self.selected {
            case .records:
                RecordDetail()
                RecordRecent()
            case .jobs:
                JobDetail()
            case .tasks:
                TaskDetail()
                TasksRecent()
            case .notes:
                NoteDetail()
            case .companies:
                CompanyDetail()
            case .people:
                PersonDetail()
            case .projects:
                ProjectDetail()
            case .terms:
                TermDetail()
            }
        }
    }

    struct TVMUpdate: View {
        var body: some View {
            Text("update")
        }
    }

    struct TVMDelete: View {
        var body: some View {
            Text("delete")
        }
    }

    struct TVMDashboard: View {
        @EnvironmentObject private var state: AppState
        @Binding public var selected: EntityType

        var body: some View {
            ZStack(alignment: .bottomTrailing) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading) {
                        switch self.selected {
                        case .records:
                            Home.QuickAccessTabs.QuickRecordPanel()
//                            Widget.Tasks.CheckLists() // for testing only
                            Home.RecordFilters()
//                            Home.QuickAccessTabs.QuickSearchPanel() // probably not here
                            Home.QuickHistory()
                        case .jobs:
                            HStack(alignment: .top, spacing: 1) {
                                Home.QuickAccessTabs.RecentJobs()
                                Home.QuickAccessTabs.FavouriteJobs()
                            }
                            Home.QuickHistory()
                        case .tasks:
                            Home.QuickAccessTabs.QuickTaskList()
                            Widget.Tasks.CheckLists()
                            Home.TaskFilters()
                            Widget.Tasks.DailyOverview()
                        case .notes:
                            HStack(alignment: .top, spacing: 1) {
                                Home.QuickAccessTabs.RecentNotes()
                                Home.QuickAccessTabs.FavouriteNotes()
                            }
                            Home.QuickHistory()
                        case .companies:
                            Home.QuickHistory()
                        case .people:
                            Home.RecentlyMentioned(date: DateHelper.daysAhead(-14, from: self.state.date))
                            Home.QuickHistory()
                        case .projects:
                            Home.QuickHistory()
                        case .terms:
                            Home.QuickAccessTabs.QuickSearchPanel()
                            Home.QuickHistory()
                        }
                    }
                    .padding(8)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Home.QuickCreateWidget()
                    .padding(.trailing)
                    .padding(.bottom, 8)
            }
        }
    }
}
