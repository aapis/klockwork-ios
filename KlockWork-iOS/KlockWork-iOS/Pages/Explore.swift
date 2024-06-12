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
    @State private var isPresented: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Widgets(text: $searchText)
                .sheet(isPresented: $isPresented) {
                    FilterPanel()
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Explore")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isPresented.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .padding()
                                .background(Theme.rowColour)
                                .mask(Circle())
                        }
                    }
                }
            }
        }
        .tint(fgColour)
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
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if showActivityCalendar {Widget.ActivityCalendar(searchTerm: $text)}
                    if showDataExplorer {Widget.DataExplorer()}
//                    if showRecent {Widget.Rollups()}
                    if showTrends {Widget.Trends()}
                }
                Spacer()
            }
            .padding()
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
