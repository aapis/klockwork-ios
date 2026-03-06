//
//  KlockWorkiOSApp.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI
import SwiftData

// @TODO: copied from KW directly so this project would build again, should be moved or something
public enum Page {
    typealias Conf = PageConfiguration.AppPage
    case dashboard, today, notes, tasks, projects, projectDetail, jobs, companies, companyDetail, planning,
    terms, termDetail, definitions, definitionDetail, taskDetail, noteDetail, people, peopleDetail, explore, activityFlashcards, activityCalendar, recordDetail,
    timeline

    var appPage: Conf {
        switch self {
        case .dashboard: return Conf.find
        case .today: return Conf.today
        case .planning: return Conf.planning
        default: return Conf.explore
        }
    }

    var colour: Color {
        switch self {
        case .dashboard:
            return Conf.find.primaryColour
        case .today:
            return Conf.today.primaryColour
        case .planning:
            return Conf.planning.primaryColour
        default:
            return Conf.explore.primaryColour
        }
    }

    var defaultTitle: String {
        switch self {
        case .dashboard: return "Dashboard"
        case .today: return "Today"
        case .tasks: return "Tasks"
        case .notes: return "Notes"
        case .projects: return "Projects"
        case .projectDetail: return "Project"
        case .jobs: return "Jobs"
        case .companies: return "Companies"
        case .companyDetail: return "Company"
        case .planning: return "Planning"
        case .terms: return "Terms"
        case .termDetail: return "Term"
        case .definitions: return "Definitions"
        case .definitionDetail: return "Definition"
        case .taskDetail: return "Task"
        case .noteDetail: return "Note"
        case .people: return "People"
        case .peopleDetail: return "Person"
        case .explore: return "Explore"
        case .activityCalendar: return "Activity Calendar"
        case .activityFlashcards: return "Flashcards"
        case .recordDetail: return "Record"
        case .timeline: return "Timeline"
        }
    }

    var parentView: Page? {
        switch self {
        case .companyDetail: return .companies
        case .projectDetail: return .projects
        case .definitionDetail: return .definitions
        case .taskDetail: return .tasks
        case .noteDetail: return .notes
        case .peopleDetail: return .people
        case .activityCalendar, .activityFlashcards: return .explore
        case .recordDetail: return .today
        case .timeline: return .explore
        case .termDetail: return .terms
        default: return nil
        }
    }
}

@main
struct KlockWorkiOSApp: App {
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            Main()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

extension Double {
    var string: String {
        return String(format: "%.0f", self)
    }
}
