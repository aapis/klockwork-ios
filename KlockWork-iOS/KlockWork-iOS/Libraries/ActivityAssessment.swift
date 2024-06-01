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
    public var moc: NSManagedObjectContext
    public var weight: ActivityWeightAssessment = .light
    public var score: Int = 0
    public var factors: [AssessmentFactor] = []
    public var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    private var jobsCreated: Int {CoreDataJob(moc: self.moc).countByDate(for: self.date)}
    private var records: Int {CoreDataRecords(moc: self.moc).countRecords(for: self.date)}
    private var jobsReferenced: Int {CoreDataRecords(moc: self.moc).countJobs(for: self.date)}
    private var notesReferenced: Int {CoreDataNotes(moc: self.moc).countByDate(for: self.date)}
    private var tasksReferenced: Int {CoreDataTasks(moc: self.moc).countByDate(for: self.date)}
    private var assessables: [AssessmentFactor] = []

    init(for date: Date, moc: NSManagedObjectContext, searchTerm: String = "") {
        self.date = date
        self.moc = moc
        self.searchTerm = searchTerm

        // @TODO: REMOVE ME! DELETES ALL AF'S!
//        for ass in CDAssessmentFactor(moc: self.moc).all() {
//            self.moc.delete(ass)
//        }
        self.assessables = CDAssessmentFactor(moc: self.moc).all(for: self.date)

        if self.assessables.isEmpty {
            self.createDefaultAssessments()
        }

        self.perform()
    }
}

// MARK: method definitions
extension ActivityAssessment {
    /// Perform the assessment by iterating over all the things and calculating the score
    /// - Returns: Void
    private func perform() -> Void {
        for factor in self.assessables {
            let weighted = Int64(factor.count * factor.weight)

            if weighted > 0 {
                // record the reason for this score increase
                self.factors.append(factor)
                // calculate score
                self.score += Int(weighted)
            }
        }

        self.determineWeight()
    }
    
    /// Determines the weight property
    /// - Returns: Void
    private func determineWeight() -> Void {
        if self.score == 0 {
            self.weight = .empty
        } else if self.score > 1 && self.score < 5 {
            self.weight = .light
        } else if self.score >= 5 && self.score < 10 {
            self.weight = .medium
        } else if self.score > 10 && self.score <= 13 {
            self.weight = .heavy
        } else {
            self.weight = .significant
        }
    }

    /// Creates new AssessmentFactor objects
    /// - Returns: Void
    private func createDefaultAssessments() -> Void {
        let defaultAssesssments: [AssessmentFactor] = [
            self.createAssessment(count: Int64(self.jobsCreated), date: self.date, desc: "\(jobsCreated) new job(s)"),
            self.createAssessment(count: Int64(self.records), date: self.date, desc: "\(records) new record(s)"),
            self.createAssessment(count: Int64(self.jobsReferenced), weight: 2, date: self.date, desc: "\(jobsReferenced) job interaction(s)"),
            self.createAssessment(count: Int64(self.notesReferenced), date: self.date, desc: "\(notesReferenced) note interaction(s)"),
            self.createAssessment(count: Int64(self.tasksReferenced), date: self.date, desc: "\(tasksReferenced) task interaction(s)")
        ]

        for ass in defaultAssesssments {
            do {
                try ass.validateForInsert()

                PersistenceController.shared.save()
            } catch {
                print("[error] ActivityAssessment Failed to create default assessments due to \(error) saving \(ass)")
            }
        }
    }

    /// Creates a new AssessmentFactor object
    /// - Parameters:
    ///   - count: Int64
    ///   - date: Date
    ///   - desc: String
    /// - Returns: AssessmentFactor
    fileprivate func createAssessment(count: Int64, weight: Int = 1, date: Date, desc: String) -> AssessmentFactor {
        let factor = AssessmentFactor(context: self.moc)
        factor.id = UUID()
        factor.alive = true
        factor.count = count
        factor.desc = desc
        factor.date = date
        factor.created = Date()
        factor.lastUpdate = Date()
        factor.weight = Int64(weight)

        return factor
    }
}

// @TODO: move these functions to ViewFactory.MonthData an remove this entirely
extension ActivityAssessment.ViewFactory.Month {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.cumulativeScore = 0

        if self.days.isEmpty {
            self.createTiles()
        }
        
        self.calculateCumulativeScore()

//        self.data = ActivityAssessment.ViewFactory.MonthData(moc: self.moc, date: self.date, cumulativeScore: self.cumulativeScore)
//        print("DERPO month.data=\(self.data!.days)")
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
            [.weekday],
            from: DateHelper.datesAtStartAndEndOfMonth(for: self.date)!.0
        )

        if let ordinal = firstDayComponents.weekday {
            if (ordinal - 2) > 0 {
                for _ in 0...(ordinal - 2) { // @TODO: not sure why this is -2, should be -1?
                    self.days.append(Day(day: 0, isToday: false))
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
                                        assessment: ActivityAssessment(for: date, moc: moc, searchTerm: searchTerm)
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

extension ActivityAssessment.ViewFactory.MonthData {
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
            [.weekday],
            from: DateHelper.datesAtStartAndEndOfMonth(for: self.date)!.0
        )

        if let ordinal = firstDayComponents.weekday {
            for _ in 0...(ordinal - 2) { // @TODO: not sure why this is -2, should be -1?
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
                                        isWeekend: selectorComponents.weekday == 1 || selectorComponents.weekday! == 7,
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
    /// Levels representing an amount of work
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

    /// Create prebuilt views
    struct ViewFactory {
        struct Month: View {
            typealias Day = ActivityCalendar.Day // @TODO: move out of ActivityCalendar
            
            @Environment(\.managedObjectContext) var moc
            @Binding public var date: Date
            @Binding public var cumulativeScore: Int
            public var searchTerm: String
            @State private var days: [Day] = []
            @State private var data: ViewFactory.MonthData?
            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
            }

            var body: some View {
                GridRow {
                    // @TODO: playing with self.data, not functional yet
//                    Text("JKLISD")
//                    if let data = self.data {
//                        LazyVGrid(columns: self.columns, alignment: .leading) {
//                            ForEach(data.days) {view in view}
//                        }
//                    }

                    LazyVGrid(columns: self.columns, alignment: .leading) {
                        ForEach(self.days) {view in view}
                    }
                }
                .padding([.leading, .trailing, .bottom])
                .onAppear(perform: self.actionOnAppear)
//                .onChange(of: self.data) {
//                    if let data = self.data {
//                        data.days = []
//                        self.actionOnAppear()
//                    }
//                }
                .onChange(of: self.date) {
                    self.days = []
                    self.actionOnAppear()
                }
            }
        }

        class MonthData: Equatable {
            typealias Day = ActivityCalendar.Day // @TODO: move out of ActivityCalendar

            public var moc: NSManagedObjectContext
            public var date: Date
            public var cumulativeScore: Int = 0
            public var days: [Day] = []

            static func == (lhs: ActivityAssessment.ViewFactory.MonthData, rhs: ActivityAssessment.ViewFactory.MonthData) -> Bool {
                return lhs.date == rhs.date
            }

            init(moc: NSManagedObjectContext, date: Date, cumulativeScore: Int = 0) {
                self.moc = moc
                self.date = date
                self.cumulativeScore = cumulativeScore

                if self.days.isEmpty {
                    Task {
                        self.createTiles()
                        self.calculateCumulativeScore()
                    }
                }

                print("DERPO days=\(self.days)")
            }
        }
    }
}
