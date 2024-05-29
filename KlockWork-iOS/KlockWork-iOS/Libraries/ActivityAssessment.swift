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

// MARK: Data structures
extension ActivityAssessment {
    public enum ActivityWeightAssessment {
        case light, medium, heavy, significant, empty

        var colour: Color {
            switch self {
            case .light: Theme.rowColour
            case .medium: Theme.cYellow
            case .heavy: Theme.cRed
            case .significant: .black
            case .empty: .clear
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
}
