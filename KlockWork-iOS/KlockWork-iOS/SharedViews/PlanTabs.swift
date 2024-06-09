//
//  PlanTabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-04.
//

import SwiftUI

struct PlanTabs: View {
    typealias PlanType = PageConfiguration.PlanType

    public var inSheet: Bool
    @Environment(\.managedObjectContext) var moc
    @Binding public var job: Job?
    @Binding public var selected: PlanType
    @Binding public var date: Date
    public var content: AnyView? = nil
    public var buttons: AnyView? = nil
    public var title: AnyView? = nil
    @State private var selectedJobs: [Job] = []
    @State private var selectedTasks: [LogTask] = []
    @State private var selectedNotes: [Note] = []
    @State private var selectedProjects: [Project] = []
    @State private var selectedCompanies: [Company] = []
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
                MiniTitleBarPlan(selected: $selected)
                    .border(width: 1, edges: [.bottom], color: .yellow)
            } else {
                title
            }

            if content == nil {
                Content(
                    inSheet: inSheet,
                    job: $job,
                    selected: $selected,
                    selectedJobs: $selectedJobs,
                    selectedTasks: $selectedTasks,
                    selectedNotes: $selectedNotes,
                    selectedProjects: $selectedProjects,
                    selectedCompanies: $selectedCompanies,
                    date: $date
                )
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                content
            }
        }
        .background(.clear)
        .onChange(of: job) {
            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                selected = .daily
            }
        }
    }
}

