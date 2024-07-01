//
//  RowAddButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-30.
//

import SwiftUI

struct RowAddButton: View {
    public var title: String = "Add"
    @Binding public var isPresented: Bool
    public var animationDuration: CGFloat = 0.1

    var body: some View {
        Button {
            withAnimation(.linear(duration: self.animationDuration)) {
                self.isPresented.toggle()
            }
        } label: {
            ZStack(alignment: .center) {
                RadialGradient(colors: [Theme.base, .clear], center: .center, startRadius: 0, endRadius: 40)
                    .blendMode(.softLight)
                    .opacity(0.8)
                Text(self.title)
                    .font(.caption)
                    .padding(6)
                    .padding([.leading, .trailing], 8)
                    .background(self.isPresented ? .orange : .white)
                    .foregroundStyle(Theme.base)
                    .clipShape(.capsule(style: .continuous))
            }
        }
        .frame(width: 80)
    }
}

struct RowAddNavLink: View {
    public var title: String = "Add"
    public let target: AnyView

    var body: some View {
        NavigationLink {
            self.target
        } label: {
            ZStack(alignment: .center) {
                RadialGradient(colors: [Theme.base, .clear], center: .center, startRadius: 0, endRadius: 40)
                    .blendMode(.softLight)
                    .opacity(0.8)
                Text(self.title)
                    .font(.caption)
                    .padding(6)
                    .padding([.leading, .trailing], 8)
                    .background(.white)
                    .foregroundStyle(Theme.base)
                    .clipShape(.capsule(style: .continuous))
            }
        }
        .frame(width: 90)
    }
}
