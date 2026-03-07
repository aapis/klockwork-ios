//
//  Widget.Tasks.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-26.
//

import SwiftUI

extension Widget {
    struct Tasks {
        // MARK: Widget.Tasks.TaskBlock
        struct TaskBlock: View {
            @EnvironmentObject private var state: AppState
            @FetchRequest private var tasks: FetchedResults<LogTask>
            public var colour: Color = .clear
            public var fgColour: Color? = nil
            public var label: String = "Block"
            public var icon: String = "circle.circle.fill"
            public var predicate: NSPredicate
            public var target: AnyView? = nil
            public var infoView: AnyView? = nil
            public var des: Int = 0 // @TODO: delete entirely
            public var help: String? = nil

            var body: some View {
                NavigationLink {
                    if self.des == 1 {
                        PlanTabs.TasksByPredicate(predicate: self.predicate)
                            .navigationTitle(self.label)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    if let view = self.infoView {
                                        NavigationLink {
                                            view
                                        } label: {
                                            Image(systemName: "info.circle")
                                        }
                                    }
                                }
                            }
                    } else {
                        if let trgt = self.target {
                            trgt
                                .navigationTitle(self.label)
                        }
                    }
                } label: {
                    if self.des == 0 {
                        self.desOne
                    } else if self.des == 1 {
                        self.desTwo
                    }
                }
                .disabled(self.tasks.isEmpty)
            }

