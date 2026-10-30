//
//  GASidebar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-29.
//

import SwiftUI

struct GASidebar: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("recordBlock.isSidebarShowing") private var isSidebarShowing: Bool = false

    var body: some View {
        if self.isSidebarShowing {
//            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    SidebarTitle(
                        title: "Calendar",
                        description: "Tap once to view records for one day, tap another day to see the data within that range."
                    )
                    GADateNavigation()
                    GACalendar()
                    SidebarTitle(
                        title: "Entities In Range",
                        description: "All entities created, updated, completed, or cancelled during the specified range."
                    )
                    //                EntitiesInRange()
                }
                .background(Theme.cPurple)
                .clipShape(.rect(bottomTrailingRadius: 16))
                .shadow(radius: 4)
                .overlay {
                    UnevenRoundedRectangle(bottomTrailingRadius: 16)
                        .stroke(Theme.lightWhite, lineWidth: 1)
                        .blendMode(.softLight)
                }

//            }
            .frame(width: 350)
            .swipe([.left, .right]) { swipe in
                if swipe == .left {
                    self.isSidebarShowing = false
                }
            }
        }
    }
}
