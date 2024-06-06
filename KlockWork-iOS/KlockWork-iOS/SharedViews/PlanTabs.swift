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
                Content(inSheet: inSheet, job: $job, selected: $selected, date: $date)
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
        @Binding public var date: Date
        @State private var selectedJobs: [Job] = []

        var body: some View {
            switch selected {
            case .daily:
                Daily(date: $date, selectedJobs: $selectedJobs)
            case .feature:
                Feature()
            }
        }
    }
}

extension PlanTabs {
    struct Daily: View {
        typealias Row = PlanRow

        @Binding public var date: Date
        @Binding public var selectedJobs: [Job]
        @State private var isJobSelectorPresent: Bool = false
        @State private var score: Int = 0

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                SelectedItems(selectedJobs: $selectedJobs)
                
                ZStack(alignment: .bottomLeading) {
                    ZStack(alignment: .topLeading){
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 1) {
                                ForEach(selectedJobs.sorted(by: {$0.project != nil && $1.project != nil ? $0.project!.name! > $1.project!.name! && $0.jid < $1.jid : $0.jid < $1.jid})) { job in // sooo sorry
                                    Row(job: job)
                                }
                            }
                        }
                    }
                    ActionBar
                }
            }
        }

        @ViewBuilder var ActionBar: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .center, spacing: 10) {
                    ActionBarAddButton
                    Spacer()
                    ActionBarScore
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

                } label: {
                    Text("Save")
                }
                .fontWeight(.bold)
                .padding(8)
                .background(.green.opacity(0.5))
                .background(.gray)

                Button {
                    selectedJobs = []
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

        @ViewBuilder var ActionBarScore: some View {
            HStack(spacing: 0) {
                Image(systemName: "\(self.score).circle")
                    .font(.title)
                    .foregroundStyle(.white)
            }
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
                .navigationTitle("Jobs")
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
            @Binding public var selectedJobs: [Job]
            @State private var taskCount: Int = 0
            @State private var jobCount: Int = 0
            @State private var noteCount: Int = 0
            @State private var projectCount: Int = 0
            @State private var companyCount: Int = 0

            var body: some View {
                VStack {
                    HStack(alignment: .center, spacing: 0) {
                        MenuItem(count: taskCount, icon: "checklist", description: "task(s) selected")
                        MenuItem(count: selectedJobs.count, icon: "hammer", description: "job(s) selected")
                        MenuItem(count: noteCount, icon: "note.text", description: "note(s) selected")
                        MenuItem(count: projectCount, icon: "folder", description: "jobs selected")
                        MenuItem(count: companyCount, icon: "building.2", description: "jobs selected")
                        Spacer()
                    }
                    .padding([.top, .bottom])
                    .background(Theme.textBackground)
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: selectedJobs) {self.actionOnAppear()}
                }
            }
            
            /// Onload handler
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                taskCount = selectedJobs.count * 2
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
            @FetchRequest private var incompleteTasks: FetchedResults<LogTask>
            @FetchRequest private var notes: FetchedResults<Note>
            @State private var isDetailsPresented: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    Row(job: job, callback: self.rowTapCallback)

                    if isDetailsPresented {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Incomplete Tasks")
                                Spacer()
                            }

                            if incompleteTasks.count > 0 {
                                VStack(alignment: .leading, spacing: 1) {
                                    ForEach(incompleteTasks) { task in
                                        PlanRowTask(task: task)
                                    }
                                }
                            } else {
                                Text("Add one")
                            }

                            HStack {
                                Text("Notes")
                                Spacer()
                            }

                            if notes.count > 0 {
                                VStack(alignment: .leading, spacing: 1) {
                                    ForEach(notes) { note in
                                        PlanRowNote(note: note)
                                    }
                                }
                            } else {
                                Text("Add one")
                            }
                        }
                        .padding()
                        .background(job.backgroundColor.opacity(0.5))
                        .background(.gray)
                    }
                }
            }

            init(job: Job) {
                self.job = job
                _incompleteTasks = CoreDataTasks.fetch(by: job)
                _notes = CoreDataNotes.fetch(by: job)
            }
            
            /// Handler for when you tap on a single row
            /// - Parameter job: Job
            /// - Returns: Void
            private func rowTapCallback(_ job: Job) -> Void {
                isDetailsPresented.toggle()
            }
        }

        struct PlanRowTask: View {
            public var task: LogTask
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: selected ? "square.fill" : "square")
                        if let content = task.content {
                            Text(content)
                        }
                    }
                }
            }
        }

        struct PlanRowNote: View {
            public var note: Note
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                } label: {
                    HStack(alignment: .center) {
                        Image(systemName: selected ? "square.fill" : "square")
                        if let title = note.title {
                            Text(title)
                        }
                    }
                }
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
