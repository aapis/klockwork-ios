//
//  PageActionBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-08.
//

import SwiftUI

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
