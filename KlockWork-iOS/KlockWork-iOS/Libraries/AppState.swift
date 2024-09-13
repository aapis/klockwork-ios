//
//  SharedData.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-12.
//

import SwiftUI
import CoreData

class AppState: ObservableObject {
    @Published var moc: NSManagedObjectContext = PersistenceController.shared.container.viewContext
    @Published var date: Date = Date()
    @Published var activities: Activities = Activities()
    @Published var theme: AppTheme = AppTheme()
    @Published var today: TodayPage = TodayPage()
    @Published var planning: PlanningPage = PlanningPage()
    @Published var job: Job?
    @Published var plan: Plan?

    init() {
        self.activities.state = self
    }
    
    /// Shortcut for determining if the current AppState.date value is today's date or not
    /// - Returns: Bool
    func isToday() -> Bool {
        return Calendar.autoupdatingCurrent.isDateInToday(self.date)
    }
}

struct AppTheme {
    var tint: Color = .yellow
    var page: PageConfiguration.AppPage = .planning
}

struct TodayPage {
    var job: Job? = nil
    var mode: PageMode = .read
}

struct PlanningPage {
    var selectedDate: Date? = nil
}

class Activities {
    typealias Statuses = [AssessmentThreshold]

    var state: AppState? = nil
    var statuses: Statuses = []
    var assessed: [Assessment] = []
    var searchTerm: String = ""
    var score: Int = 0

    /// Run the assessments for a given day
    /// - Returns: Void
    func assess() -> Void {
        self.assessed = []
        self.createAssessments()
        self.calculateScore()
    }

    /// Calculate overall score for the day by tallying up the factors. Sets self.score
    /// - Returns: Void
    private func calculateScore() -> Void {
        self.score = 0

        for day in self.assessed {
            self.score += day.score
        }
    }

    /// Easiest way to make it look like a calendar is to bump the first row of Day's over by the first day of the month's weekdayOrdinal value
    /// - Returns: Void
    private func createBlankAssessments() -> Void {
        let firstDayComponents = Calendar.autoupdatingCurrent.dateComponents(
            [.weekday],
            from: DateHelper.datesAtStartAndEndOfMonth(for: self.state!.date)!.0
        )

        if let ordinal = firstDayComponents.weekday {
            if (ordinal - 2) > 0 {
                for _ in 0...(ordinal - 2) { // @TODO: not sure why this is -2, should be -1?
                    self.assessed.append(
                        Assessment(
                            assessmentStatuses: &self.state!.activities.statuses,
                            date: Date(),
                            dayNumber: 0,
                            moc: self.state!.moc
                        )
                    )
                }
            }
        }
    }

    /// Creates the required number of tile objects for a given month
    /// - Returns: Void
    private func createAssessments() -> Void {
        let calendar = Calendar.autoupdatingCurrent
        if let interval = calendar.dateInterval(of: .month, for: self.state!.date) {
            let numDaysInMonth = calendar.dateComponents([.day], from: interval.start, to: interval.end)
            let adComponents = calendar.dateComponents([.day, .month, .year], from: self.state!.date)

            if numDaysInMonth.day != nil {
                self.createBlankAssessments()

                // Append the real Day objects
                for idx in 1...numDaysInMonth.day! {
                    if let dayComponent = adComponents.day {
                        let month = adComponents.month
                        let components = DateComponents(year: adComponents.year, month: adComponents.month, day: idx)
                        if let date = calendar.date(from: components) {
                            let selectorComponents = calendar.dateComponents([.weekday, .month], from: date)

                            if selectorComponents.weekday != nil && selectorComponents.month != nil {
                                self.assessed.append(
                                    Assessment(
                                        assessmentStatuses: &self.state!.activities.statuses,
                                        date: date,
                                        dayNumber: idx,
                                        isSelected: dayComponent == idx && selectorComponents.month == month,
                                        isWeekend: selectorComponents.weekday == 1 || selectorComponents.weekday! == 7,
                                        moc: self.state!.moc,
                                        searchTerm: searchTerm
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
