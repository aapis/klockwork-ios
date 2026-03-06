//
//  TitleBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct MiniTitleBar: View {
    typealias PType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    @Binding public var selected: PType
    @State private var title: String = ""

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.title)
                .font(.caption)
            Spacer()
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 8)
        .background(
            ZStack(alignment: .top) {
                self.state.theme.tint
                LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                    .blendMode(.softLight)
            }
        )
        .foregroundStyle(Theme.lightBase)
        .onAppear(perform: self.setTitle)
        .onChange(of: self.selected) {self.setTitle()}
    }
}

struct MiniTitleBarPlan: View {
    typealias PType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
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

struct MiniTitleBarCustom: View {
    @EnvironmentObject private var state: AppState
    public var title: String
    public var icon: String? = nil
    public var fgColour: Color = Theme.lightBase

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(self.title)
            Spacer()
            if let icon = self.icon {
                Image(systemName: icon)
            }
        }
        .padding([.top, .bottom], 5)
        .padding([.leading, .trailing], 8)
        .background(
            ZStack(alignment: .top) {
                self.state.theme.tint
                LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                    .blendMode(.softLight)
            }
        )
        .foregroundStyle(self.fgColour)
        .font(.caption)
    }
}

extension MiniTitleBar {
    /// Sets title of the MTB to the selected tab's label
    /// - Returns: Void
    private func setTitle() -> Void {
        switch self.state.today.mode {
        case .create:
            title = "Create \(selected.enSingular)".uppercased()
        case .delete:
            title = "Delete \(selected.enSingular)".uppercased()
        default:
            title = selected.label.uppercased()
        }
    }
}
