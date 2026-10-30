//
//  SuperiorTabView.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-10.
//

import SwiftUI

struct SuperiorTabView: View {
    @EnvironmentObject private var state: AppState
    @State private var pageView: AnyView = AnyView(Home(inSheet: false))

    var body: some View {
//        ZStack(alignment: .bottom) {
        VStack(alignment: .leading) {
            self.state.view
//            HStack {
//                SuperiorTab(
//                    icon: "house.fill",
//                    label: "Home",
//                    target: AnyView(Home(inSheet: false)),
//                    pageView: self.$pageView,
//                )
//                Spacer()
//                SuperiorTab(
//                    icon: "tray.fill",
//                    label: "Today",
//                    target: AnyView(Today(inSheet: false)),
//                    pageView: self.$pageView,
//                )
//                Spacer()
//                SuperiorTab(
//                    icon: "plus",
//                    pageView: self.$pageView,
//                )
//                Spacer()
//                SuperiorTab(
//                    icon: "globe.desk.fill",
//                    label: "Explore",
//                    target: AnyView(Explore()),
//                    pageView: self.$pageView,
//                )
//                Spacer()
//                SuperiorTab(
//                    icon: "magnifyingglass",
//                    label: "Find",
//                    target: AnyView(Find()),
//                    pageView: self.$pageView,
//                )
//            }
//            .padding([.leading, .trailing, .top])
        }
//        .background(
//            ZStack{
//                LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
//                    .blendMode(.softLight)
//                Theme.cPurple
//            }
//            .ignoresSafeArea(.all)
//        )
        .onAppear(perform: {
            self.state.view = self.pageView
        })
    }

    struct SuperiorTab: View {
        @EnvironmentObject private var state: AppState
        @AppStorage("home.backgroundWallpaper") private var homeWallpaper: String = ""
        @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false
        public var icon: String
        public var label: String? = nil
        public var target: AnyView? = nil
        @Binding public var pageView: AnyView

        var body: some View {
            Button {
                if let target = self.target {
                    self.pageView = target
                }
            } label: {
                self.labelView
            }
        }

        var labelView: some View {
            VStack {
                Image(systemName: self.icon)
                    .font(.title2)
                if let label = self.label {
                    Text(label)
                        .font(.caption)
                        .padding(.top, 2)
                }
            }
            .foregroundStyle(.white)
            .padding(self.label == nil ? 8 : 0)
            .background(
                ZStack {
                    if self.label == nil {
                        self.state.theme.tint
                    } else {
                        Color.clear
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 4))
            )
        }
    }
}
