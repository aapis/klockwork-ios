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
    public var weight: ActivityWeightAssessment = .empty
    public var score: Int = 0
    public var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    @Published public var assessables: Assessables
    private var defaultFactors: [DefaultAssessmentFactor] {
        return [
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .records, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .jobs, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .jobs, action: .interaction),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .tasks, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .tasks, action: .interaction),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .notes, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .notes, action: .interaction),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .companies, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .companies, action: .interaction),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .people, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .people, action: .interaction),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .projects, action: .create),
            DefaultAssessmentFactor(date: self.date, weight: 1, type: .projects, action: .interaction)
        ]
    }

    init(for date: Date, moc: NSManagedObjectContext, searchTerm: String = "") {
        self.date = date
        self.moc = moc
        self.searchTerm = searchTerm
        self.assessables = Assessables(
            factors: CDAssessmentFactor(moc: self.moc).all(for: self.date),
            moc: self.moc
        )

        // Create all the AssessmentFactor objects
        if self.assessables.isEmpty {
            for factor in self.defaultFactors {
                self.assessables.factors.append(factor.create(using: self.moc))
            }
        }

        // Perform the assessment by iterating over all the things and calculating the score
        self.score = self.assessables.score
        self.weight = self.assessables.weight
    }
}

// MARK: method definitions
extension ActivityAssessment.ViewFactory.Month {
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
                    self.days.append(Day(day: 0, isToday: false, assessment: ActivityAssessment(for: Date(), moc: moc)))
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

extension ActivityAssessment.ViewFactory.Factor {
    private func actionOnAppear() -> Void {
        weight = Int(self.factor.weight)
        threshold = Int(self.factor.threshold)
        count = Int(self.factor.count)

        if let desc = self.factor.desc {
            description = desc
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

    public struct DefaultAssessmentFactor {
        var id = UUID()
        var alive: Bool = true
        var count: Int64 = 0
        var desc: String = "Sample description"
        var date: Date = Date()
        var created: Date = Date()
        var lastUpdate: Date = Date()
        var threshold: Int64 = 1
        var weight: Int64
        var type: EntityType
        var action: ActionType

        func create(using moc: NSManagedObjectContext) -> AssessmentFactor {
            let af = AssessmentFactor(context: moc)
            af.id = self.id
            af.alive = self.alive
            af.count = self.count(moc: moc)
            af.desc = "\(af.count) \(af.count > 1 ? self.type.label : self.type.enSingular) \(af.count > 1 ? self.action.enPlural : self.action.enSingular)"
            af.date = self.date
            af.created = self.created
            af.lastUpdate = self.lastUpdate
            af.threshold = self.threshold
            af.weight = self.weight
            af.type = self.type.label
            af.action = self.action.label
            return af
        }

        func count(moc: NSManagedObjectContext) -> Int64 {
            switch self.type {
            case .records:
                switch self.action {
                case .create, .interaction:
                    return Int64(CoreDataRecords(moc: moc).countRecords(for: self.date))
                }
            case .jobs:
                switch self.action {
                case .create:
                    return Int64(CoreDataJob(moc: moc).countByDate(for: self.date))
                case .interaction:
                    return Int64(CoreDataRecords(moc: moc).countJobs(for: self.date))
                }
            case .tasks:
                switch self.action {
                case .create:
                    return Int64(CoreDataTasks(moc: moc).countByDate(for: self.date))
                case .interaction:
                    return Int64(CoreDataTasks(moc: moc).countByDate(for: self.date)) // @TODO: change query
                }
            case .notes:
                switch self.action {
                case .create:
                    return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date))
                case .interaction:
                    return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date)) // @TODO: change query
                }
//            case .companies:
//            case .people:
//            case .projects:
            default:
                return Int64(0)
            }
        }
    }

    public class Assessables: Identifiable, Equatable, ObservableObject {
        public var id: UUID = UUID()
        var factors: [AssessmentFactor] = []
        var moc: NSManagedObjectContext
        var isEmpty: Bool {self.factors.isEmpty}
        var score: Int = 0
        var weight: ActivityWeightAssessment = .empty

        static public func == (lhs: ActivityAssessment.Assessables, rhs: ActivityAssessment.Assessables) -> Bool {
            return lhs.id == rhs.id
        }

        init(factors: [AssessmentFactor]? = nil, moc: NSManagedObjectContext) {
            self.id = UUID()
            self.moc = moc

            if factors != nil {
                self.factors = factors!
            }

            self.evaluate()
        }

        func byType(_ type: EntityType) -> [AssessmentFactor] {
            return self.sorted().filter({$0.type == type.label})
        }

        func sorted() -> [AssessmentFactor] {
            return self.factors.sorted(by: {$0.count > $1.count})
        }

        func active() -> [AssessmentFactor] {
            return self.sorted().filter({$0.alive == true && $0.count >= $0.threshold})
        }

        func inactive() -> [AssessmentFactor] {
            return self.sorted().filter({$0.alive == false || $0.count <= $0.threshold})
        }

        func clear() -> Void {
            self.factors = []
        }

        func refresh(date: Date) -> Void {
            self.factors = CDAssessmentFactor(moc: self.moc).all(for: date)
        }

        func calculateScore() -> Void {
            self.score = 0

            for factor in self.active() {
                let weighted = Int64(factor.count * factor.weight)

                if weighted >= factor.threshold {
                    self.score += Int(weighted)
                }
            }
        }

        // @TODO: move to ActivityWeightAssessment
        func weigh() -> Void {
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

        private func evaluate() -> Void {
            self.calculateScore()
            self.weigh()
        }

        func activeToggle(factor: AssessmentFactor) -> Void {
            factor.alive.toggle()
            PersistenceController.shared.save()
            self.evaluate()
        }

        func threshold(factor: AssessmentFactor, threshold: Int) -> Void {
            factor.threshold = Int64(threshold)
            PersistenceController.shared.save()
            self.evaluate()
        }

        func weight(factor: AssessmentFactor, weight: Int) -> Void {
            factor.weight = Int64(weight)
            PersistenceController.shared.save()
            self.evaluate()
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
        }

        struct Factors: View {
            public var assessables: Assessables
            @Binding public var type: EntityType
            @State private var factors: [AssessmentFactor] = []

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if factors.isEmpty {
                            HStack {
                                Text("\(type.label) provide no factors")
                                Spacer()
                            }
                            .padding()
                            .background(Theme.rowColour)
                            .clipShape(.rect(cornerRadius: 16))
                        } else {
                            ForEach(factors) { factor in
                                Factor(factor: factor, assessables: self.assessables)
                            }
                        }
                    }
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.type) {
                        self.actionOnAppear()
                    }
                }
                .padding([.top, .leading, .trailing])
            }

            private func actionOnAppear() -> Void {
                self.factors = assessables.byType(type)
            }
        }

        struct Factor: View {
            @Environment(\.managedObjectContext) var moc
            public let factor: AssessmentFactor
            public let assessables: Assessables
            @State private var weight: Int = 0
            @State private var description: String = ""
            @State private var count: Int = 0
            @State private var threshold: Int = 1

            var body: some View {
                HStack(alignment: .center, spacing: 10) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 10) {
                        GridRow(alignment: .top) {
                            HStack {
                                Text("Description")
                                Spacer()
                                Text("Threshold")
                                Text("Weight")
                            }
                        }
                        .foregroundStyle(.gray)
                        .padding([.top, .leading, .trailing])

                        Divider()
                            .background(.gray)

                        GridRow {
                            HStack {
                                Text(description)
                                Spacer()
                                Picker("Threshold", selection: $threshold) {
                                    ForEach(0..<10) { Text($0.string)}
                                }
                                Picker("Weight", selection: $weight) {
                                    ForEach(0..<6) { Text($0.string)}
                                }
                            }

                        }
                        .padding([.leading, .trailing])
                    }
                    .background(count < threshold ? Theme.base : Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.threshold) {self.assessables.threshold(factor: self.factor, threshold: self.threshold)}
                .onChange(of: self.weight) {self.assessables.weight(factor: self.factor, weight: self.weight)}
            }

            private func smartDisableFactor() -> Void {
                self.threshold = count < threshold ? count == 0 ? 0 : 1 : count + 1
            }
        }
    }
}
