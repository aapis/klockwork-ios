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
    @AppStorage("home.tabLocation") public var tabLocation: Int = 0
    @AppStorage("home.backgroundWallpaper") public var homeWallpaper: String = ""
    @AppStorage("home.backgroundWallpaperAttachmentPoint") public var homeWallpaperAttachmentPoint: Int = 0
    @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false
    private let page: PageConfiguration.AppPage = .settings

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            List {
                Section("UI Customization") {
                    ColorPicker("Accent Colour", selection: self.$tint)
                        .onChange(of: self.tint) {
                            self.actionOnChangeTint()
                        }
                        .listRowBackground(Theme.textBackground)
                        .listRowSeparator(.hidden)

                    Toggle("Image wallpaper", isOn: self.$shouldUseWPImage)
                        .listRowBackground(Theme.textBackground)

                    if self.shouldUseWPImage {
                        Picker("Wallpaper", selection: self.$homeWallpaper) {
                            Text("01").tag("01")
                            Text("02").tag("02")
                            Text("03").tag("03")
                            Text("04").tag("04")
                            Text("05").tag("05")
                            Text("06").tag("06")
                            Text("07").tag("07")
                        }
                        .listRowBackground(Theme.textBackground)
                        .listRowSeparator(.hidden)
                        .background(
                            ZStack(alignment: .topLeading) {
                                Image("wallpaper-\(self.homeWallpaper)")
                            }
                        )

                        // @TODO: implement once I figure out how to do this...
//                        Picker("Wallpaper attachment point", selection: self.$homeWallpaperAttachmentPoint) {
//                            Text("Top left").tag(0)
//                            Text("Top right").tag(1)
//                            Text("Centre").tag(2)
//                            Text("Bottom left").tag(3)
//                            Text("Bottom right").tag(4)
//                        }
//                        .listRowBackground(Theme.textBackground)
//                        .listRowSpacing(1)
//                        .listRowSeparator(.hidden)
                    } else {
                        Picker("Dashboard background", selection: self.$homeBackgroundColour) {
                            Text("System").tag(-1)
                            Text("Orange").tag(0)
                            Text("Blue").tag(1)
                            Text("Green").tag(2)
                            Text("Royal").tag(3)
                            Text("Red").tag(4)
                        }
                        .listRowBackground(Theme.textBackground)
                        .listRowSeparator(.hidden)
                    }
                }

                Section("Create page options") {
                    Picker("Tab location", selection: self.$tabLocation) {
                        Text("Top (default)").tag(0)
                        Text("Bottom").tag(1)
                    }
                    .listRowBackground(Theme.textBackground)
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
