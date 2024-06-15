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
    @EnvironmentObject private var state: AppState
    public let page: PageConfiguration.AppPage
    @Binding public var isSheetPresented: Bool

    var body: some View {
        VStack {
            Button {
                self.isSheetPresented.toggle()
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Text("Save")
                        .bold()
                    Spacer()
                }
            }
            .padding()
            .background(self.page.primaryColour.opacity(0.5))
            .background(.green.opacity(0.4))
        }
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
        .padding()
        .padding(.bottom, 50)
    }
}
