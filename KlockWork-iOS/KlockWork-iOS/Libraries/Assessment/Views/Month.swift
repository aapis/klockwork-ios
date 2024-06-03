//
//  Month.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct Month: View {
    @Environment(\.managedObjectContext) var moc
    @Binding public var date: Date
    @Binding public var cumulativeScore: Int
    public var searchTerm: String
    @State private var days: [Day] = []
//            @State private var data: ViewFactory.MonthData?
    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    }

    var body: some View {
        GridRow {
            LazyVGrid(columns: self.columns, alignment: .leading) {
                ForEach(self.days) {view in view}
            }
        }
        .padding([.leading, .trailing, .bottom])
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.date) {
            self.days = []
            self.actionOnAppear()
        }
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.cumulativeScore = 0

        if self.days.isEmpty {
            self.createTiles()
        }

        self.calculateCumulativeScore()
    }

    /// Calculates the cumulative score for the month
    /// - Returns: Void
    private func calculateCumulativeScore() -> Void {
        for day in self.days {
            cumulativeScore += day.assessment.score
        }
    }

    /// Easiest way to make it look like a calendar is to bump the first row of Day's over by the first day of the month's weekdayOrdinal value
    /// - Returns: Void
    private func padStartOfMonth() -> Void {
        let firstDayComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.weekday],
            from: DateHelper.datesAtStartAndEndOfMonth(for: self.date)!.0
        )

        if let ordinal = firstDayComponents.weekday {
            if (ordinal - 2) > 0 {
                for _ in 0...(ordinal - 2) { // @TODO: not sure why this is -2, should be -1?
                    self.days.append(Day(day: 0, isToday: false, assessment: Assessment(for: Date(), moc: moc), calendarDate: $date))
                }
            }
        }
    }

    /// Creates the required number of tile objects for a given month
    /// - Returns: Void
    private func createTiles() -> Void {
        let calendar = Calendar.autoupdatingCurrent
        if let interval = calendar.dateInterval(of: .month, for: self.date) {
            let numDaysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end)
            let adComponents = calendar.dateComponents([.day, .month, .year], from: self.date)

            if numDaysInMonth.day != nil {
                self.padStartOfMonth()

                // Append the real Day objects
                for idx in 1...numDaysInMonth.day! {
                    if let dayComponent = adComponents.day {
                        let month = adComponents.month
                        let components = DateComponents(year: adComponents.year, month: adComponents.month, day: idx)
                        if let date = Calendar.autoupdatingCurrent.date(from: components) {
                            let selectorComponents = Calendar.autoupdatingCurrent.dateComponents([.weekday, .month], from: date)

                            if selectorComponents.weekday != nil && selectorComponents.month != nil {
                                self.days.append(
                                    Day(
                                        day: idx,
                                        isToday: dayComponent == idx && selectorComponents.month == month,
                                        isWeekend: selectorComponents.weekday == 1 || selectorComponents.weekday! == 7,
                                        assessment: Assessment(for: date, moc: moc, searchTerm: searchTerm),
                                        calendarDate: $date
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
