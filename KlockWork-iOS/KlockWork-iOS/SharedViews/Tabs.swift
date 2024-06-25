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
                    ForEach(EntityType.allCases.filter({$0 != .jobs}), id: \.self) { page in
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
            case .omni:
                List.HierarchyNavigator(inSheet: inSheet)
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
                _items = CoreDataTasks.fetch(for: self.date, daysPrior: 2)
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
                _items = CoreDataNotes.fetch(for: self.date, daysPrior: 2)
            }
        }

        struct HierarchyNavigator: View {
            public var inSheet: Bool
            @FetchRequest private var items: FetchedResults<Company>

            var body: some View {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if self.items.count > 0 {
                            ForEach(self.items) { item in
                                TopLevel(entity: item)
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies updated within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .navigationTitle("Hierarchy")
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
                            ForEach(projects.sorted(by: {$0.name! < $1.name!})) { project in
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
                                ForEach(jobs.sorted(by: {
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
                @State private var isPresented: Bool = false

                var body: some View {
                    Button(entity: self.entity)
                }

                /// Tap/click handler. Opens to show list of jobs.
                /// - Returns: Void
                private func actionOnTap(_ job: Job) -> Void {
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

        struct SingleJobCustomButtonTwoState: View {
            public let job: Job
            public var alreadySelected: Bool
            public var callback: (Job, ButtonAction) -> Void
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
                        selected: $selected
                    )
                }
                .buttonStyle(.plain)
                .onAppear(perform: {
                    selected = alreadySelected
                })
            }
        }

        struct SingleJobHierarchical: View {
            public let entity: Job
            @State private var selected: Bool = false

            var body: some View {
                NavigationLink {
                    JobDetail(job: self.entity)
                } label: {
                    HStack(spacing: 0) {
                        Image(systemName: "hammer")
                            .padding([.top, .bottom, .trailing], 8)
                            .padding(.leading, 16 * 3)
                        ListRow(
                            name: self.entity.title ?? self.entity.jid.string,
                            colour: self.entity.backgroundColor
                        )
                    }
                    .background(Color.fromStored(self.entity.colour ?? Theme.rowColourAsDouble))
                }
                .buttonStyle(.plain)
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
                            colour: task.owner != nil ? task.owner!.backgroundColor : Theme.rowColour
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
                HStack(spacing: 0) {
                    ZStack(alignment: .trailing) {
                        LinearGradient(gradient: Gradient(colors: [.clear, .black]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(width: 40)

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
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing], 16)
                    }

                    // Company link
                    NavigationLink {
                        CompanyDetail(company: self.entity)
                    } label: {
                        ListRow(
                            name: entity.name ?? "[NO NAME]",
                            colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble)
                        )
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

        struct SingleProjectHierarchical: View {
            public let entity: Project
            public var callback: (Project) -> Void
            @State private var selected: Bool = false

            var body: some View {
                HStack(spacing: 0) {
                    // Open folder button
                    ZStack(alignment: .leading) {
                        LinearGradient(gradient: Gradient(colors: [.white, .clear]), startPoint: .leading, endPoint: .trailing)
                            .opacity(0.6)
                            .blendMode(.softLight)
                            .frame(width: 40)

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
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], 25)
                        }
                    }

                    // Project link
                    NavigationLink {
                        ProjectDetail(project: self.entity)
                    } label: {
                        ListRow(
                            name: entity.name ?? "[NO NAME]",
                            colour: Color.fromStored(entity.colour ?? Theme.rowColourAsDouble)
                        )
                    }
                }
                .background(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble))
            }
        }
    }
}
