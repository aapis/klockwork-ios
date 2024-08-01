//
//  Page.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

struct PageConfiguration {
    let entityType: EntityType
    let planType: PlanType

    var description: String {
        return "Entity"
    }
}

extension PageConfiguration {
    enum PlanType: CaseIterable, Equatable {
        case daily, feature, upcoming

        /// Interface-friendly representation
        var label: String {
            switch self {
            case .daily: "Daily"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            }
        }

        // @TODO: localize somehow?
        var enSingular: String {
            switch self {
            case .daily: "Day"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .daily: Image(systemName: "calendar")
            case .feature: Image(systemName: "list.bullet.below.rectangle")
            case .upcoming: Image(systemName: "hourglass")
            }
        }
    }

    enum EntityType: CaseIterable, Equatable {
        case records, tasks, notes, people, companies, projects, jobs

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

        var selectedIcon: Image {
            switch self {
            case .records: Image(systemName: "tray.fill")
            case .jobs: Image(systemName: "hammer.fill")
            case .tasks: Image(systemName: "checklist")
            case .notes: Image(systemName: "note.text")
            case .companies: Image(systemName: "building.2.fill")
            case .people: Image(systemName: "person.2.fill")
            case .projects: Image(systemName: "folder.fill")
            }
        }
    }
    
    enum AppPage: CaseIterable, Equatable {
        case planning, today, explore, find, create, modify, error, intersitial, settings

        var primaryColour: Color {
            switch self {
            case .planning: Theme.cOrange
            case .today, .create, .modify: Theme.cPurple
            case .error, .intersitial, .settings: .white
            default:
                Theme.cGreen
            }
        }

        var buttonBackgroundColour: Color {
            switch self {
            default:
                Theme.cGreen
            }
        }
    }

    struct EntityTypePair {
        var key: EntityType
        var value: Int
    }
}
