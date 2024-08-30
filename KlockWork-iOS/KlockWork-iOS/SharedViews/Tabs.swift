//
//  Tabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI
import CoreData

// @TODO: refactor into one that supports any PageConfiguration enum
struct Tabs: View {
    typealias EntityType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @Binding public var job: Job?
    @Binding public var selected: EntityType
    public var content: AnyView? = nil
    public var buttons: AnyView? = nil
    public var title: AnyView? = nil
    static public let animationDuration: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if buttons == nil {
                Buttons(inSheet: inSheet, job: $job, selected: $selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                buttons
            }

            if title == nil {
                MiniTitleBar(selected: $selected)
                    .border(width: 1, edges: [.bottom], color: .yellow)
            } else {
                title
            }

            if content == nil {
                Content(inSheet: inSheet, job: $job, selected: $selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                content
            }
        }
        .background(.clear)
        .onChange(of: job) {
            withAnimation(.bouncy(duration: Tabs.animationDuration)) {
                selected = .records
            }
        }
    }
}

extension Tabs {
    /// Callback that fires when a swipe event is triggered
    /// - Parameter swipe: Swipe
    /// - Returns: Void
    public func actionOnSwipe(_ swipe: Swipe) -> Void {
        let tabs = EntityType.allCases
        if var selectedIndex = (tabs.firstIndex(of: self.selected)) {
            if swipe == .left {
                if selectedIndex <= tabs.count - 2 {
                    selectedIndex += 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[0]
                }
            } else if swipe == .right {
                if selectedIndex > 0 && selectedIndex <= tabs.count {
                    selectedIndex -= 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[tabs.count - 1]
                }
            }
        }
    }
}

extension Tabs {
    struct Buttons: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType

