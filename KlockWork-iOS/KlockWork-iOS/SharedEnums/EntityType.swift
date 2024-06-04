//
//  Page.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct PageConfiguration {
    enum EntityType: CaseIterable {
        case records, jobs, tasks, notes, companies, people, projects
        
        /// Interface-friendly representation
        var label: String {
            switch self {
            case .records: "Records"
            case .jobs: "Jobs"
            case .tasks: "Tasks"
            case .notes: "Notes"
            case .companies: "Companies"
            case .people: "People"
            case .projects: "Projects"
            }
        }
        
        // @TODO: localize somehow?
        var enSingular: String {
            switch self {
            case .records: "Record"
            case .jobs: "Job"
            case .tasks: "Task"
            case .notes: "Note"
            case .companies: "Company"
            case .people: "Person"
            case .projects: "Project"
            }
        }
        
        /// Associated icon
        var icon: Image {
            switch self {
            case .records: Image(systemName: "tray")
            case .jobs: Image(systemName: "hammer")
            case .tasks: Image(systemName: "checklist")
            case .notes: Image(systemName: "note.text")
            case .companies: Image(systemName: "building.2")
            case .people: Image(systemName: "person.2")
            case .projects: Image(systemName: "folder")
            }
        }
    }
    
    public struct EntityTypePair {
        var key: EntityType
        var value: Int
    }
}
