//
//  Tasks.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Tasks: View {
    typealias EntityType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    private let entityType: EntityType = .tasks
    @State public var items: [LogTask] = []

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(placeholder: "Task content or job name/ID", items: items, type: entityType)
                        .listRowBackground(Theme.textBackground)
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                TaskDetail(task: item)
                                    .background(Theme.cGreen)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(item.content ?? "_NO_CONTENT")
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: addItem) {
                            Text("No tasks found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataTasks(moc: self.state.moc).all()
            })
            .scrollContentBackground(.hidden)
            .background(Theme.cGreen)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

extension Tasks {
    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
//            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                modelContext.delete(items[index])
            }
        }
    }
}
