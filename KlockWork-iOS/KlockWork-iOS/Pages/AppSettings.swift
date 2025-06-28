//
//  AppSettings.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct AppSettings: View {
    @EnvironmentObject private var state: AppState
    @State private var tint: Color = .yellow
    @AppStorage("home.backgroundColour") public var homeBackgroundColour: Int = 0
    private let page: PageConfiguration.AppPage = .settings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Picker("Dashboard background", selection: self.$homeBackgroundColour) {
                    Text("Default").tag(0)
                    Text("Blue").tag(1)
                    Text("Green").tag(2)
                    Text("Royal").tag(3)
                    Text("Red").tag(4)
                }
                .listRowBackground(Theme.textBackground)

                ColorPicker("Accent Colour", selection: self.$tint)
                    .listRowBackground(Theme.textBackground)
                    .onChange(of: self.tint) {
                        self.actionOnChangeTint()
                    }
            }
            .scrollContentBackground(.hidden)
            Spacer()
        }
        .background(self.page.primaryColour)
        .presentationBackground(self.page.primaryColour)
        .navigationTitle("Settings")
        .onAppear(perform: {
            self.tint = self.state.theme.tint
        })
    }
}

extension AppSettings {
    /// Fires when you choose a new tint colour
    /// - Returns: Void
    private func actionOnChangeTint() -> Void {
        self.state.theme.tint = self.tint
    }
}
