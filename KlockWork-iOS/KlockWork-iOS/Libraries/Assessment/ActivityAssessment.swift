//
//  ActivityAssessment.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI
import CoreData

public class ActivityAssessment {
    public var date: Date
    public var moc: NSManagedObjectContext
    public var weight: ActivityWeight = .empty
    public var score: Int = 0
    public var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    @Published public var assessables: Assessables
    private var defaultFactors: [FactorProxy] {
        return [
            FactorProxy(date: self.date, weight: 1, type: .records, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .jobs, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .jobs, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .tasks, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .tasks, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .notes, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .notes, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .companies, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .companies, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .people, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .people, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .projects, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .projects, action: .interaction)
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
