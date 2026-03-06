//
//  Titlebar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct TitleBar: View {
    typealias EntityType = PageConfiguration.EntityType

    @Binding public var selected: EntityType
    @Binding public var open: Bool
    public var count: Int

    var body: some View {
        Button {
            open.toggle()
        } label: {
            HStack(alignment: .center, spacing: 5) {
                Text(selected.label.uppercased())
                    .fontWeight(.bold)
                Spacer()
                Text(String(count))
                    .padding([.leading, .trailing], 5)
                    .background(.white.opacity(0.3))
                    .mask {Capsule()}
                Image(systemName: open ? "minus" : "plus")
            }
            .font(.callout)
            .padding(12)
            .background(Theme.rowColour)
            .foregroundStyle(.white)
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension TitleBar {
    /// Fires when the button view loads
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if count == 0 {
            self.open = false
        }
    }
}
