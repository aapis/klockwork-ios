//
//  Tabs.Content.Individual.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-19.
//

import SwiftUI

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
                            VStack(alignment: .leading, spacing: 1) {
                                Timestamp(text: (record.timestamp ?? Date()).formatted(date: .omitted, time: .shortened), alignment: .trailing)
                                    .frame(maxWidth: 55)
                            }
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

        struct SingleRecordDetailedLink: View {
            @EnvironmentObject private var state: AppState
            @Environment(\.dismiss) private var dismiss
            public var record: LogRecord?
            public var callback: ((LogRecord?) -> Void)? = nil
            public var onActionDelete: (() -> Void)? = nil
            public var onAction: (() -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            @State private var isDeleteAlertPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.record != nil {
                        NavigationLink {
                            RecordDetail(record: self.record)
                                .background(self.page.primaryColour)
                                .scrollContentBackground(.hidden)
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.record?.message ?? "_RECORD_CONTENT")
                                    .multilineTextAlignment(.leading)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }

                        if self.record?.timestamp != nil {
                            Timestamp(text: self.record!.timestamp!.formatted(date: .omitted, time: .shortened), fullWidth: false, alignment: .trailing)
                                .foregroundStyle((self.record?.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
                .frame(minHeight: 45)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.record?.job?.backgroundColor ?? Theme.rowColour), type: .records)
                )
                .foregroundStyle((self.record?.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                .swipeActions(edge: .trailing) {
                    Button {
                        self.actionOnSoftDelete()

                        if let onDelete = self.onActionDelete {
                            onDelete()
                        }

                        if let onAction = self.onAction {
                            onAction()
                        }
                    } label: {
                        Image(systemName: "eye.slash")
                    }
                    .tint(.purple)
                    Button(role: .destructive) {
                        self.actionOnHardDelete()

                        if let onDelete = self.onActionDelete {
                            onDelete()
                        }

                        if let onAction = self.onAction {
                            onAction()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
            }

            /// Soft delete a Task
            /// - Returns: Void
            private func actionOnSoftDelete() -> Void {
                if self.record != nil {
                    self.record!.alive = false
                }

                PersistenceController.shared.save()
                dismiss()
            }

            /// Hard delete a Task
            /// - Returns: Void
            private func actionOnHardDelete() -> Void {
                if self.record != nil {
                    self.state.moc.delete(self.record!)
                }

                PersistenceController.shared.save()
                dismiss()
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
                                .lineLimit(1)
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
                        colour: job.backgroundColor
//                        icon: selected ? "chevron.up" : "chevron.down"
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
            public var showToggleIcon: Bool = true
            @State private var selected: Bool = false

            var body: some View {
                Button {
                    selected.toggle()
                    callback(job, selected ? .add : .remove)
                } label: {
                    ToggleableListRow(
                        name: job.title ?? job.jid.string,
                        colour: job.backgroundColor,
                        iconOff: self.showToggleIcon ? "square" : nil,
                        iconOn: self.showToggleIcon ? "square.fill" : nil,
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

        struct SingleJobDetailedLink: View {
            @EnvironmentObject private var state: AppState
            public var job: Job?
            public var callback: ((Job?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    NavigationLink {
                        JobDetail(job: job)
                    } label: {
                        HStack(alignment: .center) {
                            Text(job?.title ?? job?.jid.string ?? "Job title")
                                .lineLimit(1)

                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 8) {
                            if let project = self.job?.project {
                                if let company = project.company {
                                    if company.abbreviation != nil {
                                        Button {
                                            self.isCompanyPresented.toggle()
                                        } label: {
                                            Text(company.abbreviation!)
                                                .lineLimit(1)
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
                                            .lineLimit(1)
                                            .underline(true, pattern: .dot)
                                    }
                                }
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 8) {
                            Spacer()
                            HStack {
                                Text("\(self.job?.tasks?.count ?? 0)")
                                Image(systemName: "checklist")
                                    .help("\(self.job?.tasks?.count ?? 0) task(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                            HStack {
                                Text("\(self.job?.tasks?.count ?? 0)")
                                Image(systemName: "note.text")
                                    .help("\(self.job?.tasks?.count ?? 0) note(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                            HStack {
                                Text("\(self.job?.records?.count ?? 0)")
                                Image(systemName: "tray.fill")
                                    .help("\(self.job?.tasks?.count ?? 0) records(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.job?.backgroundColor ?? Theme.rowColour), type: .jobs)
                )
                .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
            }
        }

        struct SingleJobDetailedCustomButton: View {
            @EnvironmentObject private var state: AppState
            @State public var job: Job?
            public var callback: ((Job?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    Button {
                        if let cb = self.callback { cb(self.job ?? nil) }
                    } label: {
                        HStack(alignment: .center) {
                            Text(job?.title ?? job?.jid.string ?? "Job title")
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }

                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .center, spacing: 8) {
                            if let project = self.job?.project {
                                if let company = project.company {
                                    if company.abbreviation != nil {
                                        Button {
                                            self.isCompanyPresented.toggle()
                                        } label: {
                                            Text(company.abbreviation!)
                                                .lineLimit(1)
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
                                            .lineLimit(1)
                                            .underline(true, pattern: .dot)
                                    }
                                }
                            }
                            Spacer()
                        }

                        HStack(alignment: .center, spacing: 8) {
                            Spacer()
                            HStack {
                                Text("\(self.job?.tasks?.count ?? 0)")
                                Image(systemName: "checklist")
                                    .help("\(self.job?.tasks?.count ?? 0) task(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                            HStack {
                                Text("\(self.job?.tasks?.count ?? 0)")
                                Image(systemName: "note.text")
                                    .help("\(self.job?.tasks?.count ?? 0) note(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))

                            HStack {
                                Text("\(self.job?.records?.count ?? 0)")
                                Image(systemName: "tray.fill")
                                    .help("\(self.job?.tasks?.count ?? 0) records(s) selected")
                            }
                            .padding(3)
                            .background(.white.opacity(0.4).blendMode(.softLight))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                    }
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.job?.backgroundColor ?? Theme.rowColour), type: .jobs)
                )
                .foregroundStyle((self.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                .swipeActions(edge: .leading) {
                    Button {
                        self.actionOnSwipeComplete(job)
                    } label: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        self.actionOnSwipeDelay(job)
                    } label: {
                        Image(systemName: "clock.fill")
                    }
                    .tint(.yellow)

                    Button(role: .destructive) {
                        self.actionOnSwipeCancel(job)
                    } label: {
                        Image(systemName: "calendar.badge.minus")
                    }
                    .tint(.red)
                }
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
            }

            /// Callback which handles the Complete swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeComplete(_ job: Job?) -> Void {

            }

            /// Callback which handles the Delay swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeDelay(_ job: Job?) -> Void {

            }

            /// Callback which handles the Cancel swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeCancel(_ job: Job?) -> Void {

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
            @State public var task: LogTask
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
            @State public var task: LogTask
            public var onActionComplete: (() -> Void)? = nil
            public var onActionDelay: (() -> Void)? = nil
            public var onActionCancel: (() -> Void)? = nil
            public var onAction: (() -> Void)? = nil
            public var includeDueDate: Bool = false
            public var inSheet: Bool = false
            @State private var isCompleted: Bool = false
            @State private var isCancelled: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            @State private var isJobPresented: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    NavigationLink {
                        TaskDetail(task: task)
                    } label: {
                        HStack(alignment: .center) {
                            Text(task.content ?? "_TASK_CONTENT")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 8) {
                            if let project = task.owner?.project {
                                if let company = project.company {
                                    if company.abbreviation != nil {
                                        Button {
                                            self.isCompanyPresented.toggle()
                                        } label: {
                                            Text(company.abbreviation!)
                                                .lineLimit(1)
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
                                            .lineLimit(1)
                                            .underline(true, pattern: .dot)
                                    }
                                }

                                if task.owner != nil {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                    Button {
                                        self.isJobPresented.toggle()
                                    } label: {
                                        Text((task.owner?.title ?? task.owner?.jid.string)!)
                                            .lineLimit(1)
                                            .underline(true, pattern: .dot)
                                    }
                                }
                            }
                            Spacer()
                        }

                        if task.due != nil {
                            HStack(alignment: .center) {
                                Text("Due: \(task.due!.formatted(date: self.includeDueDate ? .abbreviated : .omitted, time: .complete))")
                                    .lineLimit(1)
                                Spacer()
                            }
                        }
                    }
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle((task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                }
                .listRowBackground(
                    Common.TypedListRowBackground(colour: self.task.owner?.backgroundColor ?? Theme.rowColour, type: .tasks)
                )
                .foregroundStyle((task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .opacity(isCompleted ? 0.5 : 1.0)
                .onAppear(perform: self.actionOnAppear)
                .swipeActions(edge: .leading) {
                    Button {
                        self.actionOnSwipeComplete(task)
                    } label: {
                        Image(systemName: "checkmark.seal.fill")
                    }
                    .tint(.green)
                }
                .swipeActions(edge: .trailing) {
                    Button {
                        self.actionOnSwipeDelay(task)
                    } label: {
                        Image(systemName: "clock.fill")
                    }
                    .tint(.yellow)

                    Button(role: .destructive) {
                        self.actionOnSwipeCancel(task)
                    } label: {
                        Image(systemName: "calendar.badge.minus")
                    }
                    .tint(.red)
                }
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.isCompleted = self.task.completedDate != nil
                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Callback which handles the Complete swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeComplete(_ task: LogTask) -> Void {
                CoreDataTasks(moc: self.state.moc).complete(task)
                self.actionOnAppear()

                if let completed = self.onActionComplete {
                    completed()
                }

                if let onAction = self.onAction {
                    onAction()
                }
            }

            /// Callback which handles the Delay swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeDelay(_ task: LogTask) -> Void {
                if let due = task.due {
                    if let newDate = DateHelper.endOfTomorrow(due) {
                        task.delayCount += 1
                        CoreDataTasks(moc: self.state.moc).due(on: newDate, task: task)
                    }
                }

                self.actionOnAppear()

                if let delayed = self.onActionDelay {
                    delayed()
                }

                if let onAction = self.onAction {
                    onAction()
                }
            }

            /// Callback which handles the Cancel swipe action
            /// - Parameter task: LogTask
            /// - Returns: Void
            private func actionOnSwipeCancel(_ task: LogTask) -> Void {
                CoreDataTasks(moc: self.state.moc).cancel(task)
                self.actionOnAppear()

                if let cancelled = self.onActionCancel {
                    cancelled()
                }

                if let onAction = self.onAction {
                    onAction()
                }
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
                        name: note.title ?? "_NOTE_TITLE",
                        colour: note.mJob != nil ? note.mJob!.backgroundColor : Theme.rowColour,
                        extraColumn: AnyView(
                            Timestamp(text: "v\(note.versions?.count ?? 0)")
                        ),
                        highlight: false
                    )
                }
            }
        }

        struct SingleNoteDetailedLink: View {
            @EnvironmentObject private var state: AppState
            public var note: Note?
            public var callback: ((Note?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.note != nil {
                        NavigationLink {
                            NoteDetail(note: self.note)
                                .background(self.page.primaryColour)
                                .scrollContentBackground(.hidden)
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.note?.title ?? "_NOTE_TITLE")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }
                        Timestamp(text: "\(self.note?.versions?.count ?? 0)", fullWidth: false, alignment: .trailing, type: .notes)
                            .foregroundStyle((self.note?.mJob?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                    }
                }
                .frame(minHeight: 45)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.note?.mJob?.backgroundColor ?? Theme.rowColour), type: .notes)
                )
                .foregroundStyle((self.note?.mJob?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
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

        struct SingleCompanyDetailedLink: View {
            @EnvironmentObject private var state: AppState
            public var entity: Company?
            public var callback: ((Company?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.entity != nil {
                        NavigationLink {
                            CompanyDetail(company: self.entity)
                                .background(self.page.primaryColour)
                                .scrollContentBackground(.hidden)
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.entity?.name ?? "_NAME")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }

                        if self.entity!.isDefault {
                            Timestamp(text: "Default", fullWidth: false, alignment: .trailing, type: .companies)
                                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.entity?.backgroundColor ?? Theme.rowColour), type: .companies)
                )
                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
            }
        }

        struct SingleCompanyDetailedCustomButton: View {
            @EnvironmentObject private var state: AppState
            public var entity: Company?
            public var callback: ((Company?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.entity != nil {
                        Button {
                            if let cb = self.callback {
                                cb(self.entity)
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.entity?.name ?? "_NAME")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }

                        if self.entity!.isDefault {
                            Timestamp(text: "Default", fullWidth: false, alignment: .trailing, type: .companies)
                                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.entity?.backgroundColor ?? Theme.rowColour), type: .companies)
                )
                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
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
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
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
                                    .lineLimit(1)
                                Spacer()
                                RowAddNavLink(
                                    title: "+ Person",
                                    target: AnyView(
                                        PersonDetail(company: self.entity)
                                    )
                                )
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
                .background(self.entity.backgroundColor)
            }
        }

        struct SinglePerson: View {
            public let person: Person
            public var colour: Color?

            var body: some View {
                NavigationLink {
                    PersonDetail(person: person)
                        .background(Theme.cPurple)
                        .scrollContentBackground(.hidden)
                } label: {
                    ContactListRow(
                        person: person,
                        colour: self.colour ?? person.company?.backgroundColor
                    )
                }
                .buttonStyle(.plain)
            }
        }

        struct SinglePersonDetailedLink: View {
            @EnvironmentObject private var state: AppState
            public var person: Person?
            public var callback: ((Person?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.person != nil {
                        NavigationLink {
                            PersonDetail(person: self.person)
                                .background(self.page.primaryColour)
                                .scrollContentBackground(.hidden)
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.person?.name ?? "_NAME")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }
                        if let cname = self.person?.company?.name {
                            Timestamp(text: cname, fullWidth: false, alignment: .trailing, type: .people)
                                .foregroundStyle((self.person?.company?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.person?.company?.backgroundColor ?? Theme.rowColour), type: .people)
                )
                .foregroundStyle((self.person?.company?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
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

        struct SingleProjectDetailedLink: View {
            @EnvironmentObject private var state: AppState
            public var entity: Project?
            public var callback: ((Project?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.entity != nil {
                        NavigationLink {
                            ProjectDetail(project: self.entity)
                                .background(self.page.primaryColour)
                                .scrollContentBackground(.hidden)
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.entity?.name ?? "_NAME")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }

                        Timestamp(text: "\(self.entity?.jobs?.count ?? 0)", fullWidth: false, alignment: .trailing, type: .jobs)
                            .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                    }
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.entity?.backgroundColor ?? Theme.rowColour), type: .projects)
                )
                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
            }
        }

        struct SingleProjectDetailedCustomButton: View {
            @EnvironmentObject private var state: AppState
            public var entity: Project?
            public var callback: ((Project?) -> Void)? = nil
            public var inSheet: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            private let page: PageConfiguration.AppPage = .create

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    if self.entity != nil {
                        Button {
                            if let cb = self.callback {
                                cb(self.entity)
                            }
                        } label: {
                            HStack(alignment: .center) {
                                Text(self.entity?.name ?? "_NAME")
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.bottom, 8)
                        }

                        Timestamp(text: "Default", fullWidth: false, alignment: .trailing, type: .companies)
                            .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                    }
                }
                .frame(height: 70)
                .listRowBackground(
                    Common.TypedListRowBackground(colour: (self.entity?.backgroundColor ?? Theme.rowColour), type: .companies)
                )
                .foregroundStyle((self.entity?.backgroundColor ?? Theme.rowColour).isBright() ? .black : .white)
                .onAppear(perform: self.actionOnAppear)
                // @TODO: after converting to list, these fire whenever the row is tapped. fix that and re-enable this functionality
//                .sheet(isPresented: $isCompanyPresented) {
//                    if let project = task.owner?.project {
//                        if let company = project.company {
//                            if !self.inSheet {
//                                NavigationStack {
//                                    CompanyDetail(company: company)
//                                        .scrollContentBackground(.hidden)
//                                }
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isProjectPresented) {
//                    if let project = task.owner?.project {
//                        if !self.inSheet {
//                            NavigationStack {
//                                ProjectDetail(project: project)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
//                .sheet(isPresented: $isJobPresented) {
//                    if let job = task.owner {
//                        if !self.inSheet {
//                            NavigationStack {
//                                JobDetail(job: job)
//                                    .scrollContentBackground(.hidden)
//                            }
//                        }
//                    }
//                }
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
//                self.isCompleted = self.task.completedDate != nil
//                self.isCancelled = self.task.cancelledDate != nil
            }

            /// Save handler. Saves completed or cancelled status for the given task.
            /// - Returns: Void
            private func actionOnSave() -> Void {
//                if self.isCompleted {
//                    self.task.completedDate = Date()
//
//                    // Create a record indicating when the task was completed
//                    CoreDataTasks(moc: self.state.moc).complete(self.task)
//                } else {
//                    self.task.completedDate = nil
//                }
//
//                if self.isCancelled {
//                    self.task.cancelledDate = Date()
//
//                    // Create a record indicating when the task was cancelled
//                    CoreDataTasks(moc: self.state.moc).cancel(self.task)
//                } else {
//                    self.task.cancelledDate = nil
//                }
//
//                PersistenceController.shared.save()
            }

            /// Fires when the task close/open icon is tapped
            /// - Returns: Void
            private func actionOnTap() -> Void {
//                isCompleted.toggle()
//                self.actionOnSave()
//                if let cb = callback { cb() }
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

        struct SingleTextCustomButton: View {
            public let text: String
            public let colour: Color
            public var callback: (() -> Void)?
            @State private var selected: Bool = false

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Rectangle()
                            .foregroundStyle(self.colour)
                            .frame(width: 15)

                        // Open people list button
                        Button {
                            self.selected.toggle()
                            self.callback?()
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
                        .padding([.top, .bottom], 8)

                        Button {
                            if let cb = self.callback { cb() }
                        } label: {
                            ListRow(
                                name: self.text,
                                padding: (8,8,8,0)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .background(Theme.base.opacity(0.8).blendMode(.softLight))
            }
        }
    }
}