            var desOne: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Image(systemName: self.icon)
                            .font(.title)
                            .foregroundStyle(self.colour)
                        Spacer()
                        Text(String(self.tasks.count))
                            .font(.title2)
                            .bold()
                    }
                    .padding(.bottom, 25)
                    HStack(alignment: .center) {
                        Text(self.label)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .opacity(0.3)
                            .font(.caption)
                    }
                }
                .padding()
                .background(
                    ZStack {
                        Theme.textBackground
                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                )
            }

            // @TODO: holy shit get rid of this A/B testing shit and self.des property
            // KEEP this one tho
            var desTwo: some View {
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        SectionTitle(
                            label: self.label,
                            uppercase: false,
                            fgColour: self.fgColour != nil ? self.fgColour! : self.tasks.count == 0 ? .white : Theme.base,
                            icon: self.icon,
                            font: .body
                        )
                        Spacer()
                        SectionTitle(
                            label: String(self.tasks.count),
                            uppercase: false,
                            fgColour: self.fgColour != nil ? self.fgColour! : self.tasks.count == 0 ? .white : Theme.base,
                            font: .body
                        )
                        Image(systemName: "chevron.right")
                            .opacity(0.3)
                    }
                    .bold()
                    .padding(4)
                    if let path = self.help {
                        Divider().background(.gray).frame(height: 1)
                        HStack {
                            Spacer()
                            Text(path.uppercased())
                                .multilineTextAlignment(.trailing)
                                .font(.caption)
                                .monospaced()
                                .foregroundStyle(self.fgColour == Theme.base ? Theme.lightBase : Theme.lightWhite)
                        }
                        .padding(2)
                    }
                }
                .foregroundStyle(self.fgColour != nil ? self.fgColour! : self.tasks.count == 0 ? Theme.lightWhite : Theme.base)
                .background(self.tasks.count == 0 ? .gray : self.colour == .clear ? self.tasks.count == 0 ? .gray : self.tasks.count < 10 ? .yellow : self.tasks.count < 20 ? .orange : .red : self.colour) // HAHA SO SORRY THO
                .clipShape(.rect(cornerRadius: 4))
            }
        }

        // MARK: Widget.Tasks.CheckLists
        struct CheckLists: View {
            @EnvironmentObject private var state: AppState
            @FetchRequest private var checklists: FetchedResults<Checklist>
            private var columns: [GridItem] {Array(repeating: GridItem(.flexible()), count: 2)}

            var body: some View {
                VStack(alignment: .leading) {
                    HStack(alignment: .top) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                        SectionTitle(
                            label: "Checklists",
                            uppercase: true,
                            fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : .white
                        )
                        Spacer()
                        NavigationLink {
                            ChecklistActivity()
                                .background(Theme.cPurple)
                        } label: {
                            Image(systemName: "chevron.right.circle.fill")
                        }
                    }
                    .padding([.leading, .top], 4)
                    VStack(alignment: .leading, spacing: 4) {
                        if self.checklists.isEmpty {
                            HStack {
                                Text("...")
                                Spacer()
                            }
                            .padding(4)
                            .background(.gray)
                            .clipShape(.rect(cornerRadius: 4))
                        } else {
                            LazyVGrid(columns: self.columns, alignment: .leading) {
                                ForEach(self.checklists, id: \.self) { list in
                                    ShowChecklistButton(checklist: list)
                                }
                            }
                        }
                    }
                }
                .padding(4)
                .background(
                    ZStack {
                        (self.state.job?.backgroundColor ?? Theme.textBackground)
                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }

            init() {
                _checklists = CoreDataChecklists.fetch(
                    with: NSPredicate(
                        format: "created < %@ && starred == true",
                        Date.distantFuture as CVarArg
                    ),
                    sort: [
                        NSSortDescriptor(keyPath: \Checklist.starred, ascending: false)
                    ],
                    limit: 4
                )
            }

            struct ShowChecklistButton: View {
                @EnvironmentObject private var state: AppState
                public var checklist: Checklist
                @State private var isListPresented: Bool = false
                @State private var remainingCount: Int = 0
                @State private var backgroundColour: Color = .clear

                var body: some View {
                    Button {
                        self.isListPresented.toggle()
                    } label: {
                        VStack(alignment: .leading, spacing: 1) {
                            VStack(alignment: .leading, spacing: 1) {
                                HStack {
                                    Text(self.checklist.label ?? "_NO_NAME")
                                        .lineLimit(1)
                                        .strikethrough(self.remainingCount == 0)
                                    Spacer()
                                    Text(String(self.remainingCount))
                                    Image(systemName: self.remainingCount == 0 ? "fireworks" : "chevron.up")
                                        .font(.caption)
                                        .opacity(0.3)
                                }
                                .bold()
                            }
                            .padding(4)
                            .background(self.backgroundColour)
                            .foregroundStyle(self.backgroundColour.isBright() ? Theme.base : .white)
                            if let overview = self.checklist.overview {
                                HStack(alignment: .top, spacing: 0) {
                                    Text(overview)
                                        .multilineTextAlignment(.leading)
                                        .font(.caption)
                                        .foregroundStyle(Theme.lightWhite)
                                    Spacer()
                                }
                                .padding(4)
                                .background(Theme.textBackground)
                            }
                            Spacer()
                        }
                        .clipShape(.rect(cornerRadius: 4))
                    }
                    .sheet(isPresented: self.$isListPresented) {
                        ChecklistView(checklist: self.checklist)
                            .onDisappear(perform: self.actionOnAppear)
                    }
                    .onAppear(perform: self.actionOnAppear)
                }

                /// Onload handler. Sets view state.
                /// - Returns: Void
                private func actionOnAppear() -> Void {
                    if let tasks = self.checklist.tasks?.allObjects as? [LogTask] {
                        let currentComplete = tasks.filter {$0.completedDate != nil}
                        self.remainingCount = (self.checklist.tasks?.count ?? 0) - currentComplete.count
                    }

                    self.backgroundColour = self.checklist.backgroundColour
                }
            }
        }

        // MARK: Widget.Tasks.ChecklistView
        // @TODO: move to another namespace
        struct ChecklistView: View {
            @EnvironmentObject private var state: AppState
            @AppStorage("home.backgroundWallpaper") private var homeWallpaper: String = ""
            @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false
            public var checklist: Checklist
            public var inSheet: Bool = true
            @State private var tasks: [LogTask] = []
            @State private var outcomes: [LogTask] = []
            @State private var selected: [LogTask] = []
            @State private var backgroundColour: Color = .clear
            @State private var id: UUID = UUID()

            var body: some View {
                NavigationStack {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 0) {
                            VStack(alignment: .leading) {
                                if self.inSheet {
                                    HStack {
                                        Spacer()
                                        Capsule()
                                            .fill(Theme.lightWhite)
                                            .frame(width: 100, height: 6)
                                            .opacity(0.7)
                                        Spacer()
                                    }
                                    .padding([.leading, .trailing, .bottom])
                                }
                                HStack {
                                    Text(self.checklist.label ?? "_INVALID_LABEL")
                                        .font(.title)
                                        .bold()
                                    Spacer()
                                }
                                HStack(alignment: .top) {
                                    if self.checklist.overview != nil {
                                        Text(self.checklist.overview!)
                                            .multilineTextAlignment(.leading)
                                            .font(.headline)
                                            .italic()
                                            .foregroundStyle(self.backgroundColour.isBright() ? Theme.lightBase : Theme.lightWhite)
                                    }
                                    Spacer()
                                    Button {
                                        self.actionOnReset()
                                    } label: {
                                        Image(systemName: "arrow.clockwise.circle.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.title)
                                    }
                                    .buttonStyle(.plain)
                                    .foregroundStyle(self.state.theme.tint)
                                    .disabled(self.selected.count == 0)
                                    NavigationLink {
                                        ChecklistDetail(checklist: self.checklist)
                                            .onDisappear(perform: self.actionOnAppear)
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .symbolRenderingMode(.hierarchical)
                                            .font(.title)
                                    }
                                    .foregroundStyle(self.state.theme.tint)
                                }
                            }
                            .padding()
                            .background(Theme.lightBase)
                            .foregroundStyle(self.backgroundColour.isBright() ? Theme.base : .white)
                            Divider().background(.white)
                            ZStack(alignment: .top) {
                                LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 50)
                                    .blendMode(.softLight)
                                    .opacity(0.5)
                                ScrollView(.vertical, showsIndicators: false) {
                                    VStack(alignment: .leading, spacing: 0) {
                                        if self.tasks.count > 0 {
                                            ForEach(self.tasks, id: \.self) { task in
                                                Tabs.Content.Individual.SingleChecklistTask(
                                                    task: task,
                                                    label: task.title ?? task.content ?? "_INVALID_TASK_TITLE",
                                                    checklist: self.checklist,
                                                    callback: {
                                                        if task.isOpen {
                                                            CoreDataTasks(moc: self.state.moc).complete(task, legacyAuditTrail: false)
                                                        } else {
                                                            CoreDataTasks(moc: self.state.moc).reopen(task)
                                                        }
                                                    },
                                                    isComplete: task.completedDate != nil,
                                                    isCancelled: task.cancelledDate != nil,
                                                    selectedTasks: self.$selected
                                                )
                                            }
                                        } else {
                                            Tabs.Content.Individual.MythicalSingleBlank(label: "None yet")
                                        }

                                        if self.outcomes.count > 0 {
                                            VStack(alignment: .leading) {
                                                HStack {
                                                    Text("Outcomes")
                                                    Spacer()
                                                }
                                                .font(.title2)
                                                .bold()
                                                .padding([.leading, .trailing])
                                                .foregroundStyle(self.backgroundColour.isBright() ? Theme.base : .white)
                                                if self.outcomes.count > 0 {
                                                    ForEach(self.outcomes, id: \.self) { task in
                                                        Tabs.Content.Individual.SingleChecklistTask(
                                                            task: task,
                                                            label: task.title ?? task.content ?? "_INVALID_TASK_TITLE",
                                                            checklist: self.checklist,
                                                            callback: {
                                                                if task.isOpen {
                                                                    CoreDataTasks(moc: self.state.moc).complete(task, legacyAuditTrail: false)
                                                                } else {
                                                                    CoreDataTasks(moc: self.state.moc).reopen(task)
                                                                }
                                                            },
                                                            isComplete: task.completedDate != nil,
                                                            isCancelled: task.cancelledDate != nil,
                                                            selectedTasks: self.$selected
                                                        )
                                                    }
                                                }
                                            }
                                            .padding([.top, .bottom])
                                            .background(
                                                ZStack(alignment: .top) {
                                                    Theme.textBackground
                                                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                                                        .blendMode(.softLight)
                                                        .opacity(0.5)
                                                }
                                            )
                                            .padding(.top)
                                        }
                                    }
                                    .padding(.top)
                                    .padding(.top) // 2 of these is intentional
                                }
                                HStack {
                                    Spacer()
                                    Text("\(self.selected.count)/\(self.tasks.count)")
                                        .monospaced()
                                }
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom], 8)
                                .foregroundStyle(self.backgroundColour.isBright() ? Theme.base : .white)
                            }
                        }
                    }
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.selected) {
                    self.actionOnAppear()
                }
                .onChange(of: self.tasks) {
                    self.actionOnAppear()
                }
                .onChange(of: self.outcomes) {
                    self.actionOnAppear()
                }
                // @TODO: do some cool WP overlay of bg colour maybe?
