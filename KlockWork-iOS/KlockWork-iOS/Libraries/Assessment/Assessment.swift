//
//  ActivityAssessment.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI
import CoreData

class Assessment {
    typealias EntityType = PageConfiguration.EntityType

    var date: Date?
    var moc: NSManagedObjectContext
    var weight: ActivityWeight = .empty
    var score: Int = 0
    var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    var assessables: Assessables = Assessables()

    init(for date: Date? = nil, moc: NSManagedObjectContext, searchTerm: String = "") {
        self.date = date
        self.moc = moc
        self.searchTerm = searchTerm

        if self.date != nil {
            self.assessables.date = self.date!
            self.assessables.moc = self.moc

            // Create all the AssessmentFactor objects
            self.assessables.factors = CDAssessmentFactor(moc: self.moc).all()

            for factor in self.assessables.factors {
                factor.date = self.date
                factor.count = factor.countFactors(using: self.moc)
            }

            // Perform the assessment by iterating over all the things and calculating the score
            self.assessables.evaluate()
            self.weight = self.assessables.weight
        }
    }
}
