//
//  Tabs.Content.Common.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-19.
//

import SwiftUI

extension Tabs.Content {
    struct Common {
        struct TypedListRowBackground: View {
            @EnvironmentObject private var state: AppState
            public let colour: Color
            public let type: PageConfiguration.EntityType

            var body: some View {
                ZStack(alignment: .topTrailing) {
                    self.colour
                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                        .opacity(0.1)
                    type.icon
                        .font(.system(size: 69))
                        .foregroundStyle(self.colour.isBright() ? self.colour : .black.opacity(0.1))
                        .opacity(0.3)
                        .shadow(color: self.colour.isBright() ? .black.opacity(0.1) : .white.opacity(0.2), radius: 4, x: 1, y: 1)
                }
                .border(width: 1, edges: [.bottom], color: (self.colour.isBright() ? Theme.base : Color.white).opacity(0.3))
            }
        }
    }
}

