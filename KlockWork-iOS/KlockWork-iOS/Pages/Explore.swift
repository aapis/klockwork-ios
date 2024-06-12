//
//  Home.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Explore: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias EntityTypePair = PageConfiguration.EntityTypePair

    @EnvironmentObject private var state: AppState
    private let fgColour: Color = .yellow
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 2)
    }

    @State private var path = NavigationPath()
    @State private var entityCounts: [EntityTypePair] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Header()
                Widgets(text: $searchText)
            }
            .navigationBarTitleDisplayMode(.inline)
            .background(Theme.cGreen)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
        }
        .tint(fgColour)
    }

    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = Date()

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(Calendar.autoupdatingCurrent.isDateInToday(self.state.date) ? "Explore" : self.state.date.formatted(date: .abbreviated, time: .omitted))
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
                }
                Spacer()
                Button {
                    // pass
                } label: {
                    Text("\(date.formatted(date: .abbreviated, time: .omitted))")
                    .padding(7)
                    .background(self.state.isToday() ? .yellow : Theme.rowColour)
                    .foregroundStyle(self.state.isToday() ? Theme.cOrange : .white)
                    .fontWeight(.bold)
                    .cornerRadius(7)
                }
                .padding(.trailing)
            }
            .onAppear(perform: {
                date = self.state.date
            })
        }
    }

    struct FilterPanel: View {
        @AppStorage("explore.widget.activityCalendar") private var showActivityCalendar: Bool = true
        @AppStorage("explore.widget.dataExplorer") private var showDataExplorer: Bool = false
        @AppStorage("explore.widget.recent") private var showRecent: Bool = false
        @AppStorage("explore.widget.trends") private var showTrends: Bool = false
        @State private var activityCalendarToggleDisabled: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                List {
                    Section("Widgets") {
                        Toggle("Activity Calendar", isOn: $showActivityCalendar)
                            .disabled(self.activityCalendarToggleDisabled)
                            .onChange(of: showDataExplorer) {self.showWidgetsOrDefault()}
                            .onChange(of: showRecent) {self.showWidgetsOrDefault()}
                            .onChange(of: showTrends) {self.showWidgetsOrDefault()}
                        Toggle("Data Explorer", isOn: $showDataExplorer)
//                        Toggle("Recent", isOn: $showRecent)
                        Toggle("Trends", isOn: $showTrends)
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .background(.clear)
                .scrollContentBackground(.hidden)
                .onAppear(perform: self.showWidgetsOrDefault)
            }
            .background(Theme.cGreen)
        }
    }

    struct Widgets: View {
        @Binding public var text: String
        @AppStorage("explore.widget.activityCalendar") private var showActivityCalendar: Bool = true
        @AppStorage("explore.widget.dataExplorer") private var showDataExplorer: Bool = false
        @AppStorage("explore.widget.recent") private var showRecent: Bool = false
        @AppStorage("explore.widget.trends") private var showTrends: Bool = false

        var body: some View {
            NavigationStack {
                List {
                    Section("Visualize your data") {
                        NavigationLink {
                            Widget.ActivityCalendar(searchTerm: $text)
                        } label: {
                            HStack {
                                Image(systemName: "calendar")
                                Text("Activity Calendar")
                            }
                        }
                        .listRowBackground(Theme.textBackground)

                        NavigationLink {
                            Widget.DataExplorer()
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                Text("Data Explorer")
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
                Spacer()
            }
            .scrollContentBackground(.hidden)
            .background(Theme.cGreen)
        }
    }
}

extension Explore.FilterPanel {
    /// Show user's selected widgets, or the default one (ActivityCalendar) if none selected
    /// - Returns: Void
    private func showWidgetsOrDefault() -> Void {
        if showRecent == false && showTrends == false && showDataExplorer == false {
            showActivityCalendar = true
            activityCalendarToggleDisabled = true
        } else {
            activityCalendarToggleDisabled = false
        }
    }
}
