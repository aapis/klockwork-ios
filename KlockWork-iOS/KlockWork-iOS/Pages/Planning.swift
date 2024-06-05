//
//  Planning.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    public var inSheet: Bool
    @Binding public var date: Date
    @Environment(\.managedObjectContext) var moc
    @State private var text: String = ""
    @State private var job: Job? = nil
    @State private var selected: PlanType = .daily

//    var original: some View {
//        NavigationStack {
//            VStack(alignment: .leading, spacing: 0) {
//                Header(date: $date)
//                ZStack(alignment: .bottomLeading) {
////                        Tabs(job: $job, selected: $selected, date: $date)
//                    Content(text: $text)
//                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
//                        .frame(height: 50)
//                        .opacity(0.1)
//                }
//
////                QueryField(prompt: "What can I help you find?", onSubmit: self.actionOnSubmit, text: $text)
//                Spacer().frame(height: 1)
//            }
//            .background(Theme.cOrange)
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar(inSheet ? .visible : .hidden)
//            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
//            .toolbarBackground(.visible, for: .navigationBar)
//        }
//    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(date: $date)
                Divider().background(.gray).frame(height: 1)
                PlanTabs(
                    inSheet: true,
                    job: $job,
                    selected: $selected,
                    date: $date,
                    content: AnyView(
                        Text("Hello")
                        .environment(\.managedObjectContext, moc)
                    )
                )
                Spacer()
            }
            .background(Theme.cOrange)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

extension Planning {
    struct Header: View {
        @Binding public var date: Date

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(Calendar.autoupdatingCurrent.isDateInToday(date) ? "Planning" : date.formatted(date: .abbreviated, time: .omitted))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.leading, .top, .bottom])
                        .overlay {
                            DatePicker(
                                "Date picker",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .contentShape(Rectangle())
                            .opacity(0.011)
                        }
                    Image(systemName: "chevron.right")
                }

                Spacer()
            }
        }
    }

    struct Content: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("Coming soon!")
                    .padding()
                Spacer()
            }
        }
    }
}
