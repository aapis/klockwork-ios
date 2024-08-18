//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records
    @State private var jobs: [Job] = []
    @State private var isPresented: Bool = false
    @State private var path = NavigationPath()
    @AppStorage("today.viewMode") private var viewMode: Int = 0
    @FocusState private var textFieldActive: Bool
    private let page: PageConfiguration.AppPage = .today
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if !inSheet {
                    Header(page: self.page, path: $path)
                }
                Divider().background(.white).frame(height: 1)
                
                switch(self.viewMode) {
                case 1:
                    Tabs.Content.List.HierarchyExplorer(inSheet: false)
                default:
                    main
                }
            }
            .background(page.primaryColour)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
            .onChange(of: self.job) {self.actionOnJobChange()}
        }
    }

    var main: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Tabs(inSheet: inSheet, job: $job, selected: $selected)
                if !inSheet {
                    // @TODO: each one of these could include the create entity button, but for now it's only relevant to the Records tab
                    if selected == .records {
                        PageActionBar.Today(job: $job, isPresented: $isPresented)
                    }

                    if job != nil {
                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 50)
                            .opacity(0.1)
                    }
                }
            }

            if !inSheet {
                if selected == .records {
                    Editor(job: $job, entityType: $selected, focused: _textFieldActive)
                }

                Spacer().frame(height: 1)
            }
        }
    }
}

extension Today {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = Date()
        @State private var isCreateSheetPresented: Bool = false
        public let page: PageConfiguration.AppPage
        @Binding public var path: NavigationPath

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(Calendar.autoupdatingCurrent.isDateInToday(date) ? "Today" : date.formatted(date: .abbreviated, time: .omitted))
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

                    HStack(alignment: .center, spacing: 8) {
                        AddButton()
                        ViewModeSelector()
                    }
                    .padding(10)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.4)
                            .blendMode(.softLight)
                            .frame(height: 50)
                    )
                    .clipShape(.rect(topLeadingRadius: 16, bottomLeadingRadius: 16))
                }
            }
            .onAppear(perform: {
                self.date = self.state.date
            })
            .onChange(of: self.date) {
                if self.state.date != self.date {
                    self.state.date = self.date
                }
            }
        }
    }

    struct Editor: View {
        @EnvironmentObject private var state: AppState
        @Binding public var job: Job?
        @Binding public var entityType: EntityType
        @FocusState public var focused: Bool
        @State private var text: String = ""

        var body: some View {
            if job != nil {
                QueryField(
                    prompt: "What are you working on?",
                    onSubmit: self.actionOnSubmit,
                    text: $text
                )
                .focused($focused)
            }
        }
    }

    struct AddButton: View {
        typealias Entity = PageConfiguration.EntityType
        @EnvironmentObject private var state: AppState
        @State private var isPresented: Bool = false

        var body: some View {
            NavigationStack {
                Menu("", systemImage: "plus") {
                    NavigationLink {
                        TaskDetail()
                    } label: {
                        Text(Entity.tasks.enSingular)
                        Entity.tasks.icon
                    }

                    NavigationLink {
                        NoteDetail.Sheet()
                    } label: {
                        Text(Entity.notes.enSingular)
                        Entity.notes.icon
                    }

                    NavigationLink {
                        PersonDetail()
                    } label: {
                        Text(Entity.people.enSingular)
                        Entity.people.icon
                    }

                    NavigationLink {
                        CompanyDetail()
                    } label: {
                        Text(Entity.companies.enSingular)
                        Entity.companies.icon
                    }

                    NavigationLink {
                        ProjectDetail()
                    } label: {
                        Text(Entity.projects.enSingular)
                        Entity.projects.icon
                    }

                    NavigationLink {
                        JobDetail()
                    } label: {
                        Text(Entity.jobs.enSingular)
                        Entity.jobs.icon
                    }

                    NavigationLink {
                        TermDetail()
                    } label: {
                        Text(Entity.terms.enSingular)
                        Entity.terms.icon
                    }
                }
            }
            .font(.title2)
            .foregroundStyle(self.state.theme.tint)
        }
    }

    struct ViewModeSelector: View {
        @AppStorage("today.viewMode") private var storedVm: Int = 0
        @State private var viewMode: ViewMode = .tabular

        var body: some View {
            Menu("", systemImage: self.viewMode.icon) {
                Button {
                    self.viewMode = .tabular
                    self.storedVm = self.viewMode.id
                } label: {
                    Text("Tabular")
                    Image(systemName: "tablecells")
                }
                .disabled(self.storedVm == 0)

                Button {
                    self.viewMode = .hierarchical
                    self.storedVm = self.viewMode.id
                } label: {
                    Text("Hierarchical")
                    Image(systemName: "list.bullet.indent")
                }
                .disabled(self.storedVm == 1)
            }
            .opacity(0.5)
            .onAppear(perform: self.actionOnAppear)
        }
        
        /// Onload handler. Sets the viewMode to the stored value.
        /// - Returns: Void
        private func actionOnAppear() -> Void {
            if let fromStored = ViewMode.by(id: storedVm) {
                self.viewMode = fromStored
            }
        }
    }
}

extension Today {
    /// Handler for callback when self.job changes value
    /// - Returns: Void
    private func actionOnJobChange() -> Void {
        if self.job != nil {
            self.textFieldActive = true
        }
    }
}

extension Today.Header {
    /// Callback that fires when the CreateSheet disappears
    /// - Returns: Void
    private func actionOnCreateSheetDismissed() -> Void {
        DefaultObjects.deleteDefaultJobs()
    }
}

extension Today.Editor {
    /// Form action
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
            if let job = self.job {
                CoreDataRecords(moc: self.state.moc).createWithJob(
                    job: job,
                    date: Date(),
                    text: text
                )
                text = ""
            }
        }
    }
}
