//
//  PageActionBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-08.
//

import SwiftUI

/// Page action bar whose primary functionality occurs through interaction with another sheet
struct PageActionBar: View {
    @Environment(\.managedObjectContext) var moc
    @State public var groupView: AnyView? = AnyView(EmptyView())
    @State public var sheetView: AnyView? = AnyView(EmptyView())
    @Binding public var isSheetPresented: Bool

    var body: some View {
        VStack(alignment: .leading) {
            groupView
        }
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
        .padding()
        .sheet(isPresented: $isSheetPresented) {
            sheetView
        }
    }
}

/// An action bar meant to perform a single action
/// @TODO: rename, this is criminal
struct PageActionBarSingleAction: View {
    @Environment(\.managedObjectContext) var moc
    @State public var groupView: AnyView? = AnyView(EmptyView())

    var body: some View {
        VStack {
            Button {

            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Text("Save")
                    Spacer()
                }
                .padding()
                .background(self.page.primaryColour)
                .clipShape(.capsule(style: .continuous))
                .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
            }
        }
        .padding()
        .padding(.bottom, 50)
    }
}
