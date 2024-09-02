//
//  PlanTabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-04.
//

import SwiftUI

struct PlanTabs: View {
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @Binding public var job: Job?
    @Binding public var selected: PlanType
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
                    .border(width: 1, edges: [.bottom], color: self.state.theme.tint)
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
                    selectedCompanies: $selectedCompanies
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
            withAnimation(.bouncy(duration: Tabs.animationDuration)) {
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
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType

        var body: some View {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 1) {
                    ForEach(PlanType.allCases, id: \.self) { page in
                        VStack {
                            Button {
                                withAnimation(.bouncy(duration: Tabs.animationDuration)) {
                                    selected = page
                                }
                            } label: {
                                page.icon
                                    .frame(maxHeight: 20)
                                    .padding(14)
                                    .background(page == selected ? Theme.darkBtnColour : .clear)
                                    .foregroundStyle(page == selected ? self.state.theme.tint : .gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Spacer()
                }
            }
            .frame(height: 50)
        }
    }

    struct Content: View {
        @EnvironmentObject private var state: AppState
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType
        @Binding public var selectedJobs: [Job]
        @Binding public var selectedTasks: [LogTask]
        @Binding public var selectedNotes: [Note]
        @Binding public var selectedProjects: [Project]
        @Binding public var selectedCompanies: [Company]

        var body: some View {
            switch selected {
            case .daily:
                Daily(
                    selectedJobs: $selectedJobs,
                    selectedTasks: $selectedTasks,
                    selectedNotes: $selectedNotes,
                    selectedProjects: $selectedProjects,
                    selectedCompanies: $selectedCompanies
                )
            case .feature:
                Feature()
            case .upcoming:
                Upcoming()
            case .overdue:
                Overdue()
            }
        }
    }
}

extension PlanTabs {
    struct Daily: View {
        typealias Row = PlanRow
        
        @EnvironmentObject private var state: AppState
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
                                        selectedJobs: $selectedJobs,
                                        selectedTasks: $selectedTasks,
                                        selectedNotes: $selectedNotes,
                                        selectedProjects: $selectedProjects,
                                        selectedCompanies: $selectedCompanies
                                    )
                                }
                            }
                        }
                    }
                    PageActionBar.Planning(
                        selectedJobs: $selectedJobs,
                        selectedTasks: $selectedTasks,
                        selectedNotes: $selectedNotes,
                        selectedProjects: $selectedProjects,
                        selectedCompanies: $selectedCompanies,
                        isPresented: $isJobSelectorPresent
                    )
                }
            }
            .onAppear(perform: self.restore)
        }

        /// Use the stored Plan
        /// - Returns: Void
        private func restore() -> Void {
            let model = CoreDataPlan(moc: self.state.moc)
            let plan = model.forToday(self.state.date).first

            if let existingPlan = plan {
                self.selectedJobs = existingPlan.jobs?.allObjects as! [Job]
                self.selectedTasks = existingPlan.tasks?.allObjects as! [LogTask]
                self.selectedNotes = existingPlan.notes?.allObjects as! [Note]
                self.selectedProjects = existingPlan.projects?.allObjects as! [Project]
                self.selectedCompanies = existingPlan.companies?.allObjects as! [Company]
                self.plan = existingPlan
            } else {
                let suggested = CoreDataTasks(moc: self.state.moc).dueToday(self.state.date)
                var sJobs: Set<Job> = []

                if !suggested.isEmpty {
                    for task in suggested {
                        if let job = task.owner {
                            sJobs.insert(job)
                        }
                    }

                    self.selectedJobs = Array(sJobs)
                }
            }
        }

        struct SelectedItems: View {
            @EnvironmentObject private var state: AppState
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
            @EnvironmentObject private var state: AppState
            var count: Int
            var icon: String
            var description: String

            var body: some View {
                HStack {
                    Text("\(count)")
                        .foregroundStyle(count > 0 ? self.state.theme.tint : .gray)
                    Image(systemName: icon)
                        .foregroundStyle(count > 0 ? self.state.theme.tint : .gray)
                        .help("\(count) \(description)")
                }
                .padding([.leading, .trailing], 8)
            }
        }

        struct PlanRow: View {
            typealias Row = Tabs.Content.Individual.SingleJobCustomButton

            @EnvironmentObject private var state: AppState
            public var job: Job
            @Binding public var selectedJobs: [Job]
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
                        HStack(alignment: .center, spacing: 0) {
                            Row(job: job, callback: self.rowTapCallback)
                            Button {
                                withAnimation(.bouncy(duration: Tabs.animationDuration)) {
                                    selectedJobs.removeAll(where: {$0 == self.job})

                                    if selectedJobs.isEmpty {
                                        CoreDataPlan(moc: self.state.moc).deleteAll(for: self.state.date)
                                    }
                                }
                            } label: {
                                ZStack(alignment: .center) {
                                    Theme.base.opacity(0.5)
                                    Image(systemName: "xmark")
                                }
                            }
                            .frame(width: 40)
                        }

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
                            if company.abbreviation != nil {
                                Button {
                                    self.isCompanyPresented.toggle()
                                } label: {
                                    Text(company.abbreviation!)
                                        .multilineTextAlignment(.leading)
                                        .underline(true, pattern: .dot)
                                }
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }

                        if project.abbreviation != nil {
                            Button {
                                self.isProjectPresented.toggle()
                            } label: {
                                Text(project.abbreviation!)
                                    .multilineTextAlignment(.leading)
                                    .underline(true, pattern: .dot)
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
                        TaskDetail()
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
                        NoteDetail.Sheet()
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
            ///   - selectedJobs: Bound variable representing selected jobs
            ///   - selectedTasks: Bound variable representing selected tasks
            ///   - selectedNotes: Bound variable representing selected notes
            ///   - selectedProjects: Bound variable representing selected projects
            ///   - selectedCompanies: Bound variable representing selected companies
            init(job: Job, selectedJobs: Binding<[Job]>, selectedTasks: Binding<[LogTask]>, selectedNotes: Binding<[Note]>, selectedProjects: Binding<[Project]>, selectedCompanies: Binding<[Company]>) {
                self.job = job
                _incompleteTasks = CoreDataTasks.fetch(by: job)
                _notes = CoreDataNotes.fetch(by: job)
                _selectedJobs = selectedJobs
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
                                .multilineTextAlignment(.leading)
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
                                .multilineTextAlignment(.leading)
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
            VStack(alignment: .center, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Text("Feature planning is coming soon")
                    Spacer()
                }
                .padding()
                .background(Theme.textBackground)
                .clipShape(.rect(cornerRadius: 16))
                Spacer()
            }
            .padding()
        }
    }

    struct UpcomingRow: Identifiable, Hashable {
        var id: UUID = UUID()
        var date: String
        var tasks: [LogTask]
    }

    struct Upcoming: View {
        typealias Row = Tabs.Content.Individual.SingleTaskDetailedChecklistItem
        
        @EnvironmentObject private var state: AppState
        @FetchRequest private var tasks: FetchedResults<LogTask>
        @State private var upcoming: [UpcomingRow] = []

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if !self.tasks.isEmpty {
                            ForEach(self.upcoming, id: \.id) { row in
                                HStack {
                                    Spacer()
                                    Text(row.date)
                                        .padding(5)
                                        .font(.caption)
                                }
                                .background(.black.opacity(0.2))
                                .border(width: 1, edges: [.bottom], color: self.state.theme.tint)

                                ForEach(row.tasks) { task in
                                    Row(task: task, callback: self.actionOnAppear)
                                }
                            }
                        } else {
                            HStack {
                                Text("No upcoming due dates")
                                Spacer()
                            }
                            .padding()
                            .background(Theme.textBackground)
                            .clipShape(.rect(cornerRadius: 16))
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: self.actionOnAppear)
        }

        init() {
            _tasks = CoreDataTasks.fetchUpcoming()
        }

        /// Onload handler
        /// - Returns: Void
        private func actionOnAppear() -> Void {
            self.upcoming = []
            let grouped = Dictionary(grouping: self.tasks, by: {$0.due!.formatted(date: .abbreviated, time: .omitted)})
            let sorted = Array(grouped)
                .sorted(by: {
                    let df = DateFormatter()
                    df.dateStyle = .medium
                    df.timeStyle = .none
                    if let d1 = df.date(from: $0.key) {
                        if let d2 = df.date(from: $1.key) {
                            return d1 < d2
                        }
                    }
                    return false
                })

            for group in sorted {
                self.upcoming.append(
                    UpcomingRow(
                        date: group.key,
                        tasks: group.value.sorted(by: {$0.due! < $1.due!})
                    )
                )
            }
        }
    }

    struct Overdue: View {
        typealias Row = Tabs.Content.Individual.SingleTaskDetailedChecklistItem

        @EnvironmentObject private var state: AppState
        @FetchRequest private var tasks: FetchedResults<LogTask>
        @State private var overdue: [UpcomingRow] = []

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 1) {
                        if !self.tasks.isEmpty {
                            ForEach(self.overdue, id: \.id) { row in
                                HStack {
                                    Spacer()
                                    Text(row.date)
                                        .padding(5)
                                        .font(.caption)
                                }
                                .background(.black.opacity(0.2))
                                .border(width: 1, edges: [.bottom], color: self.state.theme.tint)

                                ForEach(row.tasks) { task in
                                    Row(task: task, callback: self.actionOnAppear)
                                }
                            }
                        } else {
                            HStack {
                                Text("No overdue tasks!")
                                Spacer()
                            }
                            .padding()
                            .background(Theme.textBackground)
                            .clipShape(.rect(cornerRadius: 16))
                            Spacer()
                        }
                    }
                }
            }
            .onAppear(perform: self.actionOnAppear)
        }

        init() {
            _tasks = CoreDataTasks.fetchOverdue()
        }

        /// Onload handler
        /// - Returns: Void
        private func actionOnAppear() -> Void {
            self.overdue = []
            let grouped = Dictionary(grouping: self.tasks, by: {$0.due?.formatted(date: .abbreviated, time: .omitted) ?? "No Date"})
            let sorted = Array(grouped)
                .sorted(by: {
                    let df = DateFormatter()
                    df.dateStyle = .medium
                    df.timeStyle = .none
                    if let d1 = df.date(from: $0.key) {
                        if let d2 = df.date(from: $1.key) {
                            return d1 < d2
                        }
                    }
                    return false
                })

            for group in sorted {
                self.overdue.append(UpcomingRow(date: group.key, tasks: group.value))
            }
        }

        struct UpcomingRow: Identifiable, Hashable {
            var id: UUID = UUID()
            var date: String
            var tasks: [LogTask]
        }
    }
}
