//
//  TitleBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct MiniTitleBar: View {
    typealias EntityType = PageConfiguration.EntityType

    @Binding public var selected: EntityType

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
