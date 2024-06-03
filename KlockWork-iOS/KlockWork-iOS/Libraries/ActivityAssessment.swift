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
    private var factors: [AssessmentFactor] = []
    public var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    public var assessables: Assessables
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
        self.factors = CDAssessmentFactor(moc: self.moc).all(for: self.date)
        self.assessables = Assessables(factors: self.factors, moc: self.moc)

        if self.assessables.isEmpty {
            self.createFactorsFromDefaults()
        }

        self.perform()
    }
}

// MARK: method definitions
extension ActivityAssessment {
    /// Perform the assessment by iterating over all the things and calculating the score
    /// - Returns: Void
    private func perform() -> Void {
        // record the reason for this score increase
        for factor in self.assessables.active() {
            self.factors.append(factor)
        }

        self.score = self.assessables.score
        self.weight = self.assessables.weight
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
    private func createFactorsFromDefaults() -> Void {
        for factor in self.defaultFactors {
            self.assessables.factors.append(factor.create(using: self.moc))
        }

        PersistenceController.shared.save()
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

extension ActivityAssessment.ViewFactory.Factor {
    private func actionOnAppear() -> Void {
        weight = Int(self.factor.weight)

        if let desc = self.factor.desc {
            description = desc
        }

        count = Int(self.factor.count)
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

    public struct DefaultAssessmentFactor {
        var id = UUID()
        var alive: Bool = true
        var count: Int64 = 0
        var desc: String = "Sample description"
        var date: Date = Date()
        var created: Date = Date()
        var lastUpdate: Date = Date()
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
            af.weight = self.weight
            af.type = self.type.label
            af.action = self.action.label
            return af
        }

        func count(moc: NSManagedObjectContext) -> Int64 {
            switch self.type {
            case .records:
                switch self.action {
                case .create:
                    return Int64(CoreDataRecords(moc: moc).countRecords(for: self.date))
                case .interaction:
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
                    return Int64(CoreDataTasks(moc: moc).countByDate(for: self.date))
                }
            case .notes:
                switch self.action {
                case .create:
                    return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date))
                case .interaction:
                    return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date))
                }
//            case .companies:
//            case .people:
//            case .projects:
            default:
                return Int64(0)
            }
        }
    }

    public class Assessables: Identifiable, Equatable {
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

            self.calculateScore()
            self.weigh()
        }

        func byType(_ type: EntityType) -> [AssessmentFactor] {
            return self.sorted().filter({$0.type == type.label})
        }

        func sorted() -> [AssessmentFactor] {
            return self.factors.sorted(by: {$0.count > $1.count})
        }

        func active() -> [AssessmentFactor] {
            return self.sorted().filter({$0.count > 0})
        }

        func inactive() -> [AssessmentFactor] {
            return self.sorted().filter({$0.count == 0})
        }

        func clear() -> Void {
            self.factors = []
        }

        func activeToggle(factor: AssessmentFactor) -> Void {
            factor.alive.toggle()
            PersistenceController.shared.save()
        }

        func refresh(date: Date) -> Void {
            self.factors = CDAssessmentFactor(moc: self.moc).all(for: date)
        }

        func calculateScore() -> Void {
            for factor in self.active() {
                let weighted = Int64(factor.count * factor.weight)

                if weighted > 0 {
                    self.score += Int(weighted)
                }
            }
        }

        func weigh() -> Void {
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
                                Factor(factor: factor, callback: self.callback)
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

            private func callback(factor: AssessmentFactor) -> Void {
                assessables.activeToggle(factor: factor)
            }

            private func actionOnAppear() -> Void {
                self.factors = assessables.byType(type)
            }
        }

        struct Factor: View {
            @Environment(\.managedObjectContext) var moc
            public let factor: AssessmentFactor
            public let callback: (AssessmentFactor) -> Void
            @State private var weight: Int = 0
            @State private var description: String = ""
            @State private var count: Int = 0

            var body: some View {
                HStack(alignment: .center, spacing: 10) {
                    Button {
                        self.callback(factor)
                    } label: {
                        Image(systemName: count == 0 ? "plus" : "xmark")
                    }
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.yellow)
                    .help("Disable this assessment factor")

                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 10) {
                        GridRow(alignment: .top) {
                            Text("Description")
                            Text("Weight")
                        }
                        .foregroundStyle(.gray)
                        .padding([.top, .leading, .trailing])

                        Divider()
                            .background(.gray)

                        GridRow {
                            HStack {
                                Text(description)
                                Spacer()
                            }
                            Picker("Weight", selection: $weight) {
                                ForEach(0..<6) { Text($0.string)}
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                    .background(count == 0 ? Theme.base : Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .onAppear(perform: self.actionOnAppear)
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
