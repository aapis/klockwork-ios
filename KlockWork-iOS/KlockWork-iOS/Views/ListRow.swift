//
//  ListRow.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct ListRow: View {
    public let name: String
    public var colour: Color? = .clear
    public var icon: String = "chevron.right"

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(name)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(4)
                .background(.black.opacity(0.3))
                .cornerRadius(6.0)
            Spacer()
            Image(systemName: icon)
                .foregroundStyle(colour!.isBright() ? .white : .gray)
        }
        .padding(8)
        .background(colour)
        .listRowBackground(colour)
    }
}
