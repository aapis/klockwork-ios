//
//  Planning.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var text: String = ""
    @State private var job: Job? = nil
    @State private var selected: PlanType = .daily
    @State private var path = NavigationPath()
    private let page: PageConfiguration.AppPage = .planning

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                Header(page: self.page)
                Divider().background(.white).frame(height: 1)
                PlanTabs(
                    inSheet: true,
                    job: $job,
                    selected: $selected
                )
            }
            .background(page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

extension Planning {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State private var date: Date = Date()
        public let page: PageConfiguration.AppPage

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.2)
                        .blendMode(.softLight)
                        .frame(height: 45)
                    
                    HStack(spacing: 8) {
                        PageTitle(text: "Planning")
                        DateStrip()
                        Spacer()
                        CreateEntitiesButton(page: self.page)
                    }
                }
            }
            .onAppear(perform: {
                date = self.state.date
                DefaultObjects.deleteDefaultObjects()
            })
            .onChange(of: date) {
                self.state.date = DateHelper.startOfDay(self.date)
            }
        }
    }

    struct Content: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("Coming soon!")
                    .padding()
                Spacer()
            }
        }
    }
}
