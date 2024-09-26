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
    public var filters: AnyView? = nil
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

            if filters == nil {
                Filters(selected: $selected)
            } else {
                filters
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
                                if page == .jobs {
                                    (page == selected ? page.selectedIcon : page.icon)
                                        .frame(maxHeight: 20)
                                        .padding(14)
                                        .background(page == selected ? Theme.darkBtnColour : .clear)
                                        .foregroundStyle(self.state.job == nil ? page == selected ? self.state.theme.tint : .gray : self.state.job!.backgroundColor)
                                } else {
                                    (page == selected ? page.selectedIcon : page.icon)
                                        .frame(maxHeight: 20)
                                        .padding(14)
                                        .background(page == selected ? Theme.darkBtnColour : .clear)
                                        .foregroundStyle(page == selected ? self.state.theme.tint : .gray)
                                }
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

    struct Filters: View {
        @EnvironmentObject private var state: AppState
        @Binding public var selected: EntityType
        @State private var isPresented: Bool = false
        @State private var selectedFilters: [FilterField] = []

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .center, spacing: 0) {
                    ScrollView(.horizontal) {
                        ForEach(self.selectedFilters, id: \.id) { filter in
                            FilterFieldView(filter: filter, callback: self.actionDeSelectFilter)
                                .opacity(self.isPresented ? 0.5 : 1)
                        }
                    }
                    Spacer()
                    Button {
                        self.isPresented.toggle()
                    } label: {
                        ZStack(alignment: .center) {
                            Image(systemName: self.isPresented ? "minus" : "plus")
                            Color.white.opacity(0.7).blendMode(.softLight)
                        }
                    }
                    .foregroundStyle(.yellow)
                    .frame(width: 35, height: 35)
                }
                .padding(.leading, 8)

                if self.isPresented {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(self.selected.filters, id: \.id) { filter in
                            FilterFieldView(filter: filter, callback: self.actionSelectFilter)
                        }
                    }
                    .padding(8)
                }
            }
            .background(Theme.textBackground)
        }

        struct FilterField: Identifiable, Equatable {
            var id: UUID = UUID()
            var name: String
            var options: [FilterOptionPair] = []
            
            /// Equatable implementation
            /// - Parameters:
            ///   - lhs: FilterField
            ///   - rhs: FilterField
            /// - Returns: Bool
            static func == (lhs: Tabs.Filters.FilterField, rhs: Tabs.Filters.FilterField) -> Bool {
                return lhs.id == rhs.id
            }
        }

        struct FilterOptionPair: Identifiable {
            var id: UUID = UUID()
            var key: String
            var value: Any
        }

        struct FilterFieldView: View {
            var filter: FilterField
            var callback: ((FilterField) -> Void)?

            var body: some View {
                Button {
                    self.callback?(self.filter)
                } label: {
                    HStack(alignment: .center, spacing: 8) {
                        Text(filter.name)
                        Image(systemName: "xmark.square.fill")
                    }
                    .foregroundStyle(.yellow)
                    .padding(3)
                    .background(.white.opacity(0.7).blendMode(.softLight))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    .font(Theme.fontCaption)
                }
            }
        }
    }
}

extension Tabs.Filters {
    /// Onload handler. Determines which filter fields to display
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.selectedFilters = []
    }
    
    /// Select a filter from the list
    /// - Parameter filter: FilterField
    /// - Returns: Void
    private func actionSelectFilter(_ filter: FilterField) -> Void {
        if !self.selectedFilters.contains(where: {$0 == filter}) {
            self.selectedFilters.append(filter)
        }
    }
    
    /// Deselect a filter from the list
    /// - Parameter filter: FilterField
    /// - Returns: Void
    private func actionDeSelectFilter(_ filter: FilterField) -> Void {
        self.selectedFilters.removeAll(where: {$0 == filter})
    }
}