        var body: some View {
            ZStack {
                HStack(alignment: .center, spacing: 1) {
                    // @TODO: restore to original state (below)
                    // ForEach(EntityType.allCases, id: \.self) { page in
                    ForEach(EntityType.allCases.filter({$0 != .terms}), id: \.self) { page in
                        VStack {
                            Button {
                                withAnimation(.bouncy(duration: Tabs.animationDuration)) {
                                    selected = page
                                }
                            } label: {
                                (page == selected ? page.selectedIcon : page.icon)
                                    .frame(maxHeight: 20)
                                    .padding(14)
                                    .background(page == selected ? .white : .clear)
                                    .foregroundStyle(page == selected ? Theme.cPurple : .gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer()
                }
                .background(Theme.textBackground)

            }
            .frame(height: 50)
        }
    }

    struct Content: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: EntityType

        var body: some View {
            switch selected {
            case .records:
                List.Records(job: $job, date: self.state.date, inSheet: self.inSheet)
            case .jobs:
                List.Jobs(job: $job, date: self.state.date, inSheet: self.inSheet)
            case .tasks:
                List.Tasks(date: self.state.date, inSheet: self.inSheet)
            case .notes:
                List.Notes(date: self.state.date, inSheet: self.inSheet)
            case .companies:
                List.Companies(date: self.state.date, inSheet: self.inSheet)
            case .people:
                List.People(date: self.state.date, inSheet: self.inSheet)
            case .projects:
                List.Projects(date: self.state.date, inSheet: self.inSheet)
            case .terms:
                List.Terms(inSheet: self.inSheet, entity: $job.wrappedValue!)
            }
        }
    }
}

extension Tabs.Content {
    struct List {
        struct Records: View {
            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<LogRecord>
            @Binding public var job: Job?
            private var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { record in
                                Individual.SingleRecord(record: record)
                            }
                        } else {
                            StatusMessage.Warning(message: "No records found for \(self.state.date.formatted(date: .abbreviated, time: .omitted))")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Records")
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool) {
                _job = job
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataRecords.fetch(for: self.date)
            }
        }

        struct Jobs: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var job: Job?
            public var date: Date

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { jerb in
                                Individual.SingleJobLink(job: jerb)
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs modified within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Jobs")
            }

            init(job: Binding<Job?>, date: Date, inSheet: Bool) {
                _job = job
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataJob.fetchRecent(from: date)
            }
        }

        struct Tasks: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<LogTask>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { task in
                                Individual.SingleTaskDetailedChecklistItem(task: task)
                            }
                        } else {
                            StatusMessage.Warning(message: "No tasks modified within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Tasks")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataTasks.fetch(for: self.date)
            }
        }

        struct Notes: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Note>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items) { note in
                                Individual.SingleNote(note: note)
                            }
                        } else {
                            StatusMessage.Warning(message: "No notes updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Notes")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataNotes.fetch(for: self.date, daysPrior: 7)
            }
        }

        struct HierarchyExplorer: View {
            @EnvironmentObject private var state: AppState
            public var inSheet: Bool
            public var page: PageConfiguration.AppPage = .today
            @FetchRequest private var items: FetchedResults<Company>

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    Divider().background(.white).frame(height: 1)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            if self.items.count > 0 {
                                ForEach(self.items, id: \Company.objectID) { item in
                                    TopLevel(entity: item)
                                }
                            } else {
                                StatusMessage.Warning(message: "No companies updated within the last 7 days")
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

                @State public var entity: Company
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap)

                    if self.isPresented {
                        if let projects = self.entity.projects?.allObjects as? [Project] {
                            ForEach(projects.filter({$0.alive == true}).sorted(by: {$0.name! < $1.name!}), id: \Project.objectID) { project in
                                SecondLevel(entity: project)
                            }
                        }
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap(_ company: Company) -> Void {
                    self.isPresented.toggle()
                }
            }

            struct SecondLevel: View {
                typealias Button = Tabs.Content.Individual.SingleProjectHierarchical

                @State public var entity: Project
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap)

                    if self.isPresented {
                        if let pJobs = self.entity.jobs {
                            if let jobs = pJobs.allObjects as? [Job] {
                                ForEach(jobs.filter({$0.alive == true}).sorted(by: {
                                    if $0.title != nil && $1.title != nil {
                                        return $0.title! > $1.title!
                                    } else {
                                        return $0.jid < $1.jid
                                    }
                                }), id: \Job.objectID) { job in
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
            }

            struct ThirdLevel: View {
                typealias JobButton = Tabs.Content.Individual.SingleJobHierarchical

                @EnvironmentObject private var state: AppState
                @State public var entity: Job
                public var page: PageConfiguration.AppPage = .create
                @State private var isPresented: Bool = false
                @State private var isCreateTaskPanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var isCreateNotePanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var isCreateRecordPanelPresented: Bool = false // @TODO: move this to a new struct
                @State private var didSave: Bool = false
                @State private var tasks: [LogTask] = []
                @State private var notes: [Note] = []
                @State private var records: [LogRecord] = []
                @State private var colour: Color = .clear
                @State private var newTaskContent: String = "" // @TODO: move this to a new struct
                @State private var newNoteTitle: String = "" // @TODO: move this to a new struct
                @State private var id: UUID = UUID()

                var body: some View {
                    VStack(alignment: .leading, spacing: 0) {
                        JobButton(entity: self.entity, callback: self.actionOnTap)
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

                                // Terms
                                Terms(inSheet: false, entity: self.entity)

                                /// Record view link
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
                                                    ListRow(name: "\(self.records.count) Records", colour: self.entity.backgroundColor)
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
                        self.records = records.filter({$0.alive == true}).sorted(by: {$0.timestamp! > $1.timestamp!})
                    }

                    self.colour = Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble)
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
            public let entity: Job
            @State private var isCreateTaskPanelPresented: Bool = false
            @State private var items: [TaxonomyTerm] = [] // @TODO: we maaaaay only use this to determine term count
            @State private var newTermName: String = ""
            @State private var newTermDefinition: String = ""

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .leading) {
                        self.entity.backgroundColor
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
                                if self.items.isEmpty {
                                    Rectangle()
                                        .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                                        .frame(width: 15)
                                }

                                HStack(spacing: 0) {
                                    if self.items.isEmpty {
                                        Text("No Terms")
                                            .opacity(0.5)
                                    } else {
                                        NavigationLink {
                                            TermFilter(job: self.entity)
                                        } label: {
                                            ListRow(name: self.items.count == 1 ? "1 Term" : "\(self.items.count) Terms", colour: self.entity.backgroundColor)
                                        }
                                    }
                                }
                                .padding(.leading, 8)
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items, id: \Company.objectID) { item in
                                Individual.SingleCompany(company: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Companies")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataCompanies.fetch(for: self.date)
            }
        }

        struct People: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Person>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items, id: \Person.objectID) { item in
                                Individual.SinglePerson(person: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No people updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("People")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataPerson.fetch(for: self.date)
            }
        }

        struct Projects: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Project>
            public var date: Date

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if items.count > 0 {
                            ForEach(items, id: \Project.objectID) { item in
                                Individual.SingleProject(project: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No projects updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Projects")
            }

            init(date: Date, inSheet: Bool) {
                self.date = date
                self.inSheet = inSheet
                _items = CoreDataProjects.fetch(for: self.date)
            }
        }
    }
}

extension Tabs.Content {
    struct Individual {
        struct SingleRecord: View {
            @EnvironmentObject private var state: AppState
            public let record: LogRecord

            var body: some View {
                NavigationLink {
                    RecordDetail(record: record)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: record.message ?? "_RECORD_CONTENT",
                        colour: record.job != nil ? record.job!.backgroundColor : Theme.rowColour,
                        extraColumn: AnyView(
                            Text(record.timestamp!.formatted(date: .omitted, time: .shortened))
                                .foregroundStyle(.gray)
                        )
                    )
                }
                // @TODO: use .onLongPressGesture to open record inspector view, allowing job selection and other functions
            }
        }

        struct SingleRecordCustomButton: View {
            public let entity: LogRecord
            public var callback: (LogRecord) -> Void
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(entity)
                } label: {
                    ListRow(
                        name: entity.message ?? "NOT_FOUND",
                        colour: Color.fromStored(self.entity.job?.colour ?? Theme.rowColourAsDouble),
                        icon: selected ? "minus" : "plus"
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleTerm: View {
            @EnvironmentObject private var state: AppState
            public let term: TaxonomyTerm
            @State private var definitions: [TaxonomyTermDefinitions] = []
            @State private var colour: Color = Theme.rowColour

            var body: some View {
                NavigationLink {
                    TermDetail(term: self.term)
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            Text(term.name ?? "_TERM_NAME")
                                .font(.title3)
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.gray)
                        }
                        .padding(10)

                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(self.definitions, id: \TaxonomyTermDefinitions.objectID) { term in
                                HStack(alignment: .top) {
                                    Text("1. ")
                                    Text(term.definition ?? "_TERM_DEFINITION")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding(8)
                                .background(term.job?.backgroundColor)
                                .foregroundStyle(term.job != nil ? term.job!.backgroundColor.isBright() ? .black : .white : .white)
                            }
                        }
                    }
                    .background(Theme.rowColour)
                }
                .onAppear(perform: self.actionOnAppear)
                // @TODO: use .onLongPressGesture to open record inspector view, allowing job selection and other functions
            }
            
            /// Onload handler
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.definitions = self.term.definitions?.allObjects as! [TaxonomyTermDefinitions]
            }
        }

        struct SingleJob: View {
            public let job: Job
            @Binding public var stateJob: Job?

            var body: some View {
                Button {
                    stateJob = job
                } label: {
                    ListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleJobLink: View {
            public let job: Job

            var body: some View {
                NavigationLink {
                    JobDetail(job: job)
                } label: {
                    ListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleJobCustomButton: View {
            public let job: Job
            public var callback: (Job) -> Void
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(job)
                } label: {
                    ListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor,
                        icon: selected ? "minus" : "plus"
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleJobCustomButtonMultiSelectForm: View {
            public let job: Job
            public var alreadySelected: Bool
            public var callback: (Job, ButtonAction) -> Void
            @State private var selected: Bool = false

            var body: some View {
                SingleJobCustomButtonTwoState(
                    job: self.job,
                    alreadySelected: self.alreadySelected,
                    callback: self.callback,
                    padding: 0
                )
            }
        }

        struct SingleJobCustomButtonTwoState: View {
            public let job: Job
            public var alreadySelected: Bool
            public var callback: (Job, ButtonAction) -> Void
            public var padding: CGFloat = 8
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(job, selected ? .add : .remove)
                } label: {
                    ToggleableListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor,
                        iconOff: "square",
                        iconOn: "square.fill",
                        padding: self.padding,
                        selected: $selected
                    )
                }
                .listRowBackground(Color.fromStored(job.colour ?? Theme.rowColourAsDouble))
                .buttonStyle(.plain)
                .onAppear(perform: {
                    selected = alreadySelected
                })
            }
        }

        struct SingleJobHierarchical: View {
            public let entity: Job
            public var callback: (Job) -> Void
            public var page: PageConfiguration.AppPage = .create
            @State private var selected: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.project?.company?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.project?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)

                        // Open Job button
                        Button {
                            selected.toggle()
                            callback(self.entity)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                        }
                        .frame(width: 25, height: 25)
                        .padding([.leading, .trailing])

                        // Entity creation buttons
                        NavigationLink {
                            JobDetail(job: self.entity)
                        } label: {
                            ListRow(
                                name: self.entity.title ?? self.entity.jid.string,
                                colour: self.entity.backgroundColor,
                                padding: (14, 14, 14, 0)
                            )
                        }
                    }
                }
                .background(self.entity.colour_from_stored())
            }
        }

        struct SingleTask: View {
            public let task: LogTask

            var body: some View {
                NavigationLink {
                    TaskDetail(task: task)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: task.content ?? "_TASK_CONTENT",
                        colour: task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleTaskChecklistItem: View {
            @EnvironmentObject private var state: AppState
            public let task: LogTask
            @State private var isCompleted: Bool = false
            @State private var isCancelled: Bool = false

            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        isCompleted.toggle()
                        self.actionOnSave()
                    } label: {
                        Image(systemName: isCompleted ? "square.fill" : "square")
                            .font(.title2)
                    }
                    .padding(8)

                    NavigationLink {
                        TaskDetail(task: task)
                            .background(Theme.cPurple)
                            .scrollContentBackground(.hidden)
                    } label: {
                        ListRow(
                            name: task.content ?? "_TASK_CONTENT",
                            colour: task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour,
                            padding: (14, 14, 14, 0)
                        )
                    }
                }
                .background(self.task.owner!.backgroundColor)
                .opacity(isCompleted ? 0.5 : 1.0)
                .onAppear(perform: self.actionOnAppear)
            }
            
            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.isCompleted = self.task.completedDate != nil
                self.isCancelled = self.task.cancelledDate != nil
            }
            
            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
                if self.isCompleted {
                    self.task.completedDate = Date()

                    // Create a record indicating when the task was completed
                    CoreDataTasks(moc: self.state.moc).complete(self.task)
                } else {
                    self.task.completedDate = nil
                }

                if self.isCancelled {
                    self.task.cancelledDate = Date()

                    // Create a record indicating when the task was cancelled
                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
                } else {
                    self.task.cancelledDate = nil
                }

                PersistenceController.shared.save()
            }
        }

        struct SingleTaskDetailedChecklistItem: View {
            @EnvironmentObject private var state: AppState
            public let task: LogTask
            public var callback: (() -> Void)? = nil
            @State private var isCompleted: Bool = false
            @State private var isCancelled: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .top, spacing: 0) {
                        Button {
                            isCompleted.toggle()
                            self.actionOnSave()
                            if let cb = callback { cb() }
                        } label: {
                            VStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Image(systemName: isCompleted ? "square.fill" : "square")
                                    .font(.title2)
                                Spacer()
                            }
                            .frame(width: 50)
                            .background(.black.opacity(0.1))
                        }

                        NavigationLink {
                            TaskDetail(task: task)
                        } label: {
                            HStack(alignment: .center) {
                                Text(task.content ?? "_TASK_CONTENT")
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding(12)
                        }
                        .background(task.owner?.backgroundColor ?? Theme.rowColour)
                    }
                    .foregroundStyle((task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)

                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        ZStack(alignment: .topLeading) {
                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                .opacity(0.1)

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(alignment: .center) {
                                    Text("\(task.owner?.project?.company?.abbreviation ?? "DEF").\(task.owner?.project?.abbreviation ?? "DEF") > \(task.owner?.title ?? "_TASK_OWNER")")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                if task.due != nil {
                                    HStack(alignment: .center) {
                                        Text("Due: \(task.due!.formatted(date: .abbreviated, time: .complete))")
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                            }
                            .padding(8)
                            .font(.caption)
                            .foregroundStyle((task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
                .background(self.task.owner?.backgroundColor ?? Theme.rowColour)
                .opacity(isCompleted ? 0.5 : 1.0)
                .onAppear(perform: self.actionOnAppear)
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.isCompleted = self.task.completedDate != nil
                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
                if self.isCompleted {
                    self.task.completedDate = Date()

                    // Create a record indicating when the task was completed
                    CoreDataTasks(moc: self.state.moc).complete(self.task)
                } else {
                    self.task.completedDate = nil
                }

                if self.isCancelled {
                    self.task.cancelledDate = Date()

                    // Create a record indicating when the task was cancelled
                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
                } else {
                    self.task.cancelledDate = nil
                }

                PersistenceController.shared.save()
            }
        }

        struct SingleNote: View {
            public let note: Note
            private let page: PageConfiguration.AppPage = .modify
            @State private var isSheetPresented = false

            var body: some View {
                NavigationLink {
                    NoteDetail.Sheet(note: note, page: self.page)
                } label: {
                    ListRow(
                        name: note.title ?? "",
                        colour: note.mJob != nil ? note.mJob!.backgroundColor : Theme.rowColour,
                        extraColumn: AnyView(VersionCountBadge),
                        highlight: false
                    )
                }
            }

            @ViewBuilder private var VersionCountBadge: some View {
                Text(String(note.versions?.count ?? 0))
                    .padding(8)
                    .foregroundStyle(.white)
                    .background(Theme.base.opacity(0.2))
                    .clipShape(.circle)
            }
        }

        struct SingleCompany: View {
            public let company: Company

            var body: some View {
                NavigationLink {
                    CompanyDetail(company: company)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: company.name ?? "_COMPANY_NAME",
                        colour: Color.fromStored(company.colour ?? Theme.rowColourAsDouble)
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleCompanyCustomButton: View {
            public let company: Company
            public var callback: (Company) -> Void
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(company)
                } label: {
                    ListRow(
                        name: company.name ?? "[NO NAME]",
                        colour: Color.fromStored(company.colour ?? Theme.rowColourAsDouble),
                        icon: selected ? "minus" : "plus"
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleCompanyHierarchical: View {
            public let entity: Company
            public var callback: (Company) -> Void
            @State private var selected: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 0) {
                        // Open company button
                        Button {
                            selected.toggle()
                            callback(self.entity)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                        }
                        .frame(width: 25, height: 25)
                        .padding([.leading, .trailing])

                        // Company link
                        NavigationLink {
                            CompanyDetail(company: self.entity)
                        } label: {
                            ListRow(
                                name: entity.name ?? "[NO NAME]",
                                colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                                padding: (14, 14, 14, 0)
                            )
                        }
                    }

                    if self.selected {
                        ZStack(alignment: .leading) {
                            LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .top, endPoint: .bottom)
                                .opacity(0.8)
                                .blendMode(.softLight)
                                .frame(height: 50)
                            HStack(spacing: 0) {
                                Text(self.entity.abbreviation ?? "_DEFAULT")
                                    .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : .white)
                                    .opacity(0.7)
                                    .padding(.leading, 8)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                // @TODO: uncomment after we list out people under projects
//                                RowAddNavLink(
//                                    title: "+ Person",
//                                    target: AnyView(
//                                        PersonDetail(company: self.entity)
//                                    )
//                                )
                                RowAddNavLink(
                                    title: "+ Project",
                                    target: AnyView(
                                        ProjectDetail(company: self.entity)
                                    )
                                )
                                .padding(.trailing, 8)
                            }
                            .padding(.leading, 8)
                        }
                    }
                }
                .background(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble))
            }
        }

        struct SinglePerson: View {
            public let person: Person

            var body: some View {
                NavigationLink {
                    PersonDetail(person: person)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: person.name ?? "_PERSON_NAME",
                        colour: Color.fromStored(person.company?.colour ?? Theme.rowColourAsDouble)
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleProject: View {
            public let project: Project

            var body: some View {
                NavigationLink {
                    ProjectDetail(project: project)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ListRow(
                        name: project.name ?? "_PROJECT_NAME",
                        colour: Color.fromStored(project.colour ?? Theme.rowColourAsDouble)
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleProjectCustomButton: View {
            public let entity: Project
            public var callback: (Project) -> Void
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(entity)
                } label: {
                    ListRow(
                        name: entity.name ?? "[NO NAME]",
                        colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                        icon: selected ? "minus" : "plus"
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SingleProjectCustomButtonTwoState: View {
            public let entity: Project
            public var alreadySelected: Bool
            public var callback: (Project, ButtonAction) -> Void
            public var padding: CGFloat = 8
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(entity, selected ? .add : .remove)
                } label: {
                    ToggleableListRow(
                        name: entity.name ?? "_NAME",
                        colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                        iconOff: "square",
                        iconOn: "square.fill",
                        padding: self.padding,
                        selected: $selected
                    )
                }
                .listRowBackground(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble))
                .buttonStyle(.plain)
                .onAppear(perform: {
                    selected = alreadySelected
                })
            }
        }

        struct SingleProjectCustomButtonMultiSelectForm: View {
            public let entity: Project
            public var alreadySelected: Bool
            public var callback: (Project, ButtonAction) -> Void
            @State private var selected: Bool = false

            var body: some View {
                SingleProjectCustomButtonTwoState(
                    entity: self.entity,
                    alreadySelected: self.alreadySelected,
                    callback: self.callback,
                    padding: 0
                )
            }
        }

        struct SingleProjectHierarchical: View {
            public let entity: Project
            public var callback: (Project) -> Void
            public var page: PageConfiguration.AppPage = .create
            @State private var selected: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.company?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)

                        // Open folder button
                        Button {
                            selected.toggle()
                            callback(self.entity)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                        }
                        .frame(width: 25, height: 25)
                        .padding([.leading, .trailing])

                        // Project link
                        NavigationLink {
                            ProjectDetail(project: self.entity)
                        } label: {
                            ListRow(
                                name: entity.name ?? "[NO NAME]",
                                colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                                padding: (14, 14, 14, 0)
                            )
                        }
                    }

                    if self.selected {
                        ZStack(alignment: .leading) {
                            LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .top, endPoint: .bottom)
                                .opacity(0.8)
                                .blendMode(.softLight)
                                .frame(height: 50)

                            HStack(spacing: 0) {
                                if let company = self.entity.company {
                                    Rectangle()
                                        .foregroundStyle(Color.fromStored(company.colour ?? Theme.rowColourAsDouble))
                                        .frame(width: 15)

                                    HStack {
                                        if company.abbreviation != nil {
                                            Text("\(company.abbreviation!).\(self.entity.abbreviation ?? "DE")")
                                        } else {
                                            Text("\(self.entity.abbreviation ?? "DE")")
                                        }
                                    }
                                    .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : .white)
                                    .opacity(0.7)
                                    .padding(.leading)
                                }

                                Spacer()
                                RowAddNavLink(
                                    title: "+ Job",
                                    target: AnyView(
                                        JobDetail(company: self.entity.company, project: self.entity)
                                    )
                                )
                            }
                        }
                    }
                }
                .background(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble))
            }
        }

        struct SingleDefinitionLink: View {
            public let definition: TaxonomyTermDefinitions

            var body: some View {
                NavigationLink {
                    DefinitionDetail(definition: self.definition)
                } label: {
                    ListRow(
                        name: (self.definition.job?.title ?? self.definition.job?.jid.string) ?? "_DEFINITION",
                        colour: self.definition.job?.backgroundColor ?? Theme.rowColour
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
