//
//  DefaultObjects.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-16.
//

import SwiftUI

class DefaultObjects {
    /// Default Project object, either created or retrieved from CD
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

    /// Default Job object, either created or retrieved from CD
    static public var job: Job {
        return CoreDataJob(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            alive: true,
            colour: Color.randomStorable(),
            jid: 0.0,
            overview: "I'm the overview, edit me",
            shredable: false,
            title: JobDetail.defaultTitle,
            uri: "https://",
            project: DefaultObjects.project,
            saveByDefault: false
        )
    }

    /// Default LogTask object, either created or retrieved from CD
    static public var task: LogTask {
        return CoreDataTasks(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            content: TaskDetail.defaultContent,
            created: Date(),
            due: Date(),
            job: DefaultObjects.job,
            saveByDefault: false
        )
    }

    /// Default Note object, either created or retrieved from CD
    static public var note: Note {
        return CoreDataNotes(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            alive: true,
            body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae enim ut elit vestibulum fringilla.",
            lastUpdate: Date(),
            postedDate: Date(),
            starred: false,
            title: NoteDetail.defaultTitle,
//            job: DefaultObjects.job,
            saveByDefault: false
        )
    }

    /// Default Company object, either created or retrieved from CD
    static public var company: Company {
        return CoreDataCompanies(moc: PersistenceController.shared.container.viewContext).createAndReturn(
            name: CompanyDetail.defaultName,
            abbreviation: "II",
            colour: Color.randomStorable(),
            created: Date(),
            updated: Date(),
            projects: NSSet(array: []),
            isDefault: false,
            pid: 2,
            saveByDefault: false
        )
    }
    
    /// Delete all default objects
    /// - Returns: Void
    static public func deleteDefaultObjects() -> Void {
        DefaultObjects.deleteDefaultJobs()
        DefaultObjects.deleteDefaultProjects()
        DefaultObjects.deleteDefaultTasks()
        DefaultObjects.deleteDefaultCompanies()
        DefaultObjects.deleteDefaultNotes()
    }
    
    /// Delete all default Job objects
    /// - Returns: Void
    static public func deleteDefaultJobs() -> Void {
        let testJobs = CoreDataJob(moc: PersistenceController.shared.container.viewContext).all().filter({$0.title == JobDetail.defaultTitle})
        for job in testJobs {
            PersistenceController.shared.container.viewContext.delete(job)
            print("DERPO DELETED job=\(job.title!) job.id=\(job.jid.string)")
        }
    }

    /// Delete all default Project objects
    /// - Returns: Void
    static public func deleteDefaultProjects() -> Void {
        let projects = CoreDataProjects(moc: PersistenceController.shared.container.viewContext).all().filter({$0.name == ProjectDetail.defaultName})
        for entity in projects {
            PersistenceController.shared.container.viewContext.delete(entity)
            print("DERPO DELETED project=\(entity.name!)")
        }
    }

    /// Delete all default LogTask objects
    /// - Returns: Void
    static public func deleteDefaultTasks() -> Void {
        let tasks = CoreDataTasks(moc: PersistenceController.shared.container.viewContext).all().filter({$0.content == TaskDetail.defaultContent})
        for entity in tasks {
            PersistenceController.shared.container.viewContext.delete(entity)
            print("DERPO DELETED task=\(entity.content!)")
        }
    }

    /// Delete all default Company objects
    /// - Returns: Void
    static public func deleteDefaultCompanies() -> Void {
        let companies = CoreDataCompanies(moc: PersistenceController.shared.container.viewContext).indescriminate().filter({$0.name == CompanyDetail.defaultName})
        for entity in companies {
            PersistenceController.shared.container.viewContext.delete(entity)
            print("DERPO DELETED company=\(entity.name!)")
        }
    }

    /// Delete all default Note objects
    /// - Returns: Void
    static public func deleteDefaultNotes() -> Void {
        let notes = CoreDataNotes(moc: PersistenceController.shared.container.viewContext).all().filter({$0.title == NoteDetail.defaultTitle})
        for note in notes {
            PersistenceController.shared.container.viewContext.delete(note)
            print("DERPO DELETED note=\(note.title!)")
        }
    }
}
