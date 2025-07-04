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
    static public let animationDuration: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                    Buttons(inSheet: inSheet, job: $job, selected: $selected)
                        .swipe([.left, .right]) { swipe in
                            self.actionOnSwipe(swipe)
                        }
                }

            } else {
                buttons
            }

            if title == nil {
                MiniTitleBar(selected: $selected)
                    .border(width: 1, edges: [.bottom], color: self.state.theme.tint)
            } else {
                title
            }

            if content == nil {
                Content(inSheet: inSheet, job: $job, selected: $selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                content
            }
        }
        .background(.clear)
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
    struct Buttons: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType

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
}
