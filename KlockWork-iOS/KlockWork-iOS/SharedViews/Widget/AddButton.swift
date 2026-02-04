//
//  AddButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

struct AddButton: View {
    typealias Entity = PageConfiguration.EntityType
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var state: AppState
    public var plain: Bool = true
    @State private var isCreatePanelShowing: Bool = false
    @State private var confirmIntendedToDismiss: Bool = false
    @State private var backgroundColour: Color = Theme.cOrange
    @AppStorage("home.backgroundColour") public var homeBackgroundColourChoice: Int = 0

    var body: some View {
        VStack(alignment: .leading) {
            Button {
                self.isCreatePanelShowing.toggle()
            } label: {
                Image(systemName: "plus")
                    .foregroundStyle(
                        self.state.job?.backgroundColor.isBright() ?? false ?
                            self.backgroundColour
                        :
                            self.state.theme.tint
                    )
                    .font(.title2)
                    .bold()
                    .padding(10)
                    .background(
                        ZStack {
                            if self.plain {
                                self.state.job?.backgroundColor ?? Theme.cPurple
                            } else {
                                self.state.job?.backgroundColor ?? Theme.cPurple
                                LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                                    .blendMode(.softLight)
                            }
                        }
                    )
                    .clipShape(
                        Circle()
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
        .onAppear(perform: {
            switch self.homeBackgroundColourChoice {
            case 1: self.backgroundColour = Theme.cPurple
            case 2: self.backgroundColour = Theme.cGreen
            case 3: self.backgroundColour = Theme.cRoyal
            case 4: self.backgroundColour = Theme.cRed
            default: self.backgroundColour = Theme.cOrange
            }
        })
    }
}

extension AddButton {
    private func actionDidSheetDismiss() -> Void {
        // @TODO: this works, but may be unnecessary since field data is saved anyways
//        self.confirmIntendedToDismiss = true
    }
}
