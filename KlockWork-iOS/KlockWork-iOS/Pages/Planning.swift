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

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var text: String = ""
    @State private var job: Job? = nil
    @State private var selected: PlanType = .daily

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header()
                Divider().background(.gray).frame(height: 1)
                PlanTabs(
                    inSheet: true,
                    job: $job,
                    selected: $selected
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
        @EnvironmentObject private var state: AppState
        @State private var date: Date = Date()

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
                        // pass
                    } label: {
                        Text("\(date.formatted(date: .abbreviated, time: .omitted))")
                        .padding(7)
                        .background(self.state.isToday() ? .yellow : Theme.rowColour)
                        .foregroundStyle(self.state.isToday() ? Theme.cOrange : .white)
                        .fontWeight(.bold)
                        .cornerRadius(7)
                    }
                    .padding(.trailing)
                }

                Spacer()
            }
            .onAppear(perform: {
                date = self.state.date
            })
            .onChange(of: date) {
                self.state.date = date
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
