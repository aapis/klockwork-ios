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
        case daily, feature, upcoming, overdue

        /// Interface-friendly representation
        var label: String {
            switch self {
            case .daily: "Daily"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            case .overdue: "Overdue"
            }
        }

        // @TODO: localize somehow?
        var enSingular: String {
            switch self {
            case .daily: "Day"
            case .feature: "Feature"
            case .upcoming: "Upcoming"
            case .overdue: "Overdue"
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .daily: Image(systemName: "calendar")
            case .feature: Image(systemName: "list.bullet.below.rectangle")
            case .upcoming: Image(systemName: "hourglass")
            case .overdue: Image(systemName: "alarm")
            }
        }

        /// Alternative icon to use when selected
        var selectedIcon: Image {
            switch self {
            case .daily: Image(systemName: "calendar")
            case .feature: Image(systemName: "list.bullet.below.rectangle")
            case .upcoming: Image(systemName: "hourglass.bottomhalf.filled")
            case .overdue: Image(systemName: "alarm.fill")
            }
        }
    }

    enum EntityType: CaseIterable, Equatable {
        case records, tasks, notes, people, companies, projects, jobs, terms

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
            case .terms: "Terms"
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
            case .terms: "Term"
            }
        }

        /// Associated icon
        var icon: Image {
            switch self {
            case .records: Image(systemName: self.iconString)
            case .jobs: Image(systemName: self.iconString)
            case .tasks: Image(systemName: self.iconString)
            case .notes: Image(systemName: self.iconString)
            case .companies: Image(systemName: self.iconString)
            case .people: Image(systemName: self.iconString)
            case .projects: Image(systemName: self.iconString)
            case .terms: Image(systemName: self.iconString)
            }
        }

        /// Alternative icon to use when selected
        var selectedIcon: Image {
            switch self {
            case .records: Image(systemName: self.iconSelectedString)
            case .jobs: Image(systemName: self.iconSelectedString)
            case .tasks: Image(systemName: self.iconSelectedString)
            case .notes: Image(systemName: self.iconSelectedString)
            case .companies: Image(systemName: self.iconSelectedString)
            case .people: Image(systemName: self.iconSelectedString)
            case .projects: Image(systemName: self.iconSelectedString)
            case .terms: Image(systemName: self.iconSelectedString)
            }
        }
        
        /// Icon as string
        var iconString: String {
            switch self {
            case .records: "tray"
            case .tasks: "checklist"
            case .notes: "note.text"
            case .people: "person.2"
            case .companies: "building.2"
            case .projects: "folder"
            case .jobs: "hammer"
            case .terms: "list.bullet.rectangle"
            }
        }

        /// Selected icon as string
        var iconSelectedString: String {
            switch self {
            case .records: "tray.fill"
            case .tasks: "checklist"
            case .notes: "note.text"
            case .people: "person.2.fill"
            case .companies: "building.2.fill"
            case .projects: "folder.fill"
            case .jobs: "hammer.fill"
            case .terms: "list.bullet.rectangle.fill"
            }
        }
    }
    
    enum AppPage: CaseIterable, Equatable {
        case planning, today, explore, find, create, modify, error, intersitial, settings

        var primaryColour: Color {
            switch self {
            case .planning: Theme.cOrange
            case .today, .create, .modify: Theme.cPurple
            case .find: Theme.cRoyal
            case .settings: Color.lightGray()
            case .error, .intersitial: .white
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

    struct CircleIcon: View {
        public let entity: PageConfiguration.EntityType

        var body: some View {
            ZStack {
                Theme.base.opacity(0.3)
                self.entity.icon
                    .font(.caption)
            }
            .mask(Circle())
            .frame(width: 25, height: 25)
        }
    }
}
