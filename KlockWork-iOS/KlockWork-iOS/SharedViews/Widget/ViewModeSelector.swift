//
//  ViewModeSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

struct ViewModeSelector: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("today.viewMode") private var storedVm: Int = 0
    @State private var viewMode: ViewMode = .tabular

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    self.viewMode = .tabular
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "tablecells")
                }
                .disabled(self.storedVm == 0)
                .padding(5)
                .background(self.storedVm == 0 ? self.state.theme.tint : .black.opacity(0.1))
                .foregroundStyle(self.storedVm == 0 ? Theme.cPurple : self.state.theme.tint )
                .clipShape(.rect(topLeadingRadius: 6, bottomLeadingRadius: 6))

                Button {
                    self.viewMode = .hierarchical
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "list.bullet")
                }
                .disabled(self.storedVm == 1)
                .padding(5)
                .background(self.storedVm == 1 ? self.state.theme.tint : .black.opacity(0.1))
                .foregroundStyle(self.storedVm == 1 ? Theme.cPurple : self.state.theme.tint)
                .clipShape(.rect(bottomTrailingRadius: 6, topTrailingRadius: 6))
            }
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