//                .background(
//                    ZStack {
//                        if !self.shouldUseWPImage {
//                            self.state.theme.page.primaryColour
//                        } else {
//                            Image("wallpaper-\(self.homeWallpaper)")
//                        }
//                    }
//                    .ignoresSafeArea(.all)
//                )
                .background(self.backgroundColour)
                .id(self.id)
//                .navigationTitle(self.checklist.label ?? "")
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Button {
//
//                        } label: {
//                            Text("Reset")
//                        }
//                    }
//                    ToolbarItem(placement: .topBarTrailing) {
//                        NavigationLink {
//                            ChecklistDetail(checklist: self.checklist)
//                        } label: {
//                            Text("Edit")
//                        }
//                    }
//                }
            }
            
            /// Onload handler. Sets list iof tasks.
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.tasks = (self.checklist.tasks?.allObjects as? [LogTask] ?? [])
//                    .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})
                    .sorted(by: {$0.title ?? "" < $1.title ?? ""})
                self.outcomes = (self.checklist.outcomes?.allObjects as? [LogTask] ?? [])
//                    .sorted(by: {$0.created ?? Date() < $1.created ?? Date()})
                    .sorted(by: {$0.title ?? "" < $1.title ?? ""})
                self.selected = self.tasks.filter {$0.isComplete == true}
                self.backgroundColour = self.checklist.backgroundColour
            }
            
            /// Fires when Reset button is tapped.
            /// - Returns: Void
            private func actionOnReset() -> Void {
                for t in self.tasks {
                    t.completedDate = nil
                    t.cancelledDate = nil
                }

                for t in self.outcomes {
                    t.completedDate = nil
                    t.cancelledDate = nil
                }

                PersistenceController.shared.save()
                self.id = UUID()
            }
        }

        // MARK: Widget.Tasks.DailyOverview
        struct DailyOverview: View {
            @EnvironmentObject private var state: AppState
            private var col2: [GridItem] { Array(repeating: .init(.flexible()), count: 2) }
            @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false

            var body: some View {
                VStack(alignment: .leading) {
                    SectionTitle(
                        label: "Daily Overview",
                        uppercase: true,
                        fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : .white
                    )
                    .padding([.leading, .top], 4)
                    VStack(alignment: .leading, spacing: 1) {
                        LazyVGrid(columns: self.col2, alignment: .leading) {
                            VStack(spacing: 1) {
                                Widget.Tasks.TaskBlock(
                                    colour: .green,
                                    label: "Today",
                                    icon: "circle.circle.fill",
                                    predicate: NSPredicate(
                                        format:  DateHelper.isToday(self.state.date) ? "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)" : "due > %@ && due <= %@ && (owner.project.company.hidden == false)",
                                        DateHelper.startOfDay(self.state.date) as CVarArg,
                                        DateHelper.endOfDay(self.state.date)! as CVarArg,
                                    ),
                                    des: 1
                                )
                                VStack {
                                    SmartStatisticRow(
                                        label: "Completed",
                                        predicate: NSPredicate(
                                            format: "completedDate > %@ && completedDate <= %@ && (cancelledDate == nil && owner.project.company.hidden == false)",
                                            DateHelper.startOfDay(self.state.date) as CVarArg,
                                            DateHelper.endOfDay(self.state.date)! as CVarArg
                                        )
                                    )
                                    SmartStatisticRow(
                                        label: "Created",
                                        predicate: NSPredicate(
                                            format: "created > %@ && created <= %@ && (owner.project.company.hidden == false)",
                                            DateHelper.startOfDay(self.state.date) as CVarArg,
                                            DateHelper.endOfDay(self.state.date)! as CVarArg
                                        )
                                    )
                                    SmartStatisticRow(
                                        label: "Updated",
                                        predicate: NSPredicate(
                                            format:  DateHelper.isToday(self.state.date) ? "lastUpdate > %@ && lastUpdate <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)" : "lastUpdate > %@ && lastUpdate <= %@ && (owner.project.company.hidden == false)",
                                            DateHelper.startOfDay(self.state.date) as CVarArg,
                                            DateHelper.endOfDay(self.state.date)! as CVarArg
                                        )
                                    )
                                }
                                .padding(4)
                                .background(
                                    ZStack {
                                        Theme.textBackground
                                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                    }
                                )
                                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                TaskBlock(
                                    colour: .blue,
                                    label: "Upcoming",
                                    icon: "tray.circle.fill",
                                    predicate: NSPredicate(
                                        format: "due >= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                        (DateHelper.startOfDay(self.state.date + 86400))  as CVarArg, // +1 day to exclude today's items
                                    ),
                                    des: 1
                                )
                                VStack {
                                    SmartStatisticRow(
                                        label: "Tomorrow",
                                        predicate: NSPredicate(
                                            format: "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            DateHelper.startOfDay(self.state.date + 86400) as CVarArg,
                                            DateHelper.endOfDay(self.state.date + 86400)! as CVarArg
                                        )
                                    )
                                    // @TODO: this one doesn't work, needs to use start/endOfWeek (new DateHelper methods)
                                    SmartStatisticRow(
                                        label: "Next Week",
                                        predicate: NSPredicate(
                                            format: "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            self.state.date.startOfWeek! + (86400*7) as CVarArg,
                                            self.state.date.endOfWeek! + (86400*7) as CVarArg
                                        )
                                    )
                                    SmartStatisticRow(
                                        label: "This Month",
                                        predicate: NSPredicate(
                                            format: "due > %@ && due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            self.state.date.startOfMonth! as CVarArg,
                                            self.state.date.endOfMonth! as CVarArg
                                        )
                                    )
                                }
                                .padding(4)
                                .background(
                                    ZStack {
                                        Theme.textBackground
                                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                    }
                                )
                                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                TaskBlock(
                                    colour: .red,
                                    label: "Overdue",
                                    icon: "exclamationmark.circle.fill",
                                    predicate: NSPredicate(
                                        format: "due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                        self.state.date.startOfDay! as CVarArg
                                    ),
                                    des: 1
                                )
                                VStack {
                                    SmartStatisticRow(
                                        label: "Yesterday",
                                        predicate: NSPredicate(
                                            format: "due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            self.state.date.endOfDay! - 86400 as CVarArg
                                        )
                                    )
                                    SmartStatisticRow(
                                        label: "This Week",
                                        predicate: NSPredicate(
                                            format: "due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            self.state.date.endOfWeek! as CVarArg
                                        )
                                    )
                                    SmartStatisticRow(
                                        label: "This Month",
                                        predicate: NSPredicate(
                                            format: "due <= %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                            self.state.date.endOfMonth! as CVarArg
                                        )
                                    )
                                }
                                .padding(4)
                                .background(
                                    ZStack {
                                        Theme.textBackground
                                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                    }
                                )
                                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                            }
                            VStack(alignment: .leading, spacing: 1) {
                                TaskBlock(
                                    label: "Delayed",
                                    icon: "archivebox.circle.fill",
                                    predicate: NSPredicate(
                                        format: DateHelper.isToday(self.state.date) ? "delayCount > 0 && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)" : "delayCount > 0 && (owner.project.company.hidden == false)"
                                    ),
                                    target: AnyView(PlanTabs.Upcoming()),
                                    des: 1
                                )
                                VStack {
                                    StatisticRow(
                                        label: "Today"
                                    )
                                    StatisticRow(
                                        label: "Next Week"
                                    )
                                    StatisticRow(
                                        label: "This Month"
                                    )
                                }
                                .padding(4)
                                .background(
                                    ZStack {
                                        Theme.textBackground
                                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                    }
                                )
                                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Theme.lightWhite)
                }
                .padding(4)
                .background(
                    ZStack {
                        (self.state.job?.backgroundColor ?? Theme.textBackground)
                        LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }

        struct SectionTitle: View {
            public let label: String
            public var uppercase: Bool = true
            public var fgColour: Color = .white.opacity(0.6)
            public var icon: String? = nil
            public var alignment: Alignment = .leading
            public var font: Font = .caption

            var body: some View {
                HStack(spacing: self.label == "" ? 0 : 8) {
                    if self.alignment == .trailing {
                        Spacer()
                    }
                    if let icon = self.icon {
                        Image(systemName: icon)
                            .symbolRenderingMode(.hierarchical)
                    }
                    Text(self.uppercase ? self.label.uppercased() : self.label)
                        .lineLimit(1)
                }
                .font(self.font)
                .foregroundStyle(self.fgColour)
            }
        }

        struct SectionSubTitle: View {
            public let label: String
            public var uppercase: Bool = true
            public var fgColour: Color = .white.opacity(0.6)

            var body: some View {
                HStack {
                    Text(self.uppercase ? self.label.uppercased() : self.label)
                        .font(.caption2)
                        .foregroundStyle(self.fgColour)
                }
            }
        }

        struct ScrollIndicator: View {
            @EnvironmentObject private var state: AppState

            var body: some View {
                HStack(spacing: 0) {
                    Divider()
                        .foregroundStyle(.white.opacity(0.6))
                    VStack {
                        Image(systemName: "chevron.up")
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding(2)
                    .font(.system(size: 6))
                    .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite)
                }
            }
        }

        struct SmartStatisticRow: View {
            @EnvironmentObject private var state: AppState
            public var label: String
            public var predicate: NSPredicate
            @FetchRequest private var items: FetchedResults<LogTask>

            var body: some View {
                HStack {
                    Text(self.label)
                    Spacer()
                    Text(String(self.items.count))
                }
                .foregroundStyle((self.state.job?.backgroundColor ?? Theme.base).isBright() ? Theme.base : Theme.lightWhite)
            }
        }

        struct StatisticRow: View {
            @EnvironmentObject private var state: AppState
            public var label: String
            public var value: Int = 0

            var body: some View {
                HStack {
                    Text(self.label)
                    Spacer()
                    Text(String(self.value))
                }
                .foregroundStyle((self.state.job?.backgroundColor ?? Theme.base).isBright() ? Theme.base : Theme.lightWhite)
            }
        }
    }
}

extension Widget.Tasks.TaskBlock {
    init(colour: Color = .clear, fgColour: Color? = nil, label: String, icon: String, predicate: NSPredicate, target: AnyView? = nil, infoView: AnyView? = nil, des: Int = 0, help: String? = nil) {
        self.colour = colour
        self.fgColour = fgColour
        self.label = label
        self.icon = icon
        self.target = target
        self.predicate = predicate
        self.des = des
        self.help = help
        self.infoView = infoView
        _tasks = CoreDataTasks.fetch(with: predicate)
    }
}

extension Widget.Tasks.SmartStatisticRow {
    init(label: String, predicate: NSPredicate) {
        self.label = label
        self.predicate = predicate
        _items = CoreDataTasks.fetch(with: predicate)
    }
}
