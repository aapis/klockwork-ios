//
//  AddButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

extension Home.QuickCreateWidget {
    struct AddButton: View {
        typealias Entity = PageConfiguration.EntityType
        @Environment(\.dismiss) private var dismiss
        @EnvironmentObject private var state: AppState
        public var plain: Bool = true
        @State private var isCreatePanelShowing: Bool = false
        @State private var confirmIntendedToDismiss: Bool = false

        var body: some View {
            VStack(alignment: .leading) {
                Button {
                    self.isCreatePanelShowing.toggle()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(
                            .linearGradient(colors: [Theme.base, Theme.cPurple], startPoint: .top, endPoint: .bottom)
                        )
                        .font(.title2)
                        .bold()
                        .frame(height: 40)
                        .padding([.leading, .trailing])
                        .background(
                            ZStack {
                                self.state.theme.tint
                                if !self.plain {
                                    LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .blendMode(.softLight)
                                }
                            }
                        )
                }
            }
            .sheet(isPresented: self.$isCreatePanelShowing, onDismiss: self.actionDidSheetDismiss) {
                OmniCreator()
            }
            .alert("You may have unsaved data, are you sure?", isPresented: self.$confirmIntendedToDismiss) {
                Button("Confirm", role: .destructive) {
                    self.confirmIntendedToDismiss = false
                }
                Button("Cancel", role: .cancel) {
                    self.isCreatePanelShowing = true
                }
            }
        }
    }
}

extension Home.QuickCreateWidget.AddButton {
    private func actionDidSheetDismiss() -> Void {
        // @TODO: this works, but may be unnecessary since field data is saved anyways
//        self.confirmIntendedToDismiss = true
    }
}
