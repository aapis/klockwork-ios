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
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 2)
    }
    private let page: PageConfiguration.AppPage = .explore
    @State private var path = NavigationPath()
    @State private var entityCounts: [EntityTypePair] = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                Header()
                Divider().background(.white).frame(height: 1)
                Widgets(text: $searchText)
            }
            .background(page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
        }
        .tint(self.state.theme.tint)
    }

    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = Date()

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.1)
                        .blendMode(.softLight)
                        .frame(height: 45)

                    HStack(spacing: 8) {
                        Text("Explore").font(.title2).padding([.leading, .trailing], 10).bold()
                        Spacer()
                        CreateEntitiesButton(isViewModeSelectorVisible: false, isDateSelectorVisible: true)
                    }
                }
            }
            .onAppear(perform: {
                date = self.state.date
            })
            .onChange(of: date) {
                self.state.date = date
            }
        }
    }

    struct Widgets: View {
        @EnvironmentObject private var state: AppState
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
                                    .foregroundStyle(self.state.theme.tint)
                                Text("Activity Calendar")
                            }
                        }
                        .listRowBackground(Theme.textBackground)

                        NavigationLink {
                            Widget.DataExplorer()
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(self.state.theme.tint)
                                Text("Data Explorer")
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }

                    Section("Activities") {
                        NavigationLink {
                            FlashcardActivity()
                        } label: {
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundStyle(self.state.theme.tint)
                                Text("Flashcards")
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
