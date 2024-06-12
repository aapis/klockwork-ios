//
//  Assessables.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI
import CoreData

class Assessables: Identifiable, Equatable {
    typealias EntityType = PageConfiguration.EntityType

    public var id: UUID = UUID()
    var factors: [AssessmentFactor] = []
    var moc: NSManagedObjectContext?
    var score: Int = 0
    var weight: ActivityWeight = .empty
    var date: Date? = Date()
    var statuses: [AssessmentThreshold] = []

    /// Stub for Equatable compliance
    /// - Parameters:
    ///   - lhs: Assessables
    ///   - rhs: Assessables
    /// - Returns: Bool
    static public func == (lhs: Assessables, rhs: Assessables) -> Bool {
        return lhs.id == rhs.id
    }
    
    /// Create a new Assessables object
    /// - Parameters:
    ///   - factors: Optional(Array<AssessmentFactor>)
    ///   - moc: Optional(NSManagedObjectContext)
    init(factors: [AssessmentFactor]? = nil, statuses: [AssessmentThreshold]? = nil, moc: NSManagedObjectContext? = nil) {
        self.id = UUID()

        if moc != nil {
            self.moc = moc!
        }

        if factors != nil {
            self.factors = factors!
        }

        if let stats = statuses {
            self.statuses = stats
        }

        self.evaluate()
    }

    /// Shortcut for self.factors.isEmpty
    /// - Returns: Bool
    func isEmpty() -> Bool {
        return factors.isEmpty
    }
    
    /// Filters assessment factors by the given type
    /// - Parameter type: EntityType
    /// - Returns: Array<AssessmentFactor>
    func byType(_ type: EntityType) -> [AssessmentFactor] {
        return self.sorted().filter({$0.type == type.label})
    }
    
    /// Sort by count
    /// - Returns: Array<AssessmentFactor>
    func sorted() -> [AssessmentFactor] {
        return self.factors.sorted(by: {$0.count > $1.count})
    }
    
    /// Filter out factors that we don't want to consider because they fall below the user's threshold
    /// - Returns: Array<AssessmentFactor>
    func active() -> [AssessmentFactor] {
        return self.sorted().filter({$0.count >= $0.threshold})
    }
    
    /// Find all unused factors
    /// - Returns: Array<AssessmentFactor>
    func inactive() -> [AssessmentFactor] {
        return self.sorted().filter({$0.count <= $0.threshold})
    }
    
    /// Destroy all factors for this Assessable
    /// - Returns: Void
    func clear() -> Void {
        self.factors = []
        self.score = 0
    }
    
    /// Calculates the score based on the weight, threshold and entity count factors of a given assessment factor
    /// - Returns:Void
    func calculateScore() -> Void {
        self.score = 0

        for factor in self.factors {
            factor.count = factor.countFactors(using: self.moc!, for: self.date)

            let weighted = Int64(factor.count * factor.weight)

            if weighted >= factor.threshold {
                self.score += Int(weighted)
            }
        }
    }

    /// Determines the factor's weight
    /// @TODO: move to ActivityWeightAssessment
    /// @TODO: also this sucks
    /// - Returns: Void
    func weigh(with statuses: [AssessmentThreshold]?) -> Void {
        if let moc = self.moc {
            if let stats = statuses {
//                print("DERPO should work")
                for (idx, status) in stats.enumerated() {
                    //                var prev: Int = statuses.count - 1
                    //                var current: Int = idx
                    //                var next: Int = idx + 1
                    //
                    //                if statuses.endIndex <= next {
                    //                    current += 1
                    //                    next += 1
                    //
                    //                    let nextStatus = statuses[next]
                    ////                    if status.value nextStatus.value
                    //                } else {
                    //                    next = current
                    //                    current -= 1
                    //                    prev -= 1
                    //                }
                    //
                    let bounds = (status.value, Int64(status.value + 10))

                    switch status.label {
                    case "Clear":
                        if self.score == 0 {
                            self.weight = .empty
                        }
                    case "Light":
                        if self.score > 0 && self.score <= status.value {
                            print("DERPO light \(self.score) <= \(status.value)")
                            self.weight = .light
                        }
                    case "Busy":
                        if self.score >= bounds.0 && self.score <= bounds.1 {
                            print("DERPO busy \(self.score) <= \(status.value)")
                            self.weight = .medium
                        }
                    case "At Capacity":
                        if self.score >= bounds.0 && self.score <= bounds.1 {
                            print("DERPO at capacity \(self.score) <= \(status.value)")
                            self.weight = .heavy
                        }
                    case "Overloaded":
                        if self.score >= bounds.0 && self.score <= bounds.1 {
                            print("DERPO overloaded \(self.score) >= \(status.value)")
                            self.weight = .significant
                        }
                    case .none:
                        print("DERPO none triggered")
                        self.weight = .empty
                    case .some(_):
                        print("DERPO SOME triggered")
                        self.weight = .light
                    }
                }
            }
        } else {
//            print("DERPO fail")
            // Use default, hardcoded values if we don't have a MOC
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
    
    /// Weigh and score the factors
    /// - Returns: Void
    func evaluate(with statuses: [AssessmentThreshold]? = nil) -> Void {
        self.calculateScore()
        
        var stats: [AssessmentThreshold] = []
        if statuses != nil {
            stats = statuses!
        } else {
            stats = self.statuses
        }

        if stats.count > 0 {
            self.weigh(with: stats)
        }
    }
    
    // @TODO: activeToggle(), threshold(), weight() probably shouldn't exist (or, shouldn't exist here anyways)
    /// Modify and save the active status on a given AssessmentFactor
    /// - Parameter factor: AssessmentFactor
    /// - Returns: Void
    func activeToggle(factor: AssessmentFactor) -> Void {
        factor.alive.toggle()
        PersistenceController.shared.save()
//        self.evaluate()
    }
    
    /// Modify and save the threshold of a given AssessmentFactor
    /// - Parameters:
    ///   - factor: AssessmentFactor
    ///   - threshold: Int
    /// - Returns: Void
    func threshold(factor: AssessmentFactor, threshold: Int) -> Void {
        factor.threshold = Int64(threshold)
        PersistenceController.shared.save()
//        self.evaluate()
    }
    
    /// Modify and save the weight for a given AssessmentFactor
    /// - Parameters:
    ///   - factor: AssessmentFactor
    ///   - weight: Int
    /// - Returns: Void
    func weight(factor: AssessmentFactor, weight: Int) -> Void {
        factor.weight = Int64(weight)
        PersistenceController.shared.save()
//        self.evaluate()
    }
}
