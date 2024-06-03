//
//  Assessables.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI
import CoreData

public class Assessables: Identifiable, Equatable, ObservableObject {
    public var id: UUID = UUID()
    var factors: [AssessmentFactor] = []
    var moc: NSManagedObjectContext
    var isEmpty: Bool {self.factors.isEmpty}
    var score: Int = 0
    var weight: ActivityWeight = .empty

    static public func == (lhs: Assessables, rhs: Assessables) -> Bool {
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
