//
//  Tasks.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Tasks: View {
    private let entityType: EntityType = .tasks
    @State public var items: [LogTask] = []

    @Environment(\.managedObjectContext) var moc

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
                                Text(item.content!)
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
                items = CoreDataTasks(moc: moc).all()
            })
            .background(Theme.cGreen)
            .scrollContentBackground(.hidden)
            .toolbarBackground(Theme.cGreen, for: .navigationBar)
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
