//
//  Factor.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI
import CoreData

struct FactorProxy {
    typealias EntityType = PageConfiguration.EntityType

    var id = UUID()
    var alive: Bool = true
    var count: Int64 = 0
    var desc: String = "Sample description"
    var date: Date?
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
        af.desc = "\(af.count) \(af.count > 1 ? self.type.label : self.type.enSingular) \(af.count > 1 ? self.action.enPlural : self.action.enSingular))"
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
        if self.date == nil {
            return Int64(0)
        }

        switch self.type {
        case .records:
            switch self.action {
            case .create, .interaction:
                return Int64(CoreDataRecords(moc: moc).countRecords(for: self.date!))
            }
        case .jobs:
            switch self.action {
            case .create:
                return Int64(CoreDataJob(moc: moc).countByDate(for: self.date!))
            case .interaction:
                return Int64(CoreDataRecords(moc: moc).countJobs(for: self.date!))
            }
        case .tasks:
            switch self.action {
            case .create:
                return Int64(CoreDataTasks(moc: moc).countByDate(for: self.date!))
            case .interaction:
                return Int64(CoreDataTasks(moc: moc).countByDate(for: self.date!)) // @TODO: change query
            }
        case .notes:
            switch self.action {
            case .create:
                return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date!))
            case .interaction:
                return Int64(CoreDataNotes(moc: moc).countByDate(for: self.date!)) // @TODO: change query
            }
//            case .companies:
//            case .people:
//            case .projects:
        default:
            return Int64(0)
        }
    }
}

