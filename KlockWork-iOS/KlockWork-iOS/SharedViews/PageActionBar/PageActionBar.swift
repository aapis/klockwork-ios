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
    @Binding public var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading) {
            groupView
        }
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
        .padding()
        .sheet(isPresented: $isPresented) {
            sheetView
        }
    }
}

/// An action bar meant to perform a single action
/// @TODO: rename, this is criminal
struct PageActionBarSingleAction: View {
    public let page: PageConfiguration.AppPage
    @Binding public var job: Job?
    public let onSave: () -> Void

    var body: some View {
        VStack {
            Button {
                self.onSave()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus.circle.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    Text("Save note")
                        .bold()
                    Spacer()
                }
            }
            .padding(8)
            .background((job?.backgroundColor ?? self.page.primaryColour).opacity(0.4))
        }
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
        .padding()
    }
}

//#Preview {
//    PageActionBarSingleAction(page: .today)
//}
