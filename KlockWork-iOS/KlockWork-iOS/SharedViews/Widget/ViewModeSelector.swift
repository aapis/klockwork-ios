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
                    self.viewMode = .calendar
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "calendar")
                }
                .disabled(self.storedVm == 2)
                .padding(8)
                .background(self.storedVm == 2 ? self.state.theme.tint : .black.opacity(0.1))
                .foregroundStyle(self.storedVm == 2 ? Theme.cPurple : self.state.theme.tint)
                .clipShape(.rect(topLeadingRadius: 4))

                Button {
                    self.viewMode = .tabular
                    self.storedVm = self.viewMode.id
                } label: {
                    Image(systemName: "tablecells")
                }
                .disabled(self.storedVm == 0)
                .padding(8)
                .background(self.storedVm == 0 ? self.state.theme.tint : .black.opacity(0.1))
                .foregroundStyle(self.storedVm == 0 ? Theme.cPurple : self.state.theme.tint)

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
                .background(self.storedVm == 1 ? self.state.theme.tint : .black.opacity(0.1))
                .foregroundStyle(self.storedVm == 1 ? Theme.cPurple : self.state.theme.tint)
                .clipShape(.rect(topTrailingRadius: 4))
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
