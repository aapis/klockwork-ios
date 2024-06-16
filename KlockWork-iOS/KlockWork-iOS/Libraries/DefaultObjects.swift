//
//  DefaultObjects.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-16.
//

import SwiftUI

class DefaultObjects {
    /// A temporary Project to pass to the view
    static public var project: Project {
        return CoreDataProjects(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            name: ProjectDetail.defaultName,
            abbreviation: "ARGPN",
            colour: Color.random().toStored(),
            created: Date(),
            pid: 1,
            saveByDefault: false
        )
    }
    /// A temporary Job to pass to the view
    static public var job: Job {
        return CoreDataJob(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            alive: true,
            colour: Color.randomStorable(),
            jid: 0.0,
            overview: "I'm the overview, edit me",
            shredable: false,
            title: JobDetail.defaultTitle,
            uri: "https://",
            project: self.project,
            saveByDefault: false
        )
    }
    /// A temporary LogTask to pass to the view
    static public var task: LogTask {
        return CoreDataTasks(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            content: TaskDetail.defaultContent,
            created: Date(),
            job: self.job,
            saveByDefault: false
        )
    }
    /// A temporary Note to pass to the view
    static public var note: Note {
        return CoreDataNotes(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            alive: true,
            body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae enim ut elit vestibulum fringilla.",
            lastUpdate: Date(),
            postedDate: Date(),
            starred: false,
            title: NoteDetail.defaultTitle,
            job: self.job,
            saveByDefault: false
        )
    }
}
