//
//  Factor.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI
import CoreData

class FactorProxy {
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
    var schemaVersion: Int64 = 1

    init(date: Date? = nil, weight: Int64, type: EntityType, action: ActionType) {
        self.id = UUID()
        self.alive = true
        self.count = 0
        self.desc = "Sample description"
        self.date = date
        self.created = Date()
        self.lastUpdate = Date()
        self.threshold = 1
        self.weight = weight
        self.type = type
        self.action = action
        self.schemaVersion = 1
    }

//    func create(using moc: NSManagedObjectContext) -> AssessmentFactor {
//        let af = AssessmentFactor(context: moc)
//        af.id = self.id
//        af.alive = self.alive
//        af.count = self.count(moc: moc)
//        af.date = self.date
//        af.desc = "\(af.count) \(af.count > 1 ? self.type.label : self.type.enSingular) \(af.count > 1 ? self.action.enPlural : self.action.enSingular))"
//        af.created = self.created
//        af.lastUpdate = self.lastUpdate
//        af.schemaVersion = self.schemaVersion
//        af.threshold = self.threshold
//        af.weight = self.weight
//        af.type = self.type.label
//        af.action = self.action.label
//
//        PersistenceController.shared.save()
//        return af
//    }

    func createDefaultFactor(using moc: NSManagedObjectContext) -> Void {
        let af = AssessmentFactor(context: moc)
        af.id = self.id
        af.alive = self.alive
        af.created = self.created
        af.lastUpdate = self.lastUpdate
        af.schemaVersion = self.schemaVersion
        af.threshold = self.threshold
        af.weight = self.weight
        af.type = self.type.label
        af.action = self.action.label

        PersistenceController.shared.save()
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

