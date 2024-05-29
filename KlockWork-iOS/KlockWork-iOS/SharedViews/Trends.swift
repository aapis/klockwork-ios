//
//  Trends.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI
import CoreData

struct Trends: View {
    typealias MData = ActivityAssessment.ViewFactory.MonthData

    @Environment(\.managedObjectContext) var moc
    @State private var date: Date = Date()
    @State private var open: Bool = false
    @State private var data: MData?

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 5) {
            GridRow(alignment: .center) {
                Button {
                    open.toggle()
                } label: {
                    HStack {
                        Text("Trends")
                            .font(.title)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: open ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(Theme.rowColour)
                    .border(width: 1, edges: [.bottom], color: Theme.rowColour)
                }
            }

            if open {
                GridRow {

                }
            }
        }
        .background(Theme.rowColour)
        .border(width: 1, edges: [.bottom, .trailing], color: .black.opacity(0.2))
    }

    init() {
//        self.data = MData(date: Date())
    }
}
