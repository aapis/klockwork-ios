//
//  CreateSheet.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-14.
//
import SwiftUI

struct CreateSheet: View {
    @EnvironmentObject private var state: AppState
    public let page: PageConfiguration.AppPage = .intersitial
    @Binding public var isPresented: Bool
    private var project: Project {
        return CoreDataProjects(moc: self.state.moc).createAndReturn(
            name: "A Really Good Project Name",
            abbreviation: "ARGPN",
            colour: Color.random().toStored(),
            created: Date(),
            pid: 1,
            saveByDefault: false
        )
    }
    private var job: Job {
        return CoreDataJob(moc: self.state.moc).createAndReturn(
            alive: true,
            colour: Color.randomStorable(),
            jid: 0.0,
            overview: "I'm the overview, edit me",
            shredable: false,
            title: "Descriptive job title",
            uri: "https://",
            project: self.project
        )!
    }
    private var task: LogTask {
        return CoreDataTasks(moc: self.state.moc).createAndReturn(
            content: "Sample task content",
            created: Date(),
            job: self.job, // @TODO: this should be optional
            saveByDefault: false
        )
    }
    private var note: Note {
        return CoreDataNotes(moc: self.state.moc).createAndReturn(
            alive: true,
            body: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi vitae enim ut elit vestibulum fringilla.",
            lastUpdate: Date(),
            postedDate: Date(),
            starred: false,
            title: "Sample Note Title",
            saveByDefault: false
        )
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 30) {
                PageLink(label: "Job", target: AnyView(JobDetail.Sheet(job: self.job, isPresented: $isPresented)), page: self.page)
                PageLink(label: "Task", target: AnyView(TaskDetail.Sheet(task: self.task, isPresented: $isPresented)), page: self.page)
                PageLink(label: "Note", target: AnyView(NoteDetail.Sheet(note: self.note, isPresented: $isPresented)), page: self.page)
            }
        }
        .presentationBackground(self.page.primaryColour)
    }

    struct PageLink: View {
        public let label: String
        public let target: AnyView
        public let page: PageConfiguration.AppPage

        var body: some View {
            NavigationLink {
                self.target
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text(self.label)
                }
            }
            .padding()
            .background(self.page.buttonBackgroundColour)
            .clipShape(.capsule(style: .continuous))
            .foregroundStyle(.white)
        }
    }
}

//#Preview {
//    CreateSheet()
//}
