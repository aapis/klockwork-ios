//
//  PageActionBar.Create.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-14.
//
import SwiftUI

extension PageActionBar {
    struct Create: View {
        @EnvironmentObject private var state: AppState

        var body: some View {
            PageActionBarSingleAction(
                groupView: AnyView(Group)
            )
        }

        @ViewBuilder var Group: some View {
            Button {

            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Text("Save")
                }
                .padding()
            }
            .background(.green)
            .padding()
            .padding(.bottom, 50)
        }
    }
}
