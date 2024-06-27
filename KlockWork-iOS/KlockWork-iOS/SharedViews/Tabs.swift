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
                    ForEach(EntityType.allCases, id: \.self) { page in
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
                List.Records(job: $job, date: self.state.date, inSheet: inSheet)
            case .jobs:
                List.Jobs(job: $job, date: self.state.date, inSheet: inSheet)
            case .tasks:
                List.Tasks(date: self.state.date, inSheet: inSheet)
            case .notes:
                List.Notes(date: self.state.date, inSheet: inSheet)
            case .companies:
                List.Companies(date: self.state.date, inSheet: inSheet)
            case .people:
                List.People(date: self.state.date, inSheet: inSheet)
            case .projects:
                List.Projects(date: self.state.date, inSheet: inSheet)
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
                                Individual.SingleTaskChecklistItem(task: task)
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

        struct HierarchyNavigator: View {
            public var inSheet: Bool
            public var page: PageConfiguration.AppPage = .explore
            @FetchRequest private var items: FetchedResults<Company>

            var body: some View {
                ScrollView {
                    Divider().background(.gray)
                    VStack(alignment: .leading, spacing: 0) {
                        if self.items.count > 0 {
                            ForEach(self.items.filter({$0.alive == true})) { item in
                                TopLevel(entity: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies updated within the last 7 days")
                        }
                    }
                }
                .navigationTitle("Hierarchy")
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

                public let entity: Company
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap)

                    if self.isPresented {
                        if let projects = entity.projects?.allObjects as? [Project] {
                            ForEach(projects.filter({$0.alive == true}).sorted(by: {$0.name! < $1.name!})) { project in
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

                public let entity: Project
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
                                })) { job in
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
                typealias Button = Tabs.Content.Individual.SingleJobHierarchical

                public let entity: Job
                public var page: PageConfiguration.AppPage = .create
                @State private var isPresented: Bool = false
                @State private var tasks: [LogTask] = []
                @State private var notes: [Note] = []
                @State private var colour: Color = .clear

                var body: some View {
                    Button(entity: self.entity, callback: self.actionOnTap)
                    // @TODO: refactor to follow the pattern set in previous levels
                    if self.isPresented {
                        VStack(alignment: .leading, spacing: 0) {
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
                                        } else {
                                            Text("\(self.tasks.count) Tasks")
                                        }
                                    }
                                    .padding(.leading, 8)

                                    Spacer()
                                    NavigationLink {
                                        TaskDetail(job: self.entity)
                                    } label: {
                                        Image(systemName: "plus")
                                            .padding(8)
                                    }
                                }
                            }

                            if !self.tasks.isEmpty {
                                ForEach(self.tasks) { task in
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

                                        if self.notes.isEmpty {
                                            Text("No Notes")
                                                .padding(.leading, 8)
                                        } else {
                                            Text("\(self.notes.count) Notes")
                                                .padding(.leading, 8)
                                        }

                                        Spacer()
                                        NavigationLink {
                                            NoteDetail(job: self.entity)
                                        } label: {
                                            Image(systemName: "plus")
                                                .padding(8)
                                        }
                                    }
                                }

                            if !self.notes.isEmpty {
                                ForEach(self.notes) { note in
                                    FourthLevelNotes(entity: note)
                                }
                            }
                        }
                        .onAppear(perform: self.actionOnAppear)
                        .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : .white)
                    }
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

                    self.colour = Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble)
                }

                /// Tap/click handler. Opens to show list of jobs.
                /// - Returns: Void
                private func actionOnTap(_ job: Job) -> Void {
                    self.isPresented.toggle()
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

                        Button(task: self.entity, highlight: false)
                            .border(width: 1, edges: [.bottom], color: .gray)
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
                    }
                }

                /// Tap/click handler. Opens to show list of projects.
                /// - Returns: Void
                private func actionOnTap(_ company: Company) -> Void {
                    self.isPresented.toggle()
                }
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
                            ForEach(items) { item in
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
                            ForEach(items) { item in
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
                            ForEach(items) { item in
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

                        Spacer()

                        // Open Job button
                        Button {
                            selected.toggle()
                            callback(self.entity)
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                        }
                        .frame(width: 25)
                        .padding([.leading, .trailing], 8)

                        // Entity creation buttons
                        NavigationLink {
                            JobDetail(job: self.entity)
                        } label: {
                            ListRow(
                                name: self.entity.title ?? self.entity.jid.string,
                                colour: self.entity.backgroundColor,
                                highlight: false
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
            public let task: LogTask
            public var highlight: Bool = true
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
                    .opacity(isCompleted ? 0.5 : 1.0)

                    NavigationLink {
                        TaskDetail(task: task)
                            .background(Theme.cPurple)
                            .scrollContentBackground(.hidden)
                    } label: {
                        ListRow(
                            name: task.content ?? "_TASK_CONTENT",
                            colour: task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour,
                            highlight: self.highlight
                        )
                        .opacity(isCompleted ? 0.5 : 1.0)
                    }
                    .buttonStyle(.plain)
                }
                .background(self.task.owner!.backgroundColor)
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
                } else {
                    self.task.completedDate = nil
                }

                if self.isCancelled {
                    self.task.cancelledDate = Date()
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
                        extraColumn: AnyView(VersionCountBadge)
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
                                Circle()
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                        }
                        .frame(width: 25)
                        .padding(.leading)

                        Spacer()

                        // Company link
                        NavigationLink {
                            CompanyDetail(company: self.entity)
                        } label: {
                            ListRow(
                                name: entity.name ?? "[NO NAME]",
                                colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                                highlight: false
                            )
                        }
                    }

                    if self.selected {
                        ZStack(alignment: .leading) {
                            LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .top, endPoint: .bottom)
                                .opacity(0.8)
                                .blendMode(.softLight)
                                .frame(height: 50)
                            HStack {
                                Text(self.entity.abbreviation ?? "_DEFAULT")
                                    .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : .white)
                                Spacer()
                                NavigationLink {
                                    PersonDetail(company: self.entity)
                                } label: {
                                    Image(systemName: "person.2")
                                        .padding(8)
                                        .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : .white)
                                }
                                NavigationLink {
                                    ProjectDetail(company: self.entity)
                                } label: {
                                    Image(systemName: "folder.badge.plus")
                                        .padding(8)
                                        .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : .white)
                                }
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
                        colour: Color.fromStored(person.company != nil ? person.company!.colour! : Theme.rowColourAsDouble)
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
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)

                        // Open folder button
                        Button {
                            selected.toggle()
                            callback(entity)
                        } label: {
                            ZStack(alignment: .center) {
                                Circle()
                                    .fill(.black)
                                    .opacity(0.4)
                                Image(systemName: self.selected ? "minus" : "plus")
                            }
                            .frame(width: 25)
                            .padding(.trailing, 8)
                        }
                        
                        // Project link
                        NavigationLink {
                            ProjectDetail(project: self.entity)
                        } label: {
                            ListRow(
                                name: entity.name ?? "[NO NAME]",
                                colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble),
                                highlight: false
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
                                    .padding(.leading, 8)
                                }

                                Spacer()
                                NavigationLink {
                                    JobDetail(company: self.entity.company, project: self.entity)
                                } label: {
                                    Image(systemName: "plus")
                                        .padding(8)
                                }
                            }
                        }
                    }
                }
                .background(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble))
            }
        }
    }
}
