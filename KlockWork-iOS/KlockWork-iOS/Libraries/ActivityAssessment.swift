//
//  ActivityAssessment.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI
import CoreData

// MARK: Definition
public class ActivityAssessment {
    public var date: Date
    public var moc: NSManagedObjectContext?
    public var weight: ActivityWeightAssessment = .light
    public var score: Int
    public var factors: [AssessmentFactor] = []
    private var jobsCreated: Int {CoreDataJob(moc: self.moc).countByDate(self.date)}
    private var records: Int {CoreDataRecords(moc: self.moc).countRecords(for: self.date)}
    private var jobsReferenced: Int {CoreDataRecords(moc: self.moc).countJobs(for: self.date)}

    init(for date: Date, moc: NSManagedObjectContext?) {
        self.date = date
        self.moc = moc
        self.score = 0
        self.perform()
    }
}

// MARK: method definitions
extension ActivityAssessment {
    /// Perform the assessment by iterating over all the things and calculating the score
    /// - Returns: Void
    private func perform() -> Void {
        let assessables: [AssessmentFactor] = [
            AssessmentFactor(count: self.jobsCreated, date: self.date, description: "\(jobsCreated) job(s)"),
            AssessmentFactor(count: self.records, date: self.date, description: "\(records) new record(s)"),
            AssessmentFactor(count: self.jobsReferenced, weight: 2, date: self.date, description: "\(jobsReferenced) job(s) interacted with")
        ]

        assessables.forEach { factor in
            let weighted = (factor.count * factor.weight)

            if weighted > 0 {
                // record the reason for this score increase
                self.factors.append(factor)
                // calculate score
                self.score += weighted
            }
        }

        self.determineWeight()
    }
    
    /// Determines the weight property
    /// - Returns: Void
    private func determineWeight() -> Void {
        if self.score == 0 {
            self.weight = .empty
        } else if self.score > 0 && self.score < 5 {
            self.weight = .light
        } else if self.score >= 5 && self.score < 10 {
            self.weight = .medium
        } else if self.score > 10 && self.score <= 13 {
            self.weight = .heavy
        } else {
            self.weight = .significant
        }
    }
}

extension ActivityAssessment.ViewFactory.Month {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.cumulativeScore = 0

        if days.isEmpty {
            self.createTiles()
            self.calculateCumulativeScore()
        }
    }

    /// Calculates the cumulative score for the month
    /// - Returns: Void
    private func calculateCumulativeScore() -> Void {
        for day in self.days {
            if let ass = day.assessment {
                cumulativeScore += ass.score
            }
        }
    }

    /// Easiest way to make it look like a calendar is to bump the first row of Day's over by the first day of the month's weekdayOrdinal value
    /// - Returns: Void
    private func padStartOfMonth() -> Void {
        let firstDayComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.weekdayOrdinal],
            from: DateHelper.startAndEndOf(self.date).0
        )

        if let ordinal = firstDayComponents.weekdayOrdinal {
            for _ in 0...(ordinal - 1) {
                self.days.append(Day(day: 0, isToday: false))
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
                                        isWeekend: selectorComponents.weekday! > 5 && selectorComponents.weekday! <= 7,
                                        assessment: ActivityAssessment(for: date, moc: self.moc)
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


// MARK: Data structures
extension ActivityAssessment {
    public enum ActivityWeightAssessment: CaseIterable {
        case empty, light, medium, heavy, significant

        var colour: Color {
            switch self {
            case .empty: .clear
            case .light: Theme.rowColour
            case .medium: Theme.cYellow
            case .heavy: Theme.cRed
            case .significant: .black
            }
        }

        var label: String {
            switch self {
            case .empty: "Clear"
            case .light: "Light"
            case .medium: "Busy"
            case .heavy: "At Capacity"
            case .significant: "Overloaded"
            }
        }
    }

    public struct AssessmentFactor: Identifiable {
        public var id: UUID = UUID()
        var count: Int
        var weight: Int = 1
        var date: Date
        var description: String
    }

    struct ViewFactory {
        struct Month: View {
            typealias Day = ActivityCalendar.Day // @TODO: move out of ActivityCalendar

            public let moc: NSManagedObjectContext
            @Binding public var date: Date
            @Binding public var cumulativeScore: Int
            @State private var days: [Day] = []
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
                .onAppear(perform: actionOnAppear)
                .onChange(of: date) {
                    self.days = []
                    self.actionOnAppear()
                }
            }
        }
    }
}
