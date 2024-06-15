//
//  Planning.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Planning: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var text: String = ""
    @State private var job: Job? = nil
    @State private var selected: PlanType = .daily
    private let page: PageConfiguration.AppPage = .planning

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(page: self.page)
                Divider().background(.gray).frame(height: 1)
                PlanTabs(
                    inSheet: true,
                    job: $job,
                    selected: $selected
                )
                
                Spacer()
            }
            .background(page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
        }
    }
}

extension Planning {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State private var date: Date = Date()
        public let page: PageConfiguration.AppPage

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text("Planning")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.leading, .top, .bottom])
                        .overlay {
                            DatePicker(
                                "Date picker",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .contentShape(Rectangle())
                            .opacity(0.011)
                        }
                    Image(systemName: "chevron.right")
                    Spacer()
                    LargeDateIndicator(page: self.page)
                }
                Spacer()
            }
            .onAppear(perform: {
                date = self.state.date

                // @TODO: obviously for testing
                let testJobs = CoreDataJob(moc: self.state.moc).all().filter({$0.title == JobDetail.defaultTitle})
                for job in testJobs {
                    self.state.moc.delete(job)
                    print("DERPO DELETED job=\(job.title!) job.id=\(job.jid.string)")
                }

                let projects = CoreDataProjects(moc: self.state.moc).all().filter({$0.name == ProjectDetail.defaultName})
                for entity in projects {
                    self.state.moc.delete(entity)
                    print("DERPO DELETED project=\(entity.name!)")
                }

                let tasks = CoreDataTasks(moc: self.state.moc).all().filter({$0.content == TaskDetail.defaultContent})
                for entity in tasks {
                    self.state.moc.delete(entity)
                    print("DERPO DELETED task=\(entity.content!)")
                }

                let companies = CoreDataCompanies(moc: self.state.moc).indescriminate().filter({$0.name == CompanyDetail.defaultName})
                for entity in companies {
                    self.state.moc.delete(entity)
                    print("DERPO DELETED company=\(entity.name!)")
                }

                let notes = CoreDataNotes(moc: self.state.moc).all().filter({$0.title == NoteDetail.defaultTitle})
                for note in notes {
                    self.state.moc.delete(note)
                    print("DERPO DELETED note=\(note.title!)")
                }
            })
            .onChange(of: date) {
                self.state.date = date
            }
        }
    }

    struct Content: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var text: String

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                Text("Coming soon!")
                    .padding()
                Spacer()
            }
        }
    }
}