extension PlanTabs {
    /// Swipe action handler
    /// - Parameter swipe: Swipe
    /// - Returns: Void
    public func actionOnSwipe(_ swipe: Swipe) -> Void {
        let tabs = PlanType.allCases
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

extension PlanTabs {
    struct Buttons: View {
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType

        var body: some View {
            HStack(alignment: .center, spacing: 1) {
                ForEach(PlanType.allCases, id: \.self) { page in
                    VStack {
                        Button {
                            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                                selected = page
                            }
                        } label: {
                            page.icon
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
            .frame(height: 50)
        }
    }

    struct Content: View {
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType
        @Binding public var selectedJobs: [Job]
        @Binding public var selectedTasks: [LogTask]
        @Binding public var selectedNotes: [Note]
        @Binding public var selectedProjects: [Project]
        @Binding public var selectedCompanies: [Company]
        @Binding public var date: Date

        var body: some View {
            switch selected {
            case .daily:
                Daily(
                    date: $date,
                    selectedJobs: $selectedJobs,
                    selectedTasks: $selectedTasks,
                    selectedNotes: $selectedNotes,
                    selectedProjects: $selectedProjects,
                    selectedCompanies: $selectedCompanies
                )
            case .feature:
                Feature()
            }
        }
    }
}

extension PlanTabs {
    struct Daily: View {
        typealias Row = PlanRow
        
        @Environment(\.managedObjectContext) var moc
        @Binding public var date: Date
        @Binding public var selectedJobs: [Job]
        @Binding public var selectedTasks: [LogTask]
        @Binding public var selectedNotes: [Note]
        @Binding public var selectedProjects: [Project]
        @Binding public var selectedCompanies: [Company]
        @State private var isJobSelectorPresent: Bool = false
        @State private var plan: Plan? = nil

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                SelectedItems(
                    jobs: $selectedJobs,
                    tasks: $selectedTasks,
                    notes: $selectedNotes,
                    projects: $selectedProjects,
                    companies: $selectedCompanies
                )
                .onChange(of: selectedJobs) {
                    Task {
                        if selectedJobs.count > 0 {
                            for job in selectedJobs {
                                if let project = job.project {
                                    if !selectedProjects.contains(where: {$0 == project}) {
                                        selectedProjects.append(project)
                                    }

                                    if let company = job.project?.company {
                                        if !selectedCompanies.contains(where: {$0 == company}) {
                                            selectedCompanies.append(company)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topLeading){
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 1) {
                                ForEach(selectedJobs.sorted(by: {$0.project != nil && $1.project != nil ? $0.project!.name! > $1.project!.name! && $0.jid < $1.jid : $0.jid < $1.jid})) { job in // sooo sorry
                                    Row(
                                        job: job,
                                        selectedTasks: $selectedTasks,
                                        selectedNotes: $selectedNotes,
                                        selectedProjects: $selectedProjects,
                                        selectedCompanies: $selectedCompanies
                                    )
                                }
                            }
                        }
                    }
                    ActionBar
                }
            }
            .onAppear(perform: self.restore)
        }

        @ViewBuilder var ActionBar: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 10) {
                    ActionBarAddButton
                    Spacer()
                    ActionBarState
                }
                .background(Theme.cOrange.opacity(0.5))
            }
            .clipShape(.capsule(style: .continuous))
            .shadow(color: .black.opacity(0.4), radius: 6, x: 2, y: 2)
            .padding()
            .sheet(isPresented: $isJobSelectorPresent) {
                JobSelector(showing: $isJobSelectorPresent, selectedJobs: $selectedJobs)
            }
        }

        @ViewBuilder var ActionBarAddButton: some View {
            Button {
                self.isJobSelectorPresent.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .fontWeight(.bold)
                    .font(.largeTitle)
            }
            .padding(8)
        }

        @ViewBuilder var ActionBarState: some View {
            HStack(spacing: 0) {
                Button {
                    self.store()
                } label: {
                    Text("Save")
                }
                .fontWeight(.bold)
                .padding(8)
                .background(.green.opacity(0.5))
                .background(.gray)

                Button {
                    self.destroyPlan()
                } label: {
                    Text("Reset")
                }
                .padding(8)
                .background(.black.opacity(0.1))
                .background(.gray)
            }
            .clipShape(.capsule(style: .continuous))
            .foregroundStyle(.white)
            .padding([.trailing], 8)
        }

        /// Create a new Plan for today
        /// - Returns: Void
        private func store() -> Void {
            CoreDataPlan(moc: self.moc).create(
                date: Date(),
                jobs: Set(self.selectedJobs),
                tasks: Set(self.selectedTasks),
                notes: Set(self.selectedNotes),
                projects: Set(self.selectedProjects),
                companies: Set(self.selectedCompanies)
            )
        }
        
        /// Use the stored Plan
        /// - Returns: Void
        private func restore() -> Void {
            let model = CoreDataPlan(moc: self.moc)
            let plan = model.forToday().first

            if let existingPlan = plan {
                self.selectedJobs = existingPlan.jobs?.allObjects as! [Job]
                self.selectedTasks = existingPlan.tasks?.allObjects as! [LogTask]
                self.selectedNotes = existingPlan.notes?.allObjects as! [Note]
                self.selectedProjects = existingPlan.projects?.allObjects as! [Project]
                self.selectedCompanies = existingPlan.companies?.allObjects as! [Company]
                self.plan = existingPlan
            }
        }
        
        /// Destroy and recreate today's plan
        /// - Returns: Void
        private func destroyPlan() -> Void {
            self.selectedJobs = []
            self.selectedNotes = []
            self.selectedTasks = []
            self.selectedProjects = []
            self.selectedCompanies = []

            if self.plan != nil {
                // Delete the old plan
                do {
                    try self.plan!.validateForDelete()
                    self.moc.delete(self.plan!)
                } catch {
                    print("[error] Planning.PlanTabs Unable to delete old session due to error \(error)")
                }

                // Create a new empty plan
                self.plan = CoreDataPlan(moc: self.moc).createAndReturn(
                    date: Date(),
                    jobs: Set(),
                    tasks: Set(),
                    notes: Set(),
                    projects: Set(),
                    companies: Set()
                )
            }

            self.plan = nil
        }

        struct JobSelector: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButtonTwoState

            @FetchRequest private var items: FetchedResults<Job>
            @Binding public var showing: Bool
            @Binding private var selectedJobs: [Job]

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("What's on your plate today?")
                                .fontWeight(.bold)
                                .font(.title2)
                            Spacer()
                            Button {
                                showing.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding()

                        HStack(alignment: .center, spacing: 5) {
                            Spacer()
                            Text("Selected")
                            Text(String(selectedJobs.count))
                        }
                        .padding()

                        if items.count > 0 {
                            ForEach(items) { jerb in
                                Row(job: jerb, alreadySelected: self.jobIsSelected(jerb), callback: { job, action in
                                    if action == .add {
                                        selectedJobs.append(job)
                                    } else if action == .remove {
                                        if let index = selectedJobs.firstIndex(where: {$0 == job}) {
                                            selectedJobs.remove(at: index)
                                        }
                                    }
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No jobs modified within the last 7 days")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .presentationBackground(Theme.cOrange)
            }

            init(showing: Binding<Bool>, selectedJobs: Binding<[Job]>) {
                _showing = showing
                _selectedJobs = selectedJobs
                _items = CoreDataJob.fetchAll()
            }
            
            /// Determine if a given job is already within the selectedJobs list
            /// - Parameter job: Job
            /// - Returns: Bool
            private func jobIsSelected(_ job: Job) -> Bool {
                return selectedJobs.firstIndex(where: {$0 == job}) != nil
            }
        }

        struct SelectedItems: View {
            @Binding public var jobs: [Job]
            @Binding public var tasks: [LogTask]
            @Binding public var notes: [Note]
            @Binding public var projects: [Project]
            @Binding public var companies: [Company]

            var body: some View {
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        MenuItem(count: jobs.count, icon: "hammer", description: "job(s) selected")
                        MenuItem(count: tasks.count, icon: "checklist", description: "task(s) selected")
                        MenuItem(count: notes.count, icon: "note.text", description: "note(s) selected")
                        MenuItem(count: companies.count, icon: "building.2", description: " selected")
                        MenuItem(count: projects.count, icon: "folder", description: "project(s) selected")
                        Spacer()
                    }
                    .padding([.top, .bottom])
                    .background(Theme.textBackground)
                }
            }
        }

        struct MenuItem: View {
            var count: Int
            var icon: String
            var description: String

            var body: some View {
                HStack {
                    Text("\(count)")
                        .foregroundStyle(count > 0 ? .yellow : .gray)
                    Image(systemName: icon)
                        .foregroundStyle(count > 0 ? .yellow : .gray)
                        .help("\(count) \(description)")
                }
                .padding([.leading, .trailing], 8)
            }
        }

        struct PlanRow: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButton

            public var job: Job
            @Binding public var selectedTasks: [LogTask]
            @Binding public var selectedNotes: [Note]
            @Binding public var selectedProjects: [Project]
            @Binding public var selectedCompanies: [Company]
            @FetchRequest private var incompleteTasks: FetchedResults<LogTask>
            @FetchRequest private var notes: FetchedResults<Note>
            @State private var isDetailsPresented: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false

            var body: some View {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Row(job: job, callback: self.rowTapCallback)

                        if isDetailsPresented {
                            VStack(alignment: .leading) {
                                OwnershipHierarchy
                                IncompleteTasks
                                Notes
                            }
                            .background(job.backgroundColor.opacity(0.5))
                            .background(.gray)
                        }
                    }
                }
            }

            @ViewBuilder private var OwnershipHierarchy: some View {
                LegendLabel(label: "Path")
                    .padding([.top, .leading], 8)

                HStack(alignment: .center, spacing: 8) {
                    if let project = self.job.project {
                        if let company = project.company {
                            if company.name != nil {
                                Button {
                                    self.isCompanyPresented.toggle()
                                } label: {
                                    Text(company.name!)
                                }
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }

                        if project.name != nil {
                            Button {
                                self.isProjectPresented.toggle()
                            } label: {
                                Text(project.name!)
                            }
                        }
                    }
                    Spacer()
                }
                .padding(8)
                .background(Theme.textBackground)
                .sheet(isPresented: $isCompanyPresented) {
                    if let project = self.job.project {
                        if let company = project.company {
                            CompanyDetail(company: company)
                                .scrollContentBackground(.hidden)
                                .presentationBackground(Theme.cOrange)
                        }
                    }
                }
                .sheet(isPresented: $isProjectPresented) {
                    if let project = self.job.project {
                        ProjectDetail(project: project)
                            .scrollContentBackground(.hidden)
                            .presentationBackground(Theme.cOrange)
                    }
                }
            }

            @ViewBuilder private var IncompleteTasks: some View {
                LegendLabel(label: "Incomplete Tasks")
                    .padding([.top, .leading], 8)

                if incompleteTasks.count > 0 {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(incompleteTasks) { task in
                            PlanRowTask(task: task, callback: self.taskRowTapCallback)
                        }
                    }
                } else {
                    NavigationLink {

                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New")
                            Spacer()
                        }
                    }
                    .padding(8)
                    .background(Theme.textBackground)
                }
            }

            @ViewBuilder private var Notes: some View {
                LegendLabel(label: "Notes")
                    .padding([.top, .leading], 8)

                if notes.count > 0 {
                    VStack(alignment: .leading, spacing: 1) {
                        ForEach(notes) { note in
                            PlanRowNote(note: note, callback: self.noteRowTapCallback)
                        }
                    }
                } else {
                    NavigationLink {

                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus")
                            Text("New")
                            Spacer()
                        }
                    }
                    .padding(8)
                    .background(Theme.textBackground)
                }
            }
            
            /// Default init
            /// - Parameters:
            ///   - job: Job
            ///   - selectedTasks: Bound variable representing selected tasks
            ///   - selectedNotes: Bound variable representing selected notes
            ///   - selectedProjects: Bound variable representing selected projects
            ///   - selectedCompanies: Bound variable representing selected companies
            init(job: Job, selectedTasks: Binding<[LogTask]>, selectedNotes: Binding<[Note]>, selectedProjects: Binding<[Project]>, selectedCompanies: Binding<[Company]>) {
                self.job = job
                _incompleteTasks = CoreDataTasks.fetch(by: job)
                _notes = CoreDataNotes.fetch(by: job)
                _selectedTasks = selectedTasks
                _selectedNotes = selectedNotes
                _selectedProjects = selectedProjects
                _selectedCompanies = selectedCompanies
            }
            
            /// Handler for when you tap on a single row
            /// - Parameter job: Job
            /// - Returns: Void
            private func rowTapCallback(_ job: Job) -> Void {
                isDetailsPresented.toggle()
            }
            
            /// Handler for tapping on a task
            /// - Parameters:
            ///   - task: LogTask
            ///   - action: ButtonAction
            /// - Returns: Voit
            private func taskRowTapCallback(_ task: LogTask, _ action: ButtonAction) -> Void {
                if action == .add {
                    selectedTasks.append(task)
                } else if action == .remove {
                    if let index = selectedTasks.firstIndex(where: {$0 == task}) {
                        selectedTasks.remove(at: index)
                    }
                }
            }
            
            /// Handler for tapping on a note
            /// - Parameters:
            ///   - note: Note
            ///   - action: ButtonAction
            /// - Returns: Void
            private func noteRowTapCallback(_ note: Note, _ action: ButtonAction) -> Void {
                if action == .add {
                    selectedNotes.append(note)
                } else if action == .remove {
                    if let index = selectedNotes.firstIndex(where: {$0 == note}) {
                        selectedNotes.remove(at: index)
                    }
                }
            }
        }

