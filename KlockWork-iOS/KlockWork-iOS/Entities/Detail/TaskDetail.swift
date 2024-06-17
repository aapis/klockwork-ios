//
//  TaskDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct TaskDetail: View {
    public let task: LogTask
    @State private var completedDate: Date = Date()
    @State private var cancelledDate: Date = Date()
    @State private var content: String = ""
    @State private var created: Date = Date()
    @State private var lastUpdate: Date = Date()
    @State private var job: Job?
    @State private var isCompleted: Bool = false
    @State private var isCancelled: Bool = false
    public var page: PageConfiguration.AppPage = .create
    static public let defaultContent: String = "Sample task content"

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section("Settings") {
                        DatePicker(
                            "Created",
                            selection: $created,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        DatePicker(
                            "Last updated",
                            selection: $lastUpdate,
                            displayedComponents: [.date, .hourAndMinute]
                        )

                        if task.completedDate != nil {
                            DatePicker(
                                "Completed on",
                                selection: $completedDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .listRowBackground(Theme.cGreen)
                        } else {
                            Toggle("Completed", isOn: $isCompleted)
                        }

                        if task.cancelledDate != nil {
                            DatePicker(
                                "Cancelled on",
                                selection: $cancelledDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        } else {
                            Toggle("Cancelled", isOn: $isCancelled)
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    Section("Job") {
                        if job != nil {
                            NavigationLink {
                                JobDetail(job: job!)
                                    .toolbar {
                                        ToolbarItem(placement: .topBarTrailing) {
                                            Button("Save") {
                                                PersistenceController.shared.save()
                                            }
                                        }
                                    }
                            } label: {
                                Text(job!.title ?? job!.jid.string)
                                    .foregroundStyle(job!.backgroundColor.isBright() ? .black : .white)
                            }
                            .listRowBackground(job!.backgroundColor)
                        } else {
                            Text("Job selector")
                                .listRowBackground(Theme.textBackground)
                        }
                    }

                    Section("What needs to be done?") {
                        TextField("Task content", text: $content, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .listStyle(.grouped)
            }
            .onAppear(perform: actionOnAppear)
            .navigationTitle("Task")
            .background(page.primaryColour)
            .scrollContentBackground(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
    
    /// Default initializer
    /// - Parameter task: LogTask
    init(task: LogTask? = nil) {
        if task == nil {
            self.task = DefaultObjects.task
        } else {
            self.task = task!
        }
    }
}

extension TaskDetail {
    /// Onload handler, sets view data
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let coDate = task.completedDate {
            completedDate = coDate
            isCompleted = true
        }

        if let caDate = task.cancelledDate {
            cancelledDate = caDate
            isCancelled = true
        }

        if let cDate = task.created {created = cDate}
        if let uDate = task.lastUpdate {lastUpdate = uDate}
        if let co = task.content {content = co}
        if let jo = task.owner {job = jo}
    }
}

extension TaskDetail {
    struct Sheet: View {
        public var task: LogTask? = nil
        public var page: PageConfiguration.AppPage = .create
        @Binding public var isPresented: Bool

        var body: some View {
            TaskDetail(task: self.task)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        self.isPresented.toggle()
                        PersistenceController.shared.save()
                    }
                }
            }
        }
    }
}
