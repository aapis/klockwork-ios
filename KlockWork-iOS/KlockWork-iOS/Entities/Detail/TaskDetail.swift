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
                    
                    if job != nil {
                        Section("Job") {
                            NavigationLink {
                                JobDetail(job: job!)
                                    .background(Theme.cPurple)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(job!.title ?? job!.jid.string)
                                    .foregroundStyle(job!.backgroundColor.isBright() ? .black : .white)
                            }
                        }
                        .listRowBackground(job!.backgroundColor)
                    }

                    Section("Content") {
                        TextField("Task content", text: $content, axis: .vertical)
                    }
                    .listRowBackground(Theme.textBackground)
                }
                .listStyle(.grouped)
            }
            .onAppear(perform: actionOnAppear)
            .navigationTitle("Task")
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                Button("Save") {

                }
            }
        }
    }
}

extension TaskDetail {
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
