//
//  TitleBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct MiniTitleBar: View {
    typealias PType = PageConfiguration.EntityType

    @Binding public var selected: PType

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(selected.label.uppercased())
                .font(.caption)
            Spacer()
        }
        .padding(5)
        .background(Theme.darkBtnColour)
        .foregroundStyle(.gray)
    }
}

struct MiniTitleBarPlan: View {
    typealias PType = PageConfiguration.PlanType

    @Binding public var selected: PType

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(selected.label.uppercased())
                .font(.caption)
            Spacer()
        }
        .padding(5)
        .background(Theme.darkBtnColour)
        .foregroundStyle(.gray)
    }
}
