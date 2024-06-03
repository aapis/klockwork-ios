//
//  Rollups.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-27.
//

import SwiftUI

extension Calendar {
    static let iso8601 = Calendar(identifier: .iso8601)
}

struct Rollups: View {
    @State private var rollups: [Rollup] = []
    @State private var open: Bool = false

    @AppStorage("activeDate") public var ad: Double = Date.now.timeIntervalSinceReferenceDate
    private var activeDate: Date {
        set {ad = newValue.timeIntervalSinceReferenceDate}
        get {return Date(timeIntervalSinceReferenceDate: ad)}
    }

    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 2)
    }

    static private let daysPrior: Int = 5

    var body: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 5) {
            GridRow(alignment: .center) {
                Button {
                    open.toggle()
                } label: {
                    HStack {
                        Text("Recent")
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
                    VStack(alignment: .leading, spacing: 0) {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(rollups) { rollup in
                                rollup
                            }
                        }
                        Spacer()
                    }
                    .onAppear(perform: self.actionOnDateChange)
                    .onChange(of: activeDate) {
                        self.actionOnDateChange()
                    }
                }
            }
        }
        .background(Theme.rowColour)
        .border(width: 1, edges: [.bottom, .trailing], color: .black.opacity(0.2))
    }

    struct Rollup: View, Identifiable {
        public let id: UUID = UUID()
        public let day: Date

        private var components: DateComponents {
            Calendar.current.dateComponents([.day, .weekday], from: self.day)
        }

        @State private var weekDaySymbol: String = "Mon"

        var body: some View {
            Button {

            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Jobs: XXX")
                    }

                    VStack(alignment: .center, spacing: 5) {
                        Text(String(components.day!))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text(weekDaySymbol)
                            .font(.subheadline)
                    }
                }
                .padding()
                .background(Theme.rowColour)
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension Rollups {
    private func actionOnDateChange() -> Void {
        let pastWeek = DateHelper.prior(numDays: 7, from: activeDate)
        rollups = []

        for day in pastWeek {
            rollups.append(Rollup(day: day))
        }
    }
}

extension Rollups.Rollup {
    private func actionOnAppear() -> Void {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        weekDaySymbol = df.string(from: day)
    }
}
