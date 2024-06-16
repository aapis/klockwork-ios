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
    

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 30) {
                PageLink(label: "Job", target: AnyView(JobDetail.Sheet(job: DefaultObjects.job, isPresented: $isPresented)), page: self.page)
                PageLink(label: "Task", target: AnyView(TaskDetail.Sheet(task: DefaultObjects.task, isPresented: $isPresented)), page: self.page)
                PageLink(label: "Note", target: AnyView(NoteDetail.Sheet(note: DefaultObjects.note, isPresented: $isPresented)), page: self.page)
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

struct ContainerView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
    }
}
