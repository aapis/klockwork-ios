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
    public var extraColumn: AnyView?
    public var highlight: Bool = true

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(name)
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .padding(6)
                .background(highlight ? .black.opacity(0.2) : .clear)
                .cornerRadius(5)
            Spacer()
            extraColumn
            Image(systemName: icon)
                .foregroundStyle(colour!.isBright() ? .white : .gray)
        }
        .padding(8)
        .background(colour)
        .listRowBackground(colour)
    }
}
