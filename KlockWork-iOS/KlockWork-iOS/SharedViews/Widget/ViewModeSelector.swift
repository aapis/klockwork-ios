//
//  ViewModeSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

// @TODO: This is all just heinous, replace entuirel
struct ViewModeSelector: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("today.viewMode") private var storedVm: Int = 0
    @State private var viewMode: ViewMode = .tabular
    @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                /// Calendar view mode button
                Button {
                    self.viewMode = .calendar
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "calendar")
                }
                .disabled(self.storedVm == 2)
                .padding(8)
                .background(
                    ZStack(alignment: .top) {
                        (self.storedVm == 2 ? self.state.theme.tint : Theme.cPurple)
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .frame(height: 15)
                    }
                )
                .foregroundStyle(
                    .linearGradient(colors: [self.storedVm == 2 ? Theme.base : self.shouldUseWPImage ? Theme.lightWhite :.gray, self.storedVm == 2 ? Theme.cPurple : self.shouldUseWPImage ? Theme.lightWhite :.gray], startPoint: .top, endPoint: .bottom)
                )

                /// Tabular view mode button
                Button {
                    self.viewMode = .tabular
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "tablecells")
                }
                .disabled(self.storedVm == 0)
                .padding(8)
                .background(
                    ZStack(alignment: .top) {
                        (self.storedVm == 0 ? self.state.theme.tint : Theme.cPurple)
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .frame(height: 15)
                    }
                )
                .foregroundStyle(
                    .linearGradient(colors: [self.storedVm == 0 ? Theme.base : self.shouldUseWPImage ? Theme.lightWhite :.gray, self.storedVm == 0 ? Theme.cPurple : self.shouldUseWPImage ? Theme.lightWhite :.gray], startPoint: .top, endPoint: .bottom)
                )

                /// Hierarchy view mode button
                Button {
                    self.viewMode = .hierarchical
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "list.bullet.indent")
                }
                .disabled(self.storedVm == 1)
                .padding(8)
                .padding(.top, 2)
                .padding(.bottom, 1)
                .background(
                    ZStack(alignment: .top) {
                        (self.storedVm == 1 ? self.state.theme.tint : Theme.cPurple)
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                            .frame(height: 15)
                    }
                )
                .foregroundStyle(
                    .linearGradient(colors: [self.storedVm == 1 ? Theme.base : self.shouldUseWPImage ? Theme.lightWhite : .gray, self.storedVm == 1 ? Theme.cPurple : self.shouldUseWPImage ? Theme.lightWhite : .gray], startPoint: .top, endPoint: .bottom)
                )
            }
            .border(width: 1, edges: [.bottom], color: Theme.lightWhite)
            .clipShape(
                .rect(topLeadingRadius: 8)
            )
        }
        .onAppear(perform: self.actionOnAppear)
    }

    /// Onload handler. Sets the viewMode to the stored value.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let fromStored = ViewMode.by(id: storedVm) {
            self.viewMode = fromStored
        }
    }
}
