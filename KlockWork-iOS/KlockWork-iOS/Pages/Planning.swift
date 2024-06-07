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

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(date: $date)
                Divider().background(.gray).frame(height: 1)
                PlanTabs(
                    inSheet: true,
                    job: $job,
                    selected: $selected,
                    date: $date
                )
                
                Spacer()
            }
            .background(Theme.cOrange)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

extension Planning {
    struct Header: View {
        @Binding public var date: Date
        private var isToday: Bool {
            Calendar.autoupdatingCurrent.isDateInToday(date)
        }

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Planning")
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
                    Spacer()
                    Button {

                    } label: {
                        Text("\(date.formatted(date: .abbreviated, time: .omitted))")
                        .padding(7)
                        .background(self.isToday ? .yellow : Theme.rowColour)
                        .foregroundStyle(self.isToday ? Theme.cOrange : .white)
                        .fontWeight(.bold)
                        .cornerRadius(7)
                    }
                    .padding(.trailing)
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
