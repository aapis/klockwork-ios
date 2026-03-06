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
                                //                                    .lineLimit(1)
                                Spacer()
                            }
                            //                            .padding(.bottom, 8)
                        }

                        if self.record?.timestamp != nil {
                            Timestamp(text: self.record!.timestamp!.formatted(date: .omitted, time: .shortened), fullWidth: false, alignment: .trailing)
                                .foregroundStyle((self.record?.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        }
                    }
                }
//                .frame(minHeight: 45)
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
                            ForEach(Array(self.definitions.enumerated()), id: \.offset) { idx, term in
                                HStack(alignment: .top) {
                                    Text("\(idx + 1). ")
                                    Text(term.definition ?? "_TERM_DEFINITION")
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                    // BUG: without another element here the spacer breaks the scrollview for some reason
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.clear)
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
            @EnvironmentObject private var state: AppState
            public let entity: Job
            public var callback: (Job) -> Void
            public var page: PageConfiguration.AppPage = .create
            @Binding public var selected: Bool

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
                            if self.state.job == self.entity {
                                self.state.job = nil
                            } else {
                                self.state.job = self.entity
                            }
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
                        .lineLimit(1)

                        PageConfiguration.EntityType.jobs.icon
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base.blendMode(.softLight) : Theme.lightWhite.blendMode(.softLight))

                        // Chevron
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 8)
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : Theme.lightWhite)
                            .opacity(0.3)
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
            public var includeCompletedDate: Bool = false
            public var inSheet: Bool = false
            @State private var isCompleted: Bool = false
            @State private var isCancelled: Bool = false
            @State private var isCompanyPresented: Bool = false
            @State private var isProjectPresented: Bool = false
            @State private var isJobPresented: Bool = false
            @State private var dayDiff: CGFloat = 0
            @State private var rating: TaskClosureRating = .common
            @State private var openDelta: CGFloat = 0

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        self.statusBar
                        self.main
                    }
                    self.extendedDetails
                }
                .background(
                    ZStack(alignment: .topLeading) {
                        self.task.completedDate != nil ? Theme.cGreen : (self.task.owner?.backgroundColor ?? self.state.theme.page.primaryColour)
                        LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                            .opacity(0.3)
                            .blendMode(.softLight)
                    }
                )
                // Remove at your peril
                .clipShape(.rect)
            }

            var extendedDetails: some View {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(alignment: .center) {
                        Text("Created")
                        Spacer()
                        Text("\(self.task.created!.formatted(date: .abbreviated, time: .complete))")
                            .lineLimit(1)
                    }
                    if self.task.due != nil {
                        HStack(alignment: .center) {
                            Text("Due")
                            Spacer()
                            Text("\(self.task.due!.formatted(date: self.includeDueDate ? .abbreviated : .omitted, time: .complete))")
                                .lineLimit(1)
                        }
                    }
                    if self.task.completedDate != nil && self.includeCompletedDate {
                        HStack(alignment: .center) {
                            Text("Completed")
                            Spacer()
                            Text("\(self.task.completedDate!.formatted(date: .abbreviated, time: .complete))")
                                .lineLimit(1)
                        }
                    }
                    HStack(alignment: .center) {
                        Spacer()
                        StatusCapsule(label: "OΔ", value: self.openDelta)
                        // Hide rating until complete to disincentivize completing tasks for "reward" alone, could be optional in future
                        if self.task.completedDate != nil {
                            StatusCapsule(label: "R", value: self.dayDiff, rating: self.rating)
                        }
                    }
                }
                .padding(4)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(self.task.completedDate != nil ? Theme.lightWhite : (self.task.owner?.backgroundColor ?? .white).isBright() ? Theme.lightBase : Theme.lightWhite)
                .background(
                    ZStack(alignment: .top) {
                        self.task.completedDate != nil ? Theme.cGreen : Theme.textBackground
//                        Theme.cPurple
//                        self.task.owner?.backgroundColor ?? self.state.theme.page.primaryColour
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 15)
                            .blendMode(.softLight)
                            .opacity(0.3)
                    }
                )
            }

            var statusBar: some View {
                VStack(alignment: .center, spacing: 0) {
                    Image(systemName: self.isCompleted ? "checkmark.seal.fill" : self.isCancelled ? "xmark.seal" : "seal")
                        .padding(.top, 4)
                    // Orange indicates job is in your current plan
                        .foregroundStyle(self.isCompleted ? .white : self.state.plan != nil && (self.state.plan!.jobs?.allObjects as! [Job]).contains(where: {$0 == self.task.owner}) ?  .orange : Theme.lightBase)
                        .blendMode(self.isCompleted || self.state.plan != nil ? .normal : .softLight)
                    Spacer()
                }
                .frame(width: 34)
                .background(
                    ZStack(alignment: .topLeading) {
                        LinearGradient(colors: [.clear, (self.isCompleted ? .green : .gray.opacity(0.6))], startPoint: .bottom, endPoint: .top)
                    }
                )
            }

            var main: some View {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink {
                        TaskDetail(task: task)
                    } label: {
                        HStack(alignment: .top) {
                            if let title = self.task.title {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(title)
                                        .bold()
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(2)
                                    ResourcePath(task: self.task)
                                    if let content = self.task.content {
                                        VStack(alignment: .leading, spacing: 0) {
                                            HStack(alignment: .bottom) {
                                                Text(content)
                                                    .italic()
                                                    .lineLimit(2)
                                                    .multilineTextAlignment(.leading)
                                                    .opacity(0.6)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                        .padding(4)
                                        .padding(.bottom, 0)
                                        .background(Theme.textBackground)
                                        .clipShape(.rect(cornerRadius: 4))
                                    }
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    ResourcePath(task: self.task)
                                    VStack(alignment: .leading, spacing: 0) {
                                        HStack(alignment: .bottom) {
                                            Text(self.task.content ?? "_TASK_CONTENT")
                                                .italic()
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                                .opacity(0.6)
                                            Spacer()
                                        }
                                        Spacer()
                                    }
                                    .padding(4)
                                    .padding(.bottom, 0)
                                    .background(Theme.textBackground)
                                    .clipShape(.rect(cornerRadius: 4))
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .padding(4)
                .background(Common.TypedListRowBackground(colour: self.task.owner?.backgroundColor ?? Theme.rowColour, type: .tasks, hasBorder: false))
                .foregroundStyle((self.task.owner?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)
                .opacity(self.isCompleted || self.isCancelled ? 0.5 : 1.0)
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
            }

            /// Onload handler. Sets state vars isCompleted and isCancelled to default state
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.isCompleted = self.task.completedDate != nil
                self.isCancelled = self.task.cancelledDate != nil
                // The difference between two dates determines the rating (older tasks completed get a fancier badge)
                self.dayDiff = ((self.task.completedDate ?? self.state.date) - (self.task.due ?? self.state.date))/86400

                if !self.task.closureDelta.isZero {
                    self.dayDiff = self.task.closureDelta
                }

                if self.isCompleted || self.isCancelled {
                    self.openDelta = ((self.task.completedDate ?? self.task.cancelledDate ?? self.state.date) - (self.task.created ?? self.state.date))/86400
                } else {
                    self.openDelta = (self.state.date - (self.task.created ?? self.state.date))/86400
                }

                // @TODO: These thresholds should be customizable
                if self.dayDiff > 2 && self.dayDiff <= 50 {
                    self.rating = .magic
                } else if self.dayDiff > 50 && self.dayDiff <= 100 {
                    self.rating = .rare
                } else if self.dayDiff > 100 && self.dayDiff < 200 {
                    self.rating = .epic
                } else if self.dayDiff > 200 || self.dayDiff < 2 {
                    self.rating = .legendary
                }
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

            struct ResourcePath: View {
                public var task: LogTask

                var body: some View {
                    HStack(alignment: .center, spacing: 8) {
                        if let project = self.task.owner?.project {
                            if let company = project.company {
                                if company.abbreviation != nil {
                                    Text(company.abbreviation!)
                                        .lineLimit(1)
                                }
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                            }

                            if project.abbreviation != nil {
                                Text(project.abbreviation!)
                                    .lineLimit(1)
                            }

                            if self.task.owner != nil {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                Text((self.task.owner?.title ?? self.task.owner?.jid.string)!)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                    }
                    .font(.system(.caption, design: .monospaced))
                    .padding(4)
                    .background(Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 4))
                }
            }

            enum TaskClosureRating {
                case common, magic, rare, epic, legendary

                var colour: Color {
                    return switch self {
                    case .common:
                        Color.white
                    case .magic:
                        Color.yellow
                    case .rare:
                        Color.green
                    case .epic:
                        Color.blue
                    case .legendary:
                        Color.purple
                    }
                }

                var badge: some View {
                    Text(self.label)
                        .padding(2)
                        .background(self.colour)
                        .foregroundStyle(Theme.base)
                }

                var label: String {
                    return switch self {
                    case .common:
                        "COMMON"
                    case .magic:
                        "INSPIRED"
                    case .rare:
                        "RARE"
                    case .epic:
                        "EPIC"
                    case .legendary:
                        "LEGENDARY"
                    }
                }
            }

            struct StatusCapsule: View {
                public var label: String?
                public var value: CGFloat?
                public var rating: TaskClosureRating?

                var body: some View {
                    HStack(alignment: .center, spacing: 0) {
                        if self.label != nil {
                            HStack(alignment: .center, spacing: 0) {
                                Text(self.label!)
                            }
                            .padding(2)
                            .background(
                                ZStack {
                                    Color.indigo
                                    Theme.base.opacity(0.4)
                                }
                            )
                        }
                        if self.value != nil {
                            HStack(alignment: .center, spacing: 0) {
                                Text(String(format: "%.2f", self.value!))
                            }
                            .padding(2)
                            .background(Color.indigo)
                        }
                        if self.rating != nil {
                            self.rating!.badge
                        }
                    }
                    .foregroundStyle(Theme.lightWhite)
                    .clipShape(.rect(cornerRadius: 4))
                }
            }
        }

        struct SingleChecklistTask: View {
            @EnvironmentObject private var state: AppState
            public var task: LogTask
            public var label: String
            @State public var icon: String = "circle.dotted.circle.fill"
            public var owner: Job? = nil
            public var checklist: Checklist
            public var callback: (() -> Void)? = nil
            @State public var isComplete: Bool = false
            @State public var isCancelled: Bool = false
            @State private var bgColour: Color = Theme.lightWhite
            @Binding public var selectedTasks: [LogTask]

            var body: some View {
                Button {
                    if self.task.isOpen {
                        self.selectedTasks.append(self.task)
                    } else {
                        self.selectedTasks.removeAll(where: {$0 == self.task})
                    }

                    self.callback?()
                    self.isComplete.toggle()
                } label: {
                    HStack {
                        Image(systemName: self.icon)
                        Text(self.label)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .font(.title2)
                    .bold()
                    .foregroundStyle(self.isComplete || self.isCancelled ? Theme.lightWhite : self.checklist.backgroundColour)
                    .padding()
                    .background(self.bgColour)
                }
                .buttonStyle(.plain)
                .clipShape(.rect(cornerRadius: 32))
                .padding([.leading, .trailing])
                .padding([.top, .bottom], 10)
                .shadow(radius: 4)
                .opacity(self.isComplete || self.isCancelled ? 0.4 : 1)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.isComplete) {
                    self.actionOnAppear()
                }
            }
            
            /// Onload handler. Sets state values
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                if self.task.isOpen {
                    self.icon = "circle.dotted.circle.fill"

                    if self.owner != nil {
                        self.bgColour = self.owner!.backgroundColor
                    } else if self.checklist.backgroundColour.isBright() {
                        self.bgColour = Theme.lightBase
                    }
                } else {
                    self.icon = "checkmark.circle.fill"
                }
            }
        }

        struct MythicalSingleBlank: View {
            public var label: String

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Button {

                        } label: {
                            Image(systemName: "circle.dotted")
                                .foregroundStyle(.white)
                                .blendMode(.softLight)
                                .font(.title2)
                        }
                        .padding(4)
                        .padding(.trailing)
                        .background(
                            ZStack(alignment: .trailing) {
                                LinearGradient(colors: [.clear, Theme.base], startPoint: .leading, endPoint: .trailing)
                                    .blendMode(.softLight)
                                    .frame(width: 15)
                            }
                        )
                        .buttonStyle(.plain)
                        .disabled(true)
                        NavigationLink {

                        } label: {
                            HStack(alignment: .center) {
                                Text(self.label)
                                    .multilineTextAlignment(.leading)
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(true)
                        .buttonStyle(.plain)
                        .padding(4)
                    }
                }
                .background(.gray)
                .foregroundStyle(Theme.base)
                .clipShape(.rect(cornerRadius: 8))
            }
        }

        // MARK: Tabs.Content.Individual.MythicalSingleSuggestedTask
        struct MythicalSingleSuggestedTask: View {
            @EnvironmentObject private var state: AppState
            public var task: LogTask
            public var callback: (() -> Void)?

            var body: some View {
                HStack(alignment: .center) {
                    Button {
                        self.callback?()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(self.state.theme.tint)
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .background(
                        ZStack(alignment: .trailing) {
                            Theme.darkBtnColour
                            LinearGradient(colors: [.clear, Theme.base], startPoint: .leading, endPoint: .trailing)
                                .blendMode(.softLight)
                                .frame(width: 15)
                        }
                    )
                    if let title = self.task.title {
                        Text(title)
                            .lineLimit(1)
                            .bold()
                    }
                    Spacer()
                }
                .background(.indigo)
                .clipShape(.rect(cornerRadius: 8))
            }
        }

        struct MythicalSingleTask: View {
            @EnvironmentObject private var state: AppState
            public var task: LogTask
            public var callback: (() -> Void)?

            var body: some View {
                HStack(alignment: .center, spacing: 0) {
                    Button {
                        let model = CoreDataTasks(moc: self.state.moc)

                        if self.task.completedDate != nil || self.task.cancelledDate != nil {
                            model.reopen(self.task)
                        } else {
                            model.complete(self.task, legacyAuditTrail: false)
                        }

                        self.callback?()
                    } label: {
                        Image(systemName: self.task.completedDate != nil ? "checkmark.circle.fill" : self.task.cancelledDate != nil ? "xmark.circle.fill" : "checkmark.circle.dotted")
                            .foregroundStyle(self.task.completedDate != nil ? Theme.cGreen : self.task.cancelledDate != nil ? .red : Theme.base)
                            .blendMode(self.task.completedDate != nil || self.task.cancelledDate != nil ? .normal : .overlay)
                            .font(.title2)
                        if self.task.completedDate != nil {
                            Text(DateHelper.todayShort(self.task.completedDate!, format: "@ hh:mm"))
                                .monospaced()
                                .font(.caption)
                                .padding(4)
                                .background(Theme.textBackground)
                                .foregroundStyle(Theme.lightBase)
                                .clipShape(.rect(cornerRadius: 4))
                        } else if self.task.cancelledDate != nil {
                            Text(DateHelper.todayShort(self.task.cancelledDate!, format: "@ hh:mm"))
                                .monospaced()
                                .font(.caption)
                                .padding(4)
                                .background(Theme.textBackground)
                                .foregroundStyle(.red)
                                .clipShape(.rect(cornerRadius: 4))
                        }
                    }
                    .buttonStyle(.plain)
                    .padding(4)
                    .background(
                        ZStack(alignment: .trailing) {
                            (self.task.completedDate != nil ? .green : self.task.cancelledDate != nil ? Theme.cRed : self.state.theme.tint)
                            LinearGradient(colors: [.clear, Theme.base], startPoint: .leading, endPoint: .trailing)
                                .blendMode(.softLight)
                                .frame(width: 15)
                        }
                    )
                    NavigationLink {
                        TaskDetail(task: self.task)
                    } label: {
                        HStack(alignment: .center) {
                            if let title = self.task.title {
                                Text(title)
                                    .lineLimit(1)
                                    .bold(self.task.completedDate == nil && self.task.cancelledDate == nil)
                                    .strikethrough(self.task.completedDate != nil || self.task.cancelledDate != nil)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Theme.base.opacity(0.3))
                        }
                        .padding(4)
                        .background(.indigo) // seems to be required so whole row is tappable
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(self.task.completedDate != nil || self.task.cancelledDate != nil ? Theme.lightBase : Theme.base)
                }
                .background(.indigo)
                .clipShape(.rect(cornerRadius: 8))
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
            @EnvironmentObject private var state: AppState
            public let entity: Company
            public var callback: (Company) -> Void
            @Binding public var selected: Bool

            var body: some View {
                VStack(alignment: .leading, spacing: 1) {
                    HStack(alignment: .firstTextBaseline) {
                        // Open company button
                        Button {
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
                        .lineLimit(1)

                        PageConfiguration.EntityType.companies.icon
                            .foregroundStyle(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base.blendMode(.softLight) : Theme.lightWhite.blendMode(.softLight))

                        // Chevron
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 8)
                            .foregroundStyle(Color.fromStored(entity.colour ?? Theme.rowColourAsDouble).isBright() ? Theme.base : Theme.lightWhite)
                            .opacity(0.3)
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
                .border(width: 1, edges: [.top], color: (self.entity.backgroundColor.isBright() ? Theme.base : Color.white).opacity(0.3))
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
            @EnvironmentObject private var state: AppState
            public let entity: Project
            public var callback: (Project) -> Void
            public var page: PageConfiguration.AppPage = .create
            @Binding public var selected: Bool

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundStyle(Color.fromStored(self.entity.company?.colour ?? Theme.rowColourAsDouble))
                            .frame(width: 15)

                        // Open folder button
                        Button {
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
                        .lineLimit(1)

                        PageConfiguration.EntityType.projects.icon
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base.blendMode(.softLight) : Theme.lightWhite.blendMode(.softLight))

                        // Chevron
                        Image(systemName: "chevron.right")
                            .padding(.trailing, 8)
                            .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : Theme.lightWhite)
                            .opacity(0.3)
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
                                    .foregroundStyle(self.entity.backgroundColor.isBright() ? Theme.base : .white)
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

        struct Post: View {
            @Environment(\.colorScheme) var colourScheme
            @EnvironmentObject private var state: AppState
            public var record: LogRecord

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    NavigationLink {
                        RecordDetail(record: self.record)
                            .background(self.state.theme.page.primaryColour)
                            .scrollContentBackground(.hidden)
                    } label: {
                        HStack {
                            HStack {
                                Image("DefaultAvatar")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .padding(.leading, 3)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(self.record.job?.backgroundColor ?? Theme.rowColour, lineWidth: 1)
                                    }
                            }
                            VStack(alignment: .leading) {
                                Text("Under: \(self.record.job?.titleOrId() ?? "<Error>")")
                                    .font(.system(.caption, design: .monospaced))
                                Timestamp(text: self.record.timestamp!.formatted(date: .abbreviated, time: .shortened), fullWidth: false)
                            }
                            .padding(8)
                            Spacer()
                        }
                        .foregroundStyle((self.record.job?.backgroundColor ?? Theme.rowColour).isBright() ? .black.opacity(0.55) : .white.opacity(0.55))
                        .background(
                            Tabs.Content.Common.TypedListRowBackground(colour: self.record.job?.backgroundColor ?? Theme.rowColour, type: .records)
                        )
                        .frame(height: 66)
                    }

                    VStack(spacing: 0) {
                        HStack(alignment: .center) {
                            Text(self.record.message ?? "<Error: Record content not found>")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                        .padding(8)
                    }
                    .background(self.colourScheme == .dark ? Theme.textBackground : Theme.lightWhite)
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