        struct PlanRowTask: View {
            public var task: LogTask
            public var callback: (LogTask, ButtonAction) -> Void
            public let type: ButtonType = .button
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: self.selected ? "square.fill" : "square")
                        if let content = self.task.content {
                            Text(content)
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .background(Theme.textBackground)
            }
            
            /// Tap action handler
            /// - Returns: Void
            private func actionOnTap() -> Void {
                self.selected.toggle()
                callback(self.task, self.selected ? .add : .remove)
            }
        }

        struct PlanRowNote: View {
            public var note: Note
            public var callback: (Note, ButtonAction) -> Void
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    self.actionOnTap()
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: selected ? "square.fill" : "square")
                        if let title = note.title {
                            Text(title)
                        }
                        Spacer()
                    }
                }
                .padding(8)
                .background(Theme.textBackground)
            }

            /// Tap action handler
            /// - Returns: Void
            private func actionOnTap() -> Void {
                selected.toggle()
                callback(note, selected ? .add : .remove)
            }
        }
    }

    struct Feature: View  {
        var body: some View {
            VStack {
                HStack {
                    Text("Feature planning is coming soon")
                    Spacer()
                }
                .padding()
                .background(Theme.textBackground)
                .clipShape(.rect(cornerRadius: 16))
            }
            .padding()
        }
    }
}
