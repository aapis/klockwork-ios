//
//  ActivityCalendar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI

struct ActivityCalendar: View {
    @Environment(\.managedObjectContext) var moc
    @State private var month: String = "_DEFAULT_MONTH"
    @State private var week: Int = 0
    @State private var days: [Day] = []
    @State private var open: Bool = true
    private var weekdays: [DayOfWeek] = [
        DayOfWeek(symbol: "Sun"),
        DayOfWeek(symbol: "Mon"),
        DayOfWeek(symbol: "Tues"),
        DayOfWeek(symbol: "Wed"),
        DayOfWeek(symbol: "Thurs"),
        DayOfWeek(symbol: "Fri"),
        DayOfWeek(symbol: "Sat")
    ]

    @AppStorage("activeDate") public var ad: Double = Date.now.timeIntervalSinceReferenceDate
    private var activeDate: Date {
        set {ad = newValue.timeIntervalSinceReferenceDate}
        get {return Date(timeIntervalSinceReferenceDate: ad)}
    }

    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 5) {
                    GridRow(alignment: .center) {
                        Button {
                            open.toggle()
                        } label: {
                            HStack {
                                Text("Activity Calendar")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: open ? "chevron.up" : "chevron.down")
                            }
                            .padding()
                            .background(Theme.rowColour)
                        }
                    }

                    if open {
                        // Month row
                        GridRow {
                            Text(self.month)
                        }
                        .padding([.top, .leading, .trailing])

                        // Day of week
                        GridRow {
                            LazyVGrid(columns: self.columns, alignment: .center) {
                                ForEach(weekdays) {sym in
                                    Text(sym.symbol)
                                }
                                .font(.caption)
                            }
                        }
                        .padding()
                        .border(width: 1, edges: [.bottom], color: Theme.rowColour)

                        // Days
                        GridRow {
                            LazyVGrid(columns: self.columns, alignment: .leading) {
                                ForEach(days) {view in view}
                            }
                        }
                        .padding([.leading, .trailing, .bottom])
                    }
                }
                .background(Theme.rowColour)

                Spacer()
            }
            .scrollContentBackground(.hidden)
        }
        .padding()
        .onAppear(perform: actionOnAppear)
    }
}

extension ActivityCalendar {
    private func actionOnAppear() -> Void {
        // Don't regenerate the calendar if there is data
        if days.count > 0 {
            return
        }

        // Get month string from date
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: activeDate)

        // Create array of days which will render as buttons in the calendar
        let calendar = Calendar.autoupdatingCurrent
        if let interval = calendar.dateInterval(of: .month, for: activeDate) {
            let numDaysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end)
            let adComponents = calendar.dateComponents([.day, .month, .year], from: activeDate)

            if numDaysInMonth.day != nil {
                // Easiest way to make it look like a calendar is to bump the first row of Day's over by the first day
                // of the month's weekdayOrdinal value
                let firstDayComponents = calendar.dateComponents(
                    [.weekdayOrdinal],
                    from: DateHelper.startAndEndOf(activeDate).0
                )

                if let ordinal = firstDayComponents.weekdayOrdinal {
                    for _ in 0...(ordinal - 1) {
                        days.append(
                            Day(
                                day: 0,
                                isToday: false
                            )
                        )
                    }
                }

                // Append the real Day objects
                for idx in 1...numDaysInMonth.day! {
                    if let dayComponent = adComponents.day {
                        let components = DateComponents(year: adComponents.year, month: adComponents.month, day: idx)
                        if let date = Calendar.autoupdatingCurrent.date(from: components) {
                            if let weekday = Calendar.autoupdatingCurrent.dateComponents([.weekday], from: date).weekday {
                                days.append(
                                    Day(
                                        day: idx,
                                        isToday: dayComponent == idx,
                                        isWeekend: weekday > 5 && weekday <= 7,
                                        assessment: CoreDataAggregate(moc: moc).assess(date: date)
                                    )
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ActivityCalendar {
    struct Day: View, Identifiable {
        public let id: UUID = UUID()
        public let day: Int
        public let isToday: Bool
        public var isWeekend: Bool? = false
        public var assessment: ActivityAssessment?
        @State private var bgColour: Color = .clear
        private let gridSize: CGFloat = 40

        var body: some View {
            NavigationLink {
                VStack {
                    if assessment != nil {
                        Text("Score \(assessment!.score)")
                        Text("Date \(assessment!.date)")
                    } else {
                        Text("Unable to assess")
                    }
                }
            } label: {
                if self.day > 0 {
                    Text(String(self.day))
                }
            }
            .frame(minWidth: self.gridSize, minHeight: self.gridSize)
            .background(self.bgColour)
            .onAppear(perform: actionOnAppear)
        }
    }

    struct DayOfWeek: Identifiable {
        let id: UUID = UUID()
        let symbol: String
    }
}

extension ActivityCalendar.Day {
    private func actionOnAppear() -> Void {
        if assessment != nil {
            if isToday {
                bgColour = .blue
            } else {
                if isWeekend! {
                    // IF we did find that you worked on the weekend, highlight the tile in red
                    if assessment!.weight != .light {
                        bgColour = .red
                    } else {
                        bgColour = .clear
                    }
                } else {
                    bgColour = assessment!.weight.colour
                }

            }
        }
    }
}
