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
            Divider().background(.white).frame(height: 1)
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
                Tabs.TVMCreate(selected: $selected)
            case .read:
                Tabs.Content(inSheet: inSheet, job: $job, selected: $selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            case .update:
                Tabs.TVMUpdate()
            case .delete:
                Tabs.TVMDelete()
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
                    AddButton()
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
        case create, read, update, delete
    }

    struct Buttons: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType
        @Binding public var tabLocation: Int
        public var mode: TabsViewMode

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(EntityType.allCases, id: \.self) { page in
                        VStack(spacing: 0) {
                            Button {
                                selected = page
                            } label: {
                                (page == selected ? page.selectedIcon : page.icon)
                                    .frame(maxHeight: 20)
                                    .padding(14)
                                    .background(page == selected ? Theme.darkBtnColour : .clear)
                                    .foregroundStyle(page == selected ? self.state.theme.tint : .gray)
                            }
                            .buttonStyle(.plain)
                            .clipShape(
                                .rect(
                                    bottomLeadingRadius: self.mode == .create && self.tabLocation == 1 ? 8 : 0,
                                    bottomTrailingRadius: self.mode == .create && self.tabLocation == 1 ? 8 : 0
                                )
                            )
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 50)
        }
    }

    struct Content: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType

        var body: some View {
            switch selected {
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
            switch selected {
            case .records:
                RecordDetail()
            case .jobs:
                JobDetail()
            case .tasks:
                TaskDetail()
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
}
