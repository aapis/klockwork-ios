//
//  OmniCreator.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-03.
//

import SwiftUI

struct OmniCreator: View {
    public var inSheet = false
    public var page: PageConfiguration.AppPage = .create
    @State public var job: Job?
    @State public var selected: Tabs.EntityType = .records

    var body: some View {
        VStack(alignment: .leading) {
            Tabs(inSheet: inSheet, job: $job, selected: $selected, mode: .create)
        }
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
