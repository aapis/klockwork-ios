//
//  Tabs.Content.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-19.
//

import SwiftUI

extension Tabs.Content {
    struct List {
        struct Separator: View {
            public var label: String
            public var description: String? = nil

            var body: some View {
                HStack {
                    SectionTitle(label: self.label, uppercase: true)
                    Spacer()
                    if self.description != nil {
                        SectionTitle(label: self.description!, uppercase: true)
                    }
                }
                .listRowBackground(
                    VStack(spacing: 0) {
                        Divider()
                            .foregroundStyle(.gray)
                        ZStack(alignment: .bottom) {
                            Theme.cPurple
                            LinearGradient(colors: [.clear, Theme.base], startPoint: .top, endPoint: .bottom)
                                .frame(height: 10)
                                .blendMode(.softLight)
                                .opacity(0.7)
                        }
                        Divider()
                            .foregroundStyle(.gray)
                    }
                )
            }
        }

        struct Records: View {
            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            public var pageTitle: String = "Records"
            @FetchRequest private var items: FetchedResults<LogRecord>
            @Binding public var job: Job?
            private var date: Date

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items) { record in
                            Individual.SingleRecordDetailedLink(record: record)
                        }
                    } else {
                        StatusMessage.Warning(message: "No records found for \(self.state.date.formatted(date: .abbreviated, time: .omitted))")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle(self.pageTitle)
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool, pageTitle: String = "Records") {
                _job = job
                self.date = date
                self.inSheet = inSheet
                self.pageTitle = pageTitle
                _items = CoreDataRecords.fetch(for: self.date)
            }
        }

        struct Jobs: View {
            @EnvironmentObject public var state: AppState
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Job>
            @FetchRequest private var favouriteItems: FetchedResults<Job>
            @Binding public var job: Job?
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if let job = self.state.job {
                        Separator(label: "Current")
                        Individual.SingleJobDetailedLink(job: job)
                    }

                    if self.favouriteItems.count > 0 {
                        Separator(label: "Starred (\(self.favouriteItems.count))", description: "All time")
                        ForEach(self.favouriteItems, id: \.self) { jerb in
                            Individual.SingleJobDetailedLink(job: jerb)
                        }
                    }

                    if items.count > 0 {
                        Separator(label: "Recent (\(self.items.count))", description: "< 30 days")
                        ForEach(items) { jerb in
                            Individual.SingleJobDetailedLink(job: jerb)
                        }
                    } else {
                        StatusMessage.Warning(message: "No jobs found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle("Jobs")
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool) {
                _job = job
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataJob.fetchRecent(numDaysPrior: 30)
                _favouriteItems = CoreDataJob.fetchAll(favsOnly: true)
            }
        }
        
        struct Tasks: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<LogTask>
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items, id: \.objectID) { task in
                            Individual.SingleTaskDetailedChecklistItem(task: task)
                        }
                    } else {
                        StatusMessage.Warning(message: "No tasks found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle("Tasks")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataTasks.recentTasksWidgetData()
            }
        }

        struct TasksWithPredicate: View {
            public var label: String
            public var inSheet: Bool
            public var predicate: NSPredicate
            @FetchRequest private var items: FetchedResults<LogTask>

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items, id: \.objectID) { task in
                            Individual.SingleTaskDetailedChecklistItem(task: task)
                        }
                    } else {
                        StatusMessage.Warning(message: "No tasks found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle(self.label)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarTitleDisplayMode(.inline)
            }

            init(label: String, inSheet: Bool, predicate: NSPredicate) {
                self.label = label
                self.inSheet = inSheet
                self.predicate = predicate
                _items = CoreDataTasks.fetch(with: predicate)
            }
        }

        struct Notes: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Note>
            @FetchRequest private var favouriteItems: FetchedResults<Note>
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if self.favouriteItems.count > 0 {
                        Separator(label: "Starred (\(self.favouriteItems.count))", description: "All time")
                        ForEach(self.favouriteItems, id: \.self) { note in
                            Individual.SingleNoteDetailedLink(note: note)
                        }
                    }
                    if items.count > 0 {
                        Separator(label: "All (\(self.items.count))")
                        ForEach(items) { note in
                            Individual.SingleNoteDetailedLink(note: note)
                        }
                    } else {
                        StatusMessage.Warning(message: "No notes found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .navigationTitle("Notes")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataNotes.fetchNotes()
                _favouriteItems = CoreDataNotes.fetchNotes(favouritesOnly: true)
            }
        }

        // MARK: HierarchyExplorer
        struct HierarchyExplorer: View {
            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            public var page: PageConfiguration.AppPage = .today
            @FetchRequest private var items: FetchedResults<Company>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if self.items.count > 0 {
                                ForEach(self.items, id: \.objectID) { item in
                                    TopLevel(entity: item)
                                }
                            } else {
                                StatusMessage.Warning(message: "No companies found")
                            }
                            Spacer()
                        }
                    }
                }
                .navigationTitle("Hierarchy Explorer")
                .background(self.page.primaryColour)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
            }

            init(inSheet: Bool) {
                self.inSheet = inSheet
                _items = CoreDataCompanies.fetch()
            }

            struct TopLevel: View {
                typealias Button = Tabs.Content.Individual.SingleCompanyHierarchical
                @EnvironmentObject private var state: AppState
                public var entity: Company
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap, selected: self.$isPresented)
                        .onAppear(perform: {
                            self.actionOnAppear(self.entity)
                        })

                    if self.isPresented {
                        if let projects = self.entity.projects?.allObjects as? [Project] {
                            ForEach(projects.filter({$0.alive == true}).sorted(by: {$0.name! < $1.name!}), id: \Project.objectID) { project in
                                SecondLevel(entity: project)
                            }
                        }

                        if let people = self.entity.people?.allObjects as? [Person] {
                            if people.count > 0 {
                                TopLevelPeople(people: people, colour: self.entity.backgroundColor)
                            }
                        }
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap(_ company: Company) -> Void {
                    self.isPresented.toggle()
                }
                
                /// Fires on appear
                /// - Returns: Void
                private func actionOnAppear(_ company: Company) -> Void {
                    if self.state.job != nil {
                        if let project = self.state.job!.project {
                            if let comp = project.company {
                                if comp == company {
                                    self.isPresented = true
                                } else {
                                    self.isPresented = false
                                }
                            }
                        }
                    }
                }
            }

            struct TopLevelPeople: View {
                typealias Button = Tabs.Content.Individual.SingleTextCustomButton
                typealias PersonButton = Tabs.Content.Individual.SinglePerson

                public var people: [Person]?
                public var colour: Color
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(text: "People", colour: self.colour, callback: self.actionOnTap)

                    if self.isPresented && self.people != nil {
                        ForEach(self.people!.sorted(by: {
                            $0.name ?? "" < $1.name ?? ""
                        }), id: \.objectID) { person in
                            HStack(alignment: .center, spacing: 0) {
                                Rectangle()
                                    .foregroundStyle(self.colour)
                                    .frame(width: 15)
                                PersonButton(person: person, colour: .clear)
                            }
                        }
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap() -> Void {
                    self.isPresented.toggle()
                }
            }

            struct SecondLevel: View {
                typealias Button = Tabs.Content.Individual.SingleProjectHierarchical
                @EnvironmentObject private var state: AppState
                public var entity: Project
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap, selected: self.$isPresented)
                        .onAppear(perform: {
                            self.actionOnAppear(self.entity)
                        })

                    if self.isPresented {
                        if let pJobs = self.entity.jobs {
                            if let jobs = pJobs.allObjects as? [Job] {
                                ForEach(jobs.filter({$0.alive == true}).sorted(by: {
                                    $0.title ?? "" > $1.title ?? ""
                                }), id: \.objectID) { job in
                                    ThirdLevel(entity: job)
                                }
                            } else {
                                StatusMessage.Warning(message: "\(self.entity.name ?? "_PROJECT") doesn't have any jobs associated with it.")
                            }
                        }
                    }
                }

                /// Tap/click handler. Opens to show list of jobs.
                /// - Returns: Void
                private func actionOnTap(_ project: Project) -> Void {
                    self.isPresented.toggle()
                }

                /// Fires on appear
                /// - Returns: Void
                private func actionOnAppear(_ project: Project) -> Void {
                    if self.state.job != nil {
                        if let proj = self.state.job!.project {
                            if proj == project {
                                self.isPresented = true
                            } else {
                                self.isPresented = false
                            }
                        }
                    }
                }
            }

            struct ThirdLevel: View {
                typealias JobButton = Tabs.Content.Individual.SingleJobHierarchical

                @EnvironmentObject private var state: AppState
                public let entity: Job
                public var page: PageConfiguration.AppPage = .create
                @State private var isPresented: Bool = false
                @State private var isCreateTaskPanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var isCreateNotePanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var isCreateRecordPanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var didSave: Bool = false
                @State private var tasks: [LogTask] = []
                @State private var notes: [Note] = []
                @State private var records: [LogRecord] = []
                @State private var terms: [TaxonomyTermDefinitions] = []
                @State private var colour: Color = .clear
                @State private var newTaskContent: String = "" // @TODO: move this to a new struct
                @State private var newNoteTitle: String = "" // @TODO: move this to a new struct
                @State private var id: UUID = UUID()

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        JobButton(entity: self.entity, callback: self.actionOnTap, selected: self.$isPresented)

                        // @TODO: refactor to follow the pattern set in previous levels
                        if self.isPresented {
                            VStack(alignment: .leading, spacing: 0) {
                                /// Tasks
                                ZStack(alignment: .leading) {
                                    self.entity.backgroundColor
                                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .trailing, endPoint: .leading)
                                        .opacity(0.6)
                                        .blendMode(.softLight)
                                        .frame(height: 50)
                                    HStack(alignment: .center, spacing: 0) {
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)

                                        HStack(spacing: 0) {
                                            if self.tasks.isEmpty {
                                                Text("No Tasks")
                                                    .opacity(0.5)
                                            } else {
                                                Text("\(self.tasks.count) Tasks")
                                            }
                                        }
                                        .padding(.leading, 8)

                                        Spacer()
                                        RowAddButton(isPresented: $isCreateTaskPanelPresented)
                                    }
                                }

                                /// Quick task creator
                                if self.isCreateTaskPanelPresented {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .center, spacing: 0) {
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                            TextField("", text: $newTaskContent, prompt: Text("What needs to be done?").foregroundStyle(Theme.base.opacity(0.5)), axis: .horizontal)
                                                .submitLabel(.go)
                                                .onSubmit {
                                                    self.actionOnCreateTask()
                                                    self.newTaskContent = ""
                                                    withAnimation(.linear(duration: 0.2)) {
                                                        self.isCreateTaskPanelPresented.toggle()
                                                    }
                                                }
                                                .padding()
                                        }
                                    }
                                    .background(.orange)
                                    .onDisappear(perform: self.actionPostSave)
                                }

                                if !self.tasks.isEmpty {
                                    ForEach(self.tasks, id: \LogTask.objectID) { task in
                                        FourthLevel(entity: task)
                                    }
                                }

                                ZStack(alignment: .leading) {
                                    self.entity.backgroundColor
                                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .trailing, endPoint: .leading)
                                        .opacity(0.6)
                                        .blendMode(.softLight)
                                        .frame(height: 50)

                                    HStack(alignment: .center, spacing: 0) {
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)

                                        HStack(spacing: 0) {
                                            if self.notes.isEmpty {
                                                Text("No Notes")
                                                    .opacity(0.5)
                                            } else {
                                                Text("\(self.notes.count) Notes")
                                            }
                                        }
                                        .padding(.leading, 8)

                                        Spacer()
                                        RowAddButton(isPresented: $isCreateNotePanelPresented)
                                    }
                                }

                                /// Quick note creator
                                if self.isCreateNotePanelPresented {
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .center, spacing: 0) {
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                            TextField("", text: $newNoteTitle, prompt: Text("Untitled Note").foregroundStyle(Theme.base.opacity(0.5)), axis: .horizontal)
                                                .submitLabel(.go)
                                                .onSubmit {
                                                    self.actionOnCreateNote()
                                                    self.newNoteTitle = ""
                                                    withAnimation(.linear(duration: 0.2)) {
                                                        self.isCreateNotePanelPresented.toggle()
                                                    }
                                                }
                                                .padding()
                                        }
                                    }
                                    .background(.orange)
                                    .onDisappear(perform: self.actionPostSave)
                                }

                                if !self.notes.isEmpty {
                                    ForEach(self.notes, id: \Note.objectID) { note in
                                        FourthLevelNotes(entity: note)
                                    }
                                }

                                /// Terms
                                ZStack(alignment: .leading) {
                                    self.entity.backgroundColor
                                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .trailing, endPoint: .leading)
                                        .opacity(0.6)
                                        .blendMode(.softLight)
                                        .frame(height: 50)

                                    HStack(alignment: .center, spacing: 0) {
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        if self.terms.isEmpty {
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                        }

                                        HStack(spacing: 0) {
                                            if self.terms.isEmpty {
                                                Text("No Terms")
                                                    .opacity(0.5)
                                            } else {
                                                NavigationLink {
                                                    TermFilter(job: self.entity)
                                                } label: {
                                                    ListRow(
                                                        name: terms.count == 1 ? "1 Term" : "\(terms.count) Terms",
                                                        colour: self.entity.backgroundColor,
                                                        icon: "chevron.right"
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.leading, 8)
                                    }
                                }

                                /// Record view link
                                ZStack(alignment: .leading) {
                                    self.entity.backgroundColor
                                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .trailing, endPoint: .leading)
                                        .opacity(0.6)
                                        .blendMode(.softLight)
                                        .frame(height: 50)

                                    HStack(alignment: .top, spacing: 0) {
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        Rectangle()
                                            .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                            .frame(width: 15)
                                        if self.records.isEmpty {
                                            Rectangle()
                                                .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                                                .frame(width: 15)
                                        }

                                        HStack(spacing: 0) {
                                            if self.records.isEmpty {
                                                Text("No Records")
                                                    .opacity(0.5)
                                            } else {
                                                NavigationLink {
                                                    RecordFilter(job: self.entity)
                                                } label: {
                                                    ListRow(
                                                        name: "\(self.records.count) Records",
                                                        colour: self.entity.backgroundColor,
                                                        icon: "chevron.right"
                                                    )
                                                }
                                            }
                                        }
                                        .padding(.leading, 8)
                                    }
                                }
                            }
                            .onAppear(perform: self.actionOnAppear)
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : .white)
                        }
                    }
                    .id(self.id)
                    .onAppear(perform: self.actionOpenIfSelected)
                }

                init(entity: Job) {
                    self.entity = entity
                }

                /// Onload handler. Populates task and note lists
                /// - Returns: Void
                private func actionOnAppear() -> Void {
                    if let tasks = self.entity.tasks?.allObjects as? [LogTask] {
                        self.tasks = tasks.filter({$0.completedDate == nil && $0.cancelledDate == nil}).sorted(by: {$0.due != nil && $1.due != nil ? $0.due! > $1.due! : false})
                    }

                    if let notes = self.entity.mNotes?.allObjects as? [Note] {
                        self.notes = notes.filter({$0.alive == true}).sorted(by: {$0.title != nil && $1.title != nil ? $0.title! > $1.title! : false})
                    }

                    if let records = self.entity.records?.allObjects as? [LogRecord] {
                        self.records = records.filter({$0.alive == true}).sorted(by: {$0.timestamp ?? Date() > $1.timestamp ?? Date()})
                    }

                    if let terms = self.entity.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                        self.terms = terms.filter({$0.alive == true}).sorted(by: {$0.created! > $1.created!})
                    }

                    self.colour = Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble)
                }
                
                /// Fired when view loads
                /// - Returns: Void
                private func actionOpenIfSelected() -> Void {
                    if self.state.job != nil {
                        if self.state.job == self.entity {
                            self.isPresented = true
                        } else {
                            self.isPresented = false
                        }
                    }
                }

                /// Tap/click handler. Opens to show list of jobs.
                /// - Returns: Void
                private func actionOnTap(_ job: Job) -> Void {
                    self.isPresented.toggle()
                }

                /// Fires when creating a task using the quick creator
                /// - Returns: Void
                private func actionOnCreateTask() -> Void {
                    CoreDataTasks(moc: self.state.moc).create(
                        content: self.newTaskContent,
                        created: Date(),
                        due: DateHelper.endOfDay() ?? Date(),
                        job: self.entity
                    )

                    self.didSave = true
                }

                /// Fires when creating a note using the quick creator
                /// - Returns: Void
                private func actionOnCreateNote() -> Void {
                    CoreDataNotes(moc: self.state.moc).create(
                        alive: true,
                        body: "",
                        lastUpdate: Date(),
                        postedDate: Date(),
                        starred: false,
                        title: self.newNoteTitle,
                        job: self.entity
                    )

                    self.didSave = true
                }

                /// Force view refresh
                /// @TODO: may be unnecessary in later versions, confirm this still works
                /// - Returns: Void
                private func actionPostSave() -> Void {
                    if self.didSave {
                        self.id = UUID()
                        self.isPresented.toggle()
                    }

                    self.didSave = false
                }
            }

            struct FourthLevel: View {
                typealias Button = Tabs.Content.Individual.SingleTaskChecklistItem

                public let entity: LogTask
                @State private var isPresented: Bool = false

                var body: some View {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.owner?.project?.company?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.owner?.project?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)
                        Rectangle()
                            .foregroundStyle(self.entity.owner?.backgroundColor ?? Theme.rowColour)
                            .frame(width: 15)

                        Button(task: self.entity)
                            .border(width: 1, edges: [.bottom], color: Theme.cPurple.opacity(0.6))
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap(_ company: Company) -> Void {
                    self.isPresented.toggle()
                }
            }

            // @TODO: refactor + remove in favour of pattern defined in previous steps
            struct FourthLevelNotes: View {
                typealias Button = Tabs.Content.Individual.SingleNote

                public let entity: Note
                @State private var isPresented: Bool = false

                var body: some View {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.mJob?.project?.company?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.mJob?.project?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)
                        Rectangle()
                            .foregroundStyle(self.entity.mJob?.backgroundColor ?? Theme.rowColour)
                            .frame(width: 15)

                        Button(note: self.entity)
                            .border(width: 1, edges: [.bottom], color: Theme.cPurple.opacity(0.6))
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap(_ company: Company) -> Void {
                    self.isPresented.toggle()
                }
            }
        }

        struct Terms: View {
            public var inSheet: Bool
            @State public var entity: Job
            @State private var isCreateTaskPanelPresented: Bool = false
            @State private var items: [TaxonomyTerm] = [] // @TODO: we maaaaay only use this to determine term count
            @State private var newTermName: String = ""
            @State private var newTermDefinition: String = ""
            @State private var id: UUID = UUID()

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .trailing, endPoint: .leading)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(height: 50)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center, spacing: 0) {
                                Rectangle()
                                    .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                                    .frame(width: 15)
                                Rectangle()
                                    .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                                    .frame(width: 15)
                                TermFilterBound(job: $entity)
                            }
                        }
                    }
                }
                .onAppear(perform: self.actionOnAppear)
            }

            /// Onload handler
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.items = []
                if let definitions = self.entity.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                    for definition in definitions {
                        if let term = definition.term {
                            self.items.append(term)
                        }
                    }
                }
            }

            /// OnCreate handler
            /// - Returns: Void
            private func actionOnCreateTerm() -> Void {

            }

            /// Post-save handler
            /// - Returns: Void
            private func actionPostSave() -> Void {

            }
        }

        struct Companies: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Company>
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items, id: \Company.objectID) { item in
                            Individual.SingleCompanyDetailedLink(entity: item)
                        }
                    } else {
                        StatusMessage.Warning(message: "No companies found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle("Companies")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataCompanies.all()
            }
        }

        struct People: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Person>
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items, id: \Person.objectID) { item in
                            Individual.SinglePersonDetailedLink(person: item)
                        }
                    } else {
                        StatusMessage.Warning(message: "No people found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle("People")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataPerson.fetchAll()
            }
        }

        struct Projects: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Project>
            public var date: Date

            var body: some View {
                SwiftUI.List {
                    if items.count > 0 {
                        ForEach(items, id: \Project.objectID) { item in
                            Individual.SingleProjectDetailedLink(entity: item)
                        }
                    } else {
                        StatusMessage.Warning(message: "No projects found")
                    }
                }
                .listStyle(.plain)
                .listRowInsets(.none)
                .listRowSpacing(.none)
                .listRowSeparator(.hidden)
                .listSectionSpacing(0)
                .navigationTitle("Projects")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataProjects.fetchAll()
            }
        }
    }
}
