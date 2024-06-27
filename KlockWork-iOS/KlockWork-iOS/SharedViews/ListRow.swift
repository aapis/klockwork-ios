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
    public var gradientColours: (Color, Color) = (.clear, .clear) // (.clear, .black)

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            HStack {
                Text(name)
                    .foregroundStyle(self.highlight ? .white : self.colour!.isBright() ? Theme.base : .white)
                    .multilineTextAlignment(.leading)
                    .padding([.top, .bottom], 6)
                    .padding([.leading, .trailing], self.highlight ? 6 : 0)
                    .background(self.highlight ? .black.opacity(0.2) : .clear)
                    .cornerRadius(5)
            }
            .padding(8)

            Spacer()
            extraColumn
            ZStack {
                Image(systemName: icon)
                    .foregroundStyle(self.highlight ? .white : self.colour!.isBright() ? Theme.base : .white)
                    .padding(8)
                LinearGradient(gradient: Gradient(colors: [self.gradientColours.0, self.gradientColours.1]), startPoint: .trailing, endPoint: .leading)
                    .opacity(0.3)
                    .blendMode(.softLight)
                    .frame(width: 40)
            }
        }
        .background(colour)
        .listRowBackground(colour)
    }
}

struct ToggleableListRow: View {
    public let name: String
    public var colour: Color? = .clear
    public var iconOff: String = "square"
    public var iconOn: String = "square.fill"
    public var extraColumn: AnyView?
    public var highlight: Bool = true
    public var padding: CGFloat = 8
    @Binding public var selected: Bool

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Text(name)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .padding(6)
                    .background(highlight ? .black.opacity(0.2) : .clear)
                    .cornerRadius(5)
                Spacer()
                extraColumn
            }

            HStack(alignment: .firstTextBaseline, spacing: 0) {
                Image(systemName: selected ? iconOn : iconOff)
                    .foregroundStyle(.yellow)
                    .font(.title3)
                    .padding(1)
            }
            .background(selected ? .yellow : .clear)
            .listRowBackground(selected ? Color.yellow : Color.clear)
            .cornerRadius(5)
        }
        .padding([.leading, .trailing, .top, .bottom], self.padding)
        .background(selected ? colour.opacity(1) : colour.opacity(0.3))
        .listRowBackground(selected ? colour.opacity(1) : colour.opacity(0.3))
    }
}
