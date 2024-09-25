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
    public var icon: String?
    public var extraColumn: AnyView?
    public var highlight: Bool = false // @TODO: highlight is deprecated and unused
    public var gradientColours: (Color, Color) = (.clear, .clear) // (.clear, .black)
    public var padding: (CGFloat, CGFloat, CGFloat, CGFloat) = (8, 8, 8, 8)

    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            Text(name)
                .foregroundStyle(self.colour!.isBright() ? Theme.base : .white)
                .multilineTextAlignment(.leading)
                .padding(.top, self.padding.0)
                .padding(.bottom, self.padding.2)
            Spacer()
            extraColumn
            if self.icon != nil {
                ZStack {
                    Image(systemName: icon!)
                        .foregroundStyle(self.highlight ? .white : self.colour!.isBright() ? Theme.base.opacity(0.6) : .white)
                    LinearGradient(gradient: Gradient(colors: [self.gradientColours.0, self.gradientColours.1]), startPoint: .trailing, endPoint: .leading)
                        .opacity(0.3)
                        .blendMode(.softLight)
                        .frame(width: 20)
                }
            }
        }
        .padding(.trailing, self.padding.1)
        .padding(.leading, self.padding.3)
        .background(colour)
        .listRowBackground(colour)
    }
}

struct ToggleableListRow: View {
    @EnvironmentObject private var state: AppState
    public let name: String
    public var colour: Color? = .clear
    public var iconOff: String?
    public var iconOn: String?
    public var extraColumn: AnyView?
    public var highlight: Bool = false // @TODO: highlight is deprecated and unused
    public var padding: CGFloat = 8
    @Binding public var selected: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Text(name)
                    .foregroundStyle(selected && (self.colour ?? Theme.rowColour).isBright() ? Theme.base : .white)
                    .multilineTextAlignment(.leading)
                    .padding(6)
                Spacer()
                extraColumn
            }
            .padding(self.padding)
            .background(selected ? colour.opacity(1) : colour.opacity(0.3))

            if iconOn != nil && iconOff != nil {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Image(systemName: selected ? iconOn! : iconOff!)
                        .foregroundStyle(self.state.theme.tint)
                        .font(.title3)
                        .padding(1)
                    Spacer()
                }
                .frame(width: 40)
                .opacity(selected ? 1 : 0.5)
                .background(selected ? self.colour!.opacity(0.7) : (self.colour ?? .clear).opacity(0.3))
            }
        }
    }
}

struct ToggleableListRowTyped: View {
    typealias Row = Tabs.Content.Individual.SingleJobDetailedCustomButton

    @EnvironmentObject private var state: AppState
    public var job: Job
    public var iconOff: String?
    public var iconOn: String?
    public var extraColumn: AnyView?
    public var highlight: Bool = false // @TODO: highlight is deprecated and unused
    public var padding: CGFloat = 8
    @Binding public var selected: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            HStack(alignment: .top, spacing: 0) {
                Row(job: self.job)
                Spacer()
                extraColumn
            }
            .padding(self.padding)

            if iconOn != nil && iconOff != nil {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    Image(systemName: selected ? iconOn! : iconOff!)
                        .foregroundStyle(self.state.theme.tint)
                        .font(.title3)
                        .padding(1)
                    Spacer()
                }
                .frame(width: 40)
                .opacity(selected ? 1 : 0.5)
                .background(selected ? self.job.backgroundColor.isBright() ? .black.opacity(0.5) : .clear : .clear)
            }
        }
        .background(
            Tabs.Content.Common.TypedListRowBackground(colour: self.job.backgroundColor, type: .jobs)
        )
        .listRowBackground(
            Tabs.Content.Common.TypedListRowBackground(colour: self.job.backgroundColor, type: .jobs)
        )
    }
}

extension ToggleableListRowTyped {
    /// Tap handler. Marks current row as selected.
    /// - Returns: Void
    private func actionOnTap(_ job: Job?) -> Void {
        self.selected.toggle()
    }
}

struct ContactListRow: View {
    public let person: Person
    public var colour: Color? = .clear
    public var icon: String?
    public var extraColumn: AnyView?
    public var highlight: Bool = false // @TODO: highlight is deprecated and unused
    public var gradientColours: (Color, Color) = (.clear, .clear) // (.clear, .black)
    public var padding: (CGFloat, CGFloat, CGFloat, CGFloat) = (8, 8, 8, 8)
    @State private var initials: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle()
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(width: 33, height: 33)
                Text(self.initials)
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Theme.cPurple)
            }

            Text(self.person.name ?? "_NAME")
                .foregroundStyle(self.colour!.isBright() ? Theme.base : .white)
                .multilineTextAlignment(.leading)
            Spacer()
            Text(self.person.title ?? "_TITLE")
                .foregroundStyle(self.colour!.isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                .font(.caption)
                .multilineTextAlignment(.trailing)

            if extraColumn != nil {
                Spacer()
                extraColumn
            }
            if self.icon != nil {
                Spacer()
                ZStack {
                    Image(systemName: icon!)
                        .foregroundStyle(self.highlight ? .white : self.colour!.isBright() ? Theme.base.opacity(0.6) : .white)
                    LinearGradient(gradient: Gradient(colors: [self.gradientColours.0, self.gradientColours.1]), startPoint: .trailing, endPoint: .leading)
                        .opacity(0.3)
                        .blendMode(.softLight)
                        .frame(width: 20)
                }
            }
        }
        .padding(.top, self.padding.0)
        .padding(.bottom, self.padding.2)
        .padding(.trailing, self.padding.1)
        .padding(.leading, self.padding.3)
        .background(colour)
        .listRowBackground(colour)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension ContactListRow {
    /// Onload handler. Populates abbreviation
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let name = self.person.name {
            self.initials = ""
            for word in name.components(separatedBy: " ") {
                if let letter = word.uppercased().first {
                    self.initials += "\(letter)"
                }
            }
        }
    }
}
