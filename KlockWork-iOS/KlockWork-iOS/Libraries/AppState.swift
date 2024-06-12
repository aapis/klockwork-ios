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
    @Published var assessment: ActivityAssessment = ActivityAssessment()
    @Published var date: Date = Date()
}

class ActivityAssessment: ObservableObject {
    typealias Statuses = [AssessmentThreshold]
    @Published var statuses: Statuses = []
}
