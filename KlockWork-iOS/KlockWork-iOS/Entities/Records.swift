//
//  Records.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct Records: View {
    typealias EntityType = PageConfiguration.EntityType

    private let entityType: EntityType = .records
    @State public var items: [LogRecord] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(placeholder: "Today I...", items: items, type: entityType)
                        .listRowBackground(Theme.textBackground)
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                RecordDetail(record: item)
                                    .background(Theme.cGreen)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(item.message!)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: addItem) {
                            Text("No people found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }

            }
            .onAppear(perform: {
                items = CoreDataRecords(moc: moc).recent(3)
            })
            .background(Theme.cGreen)
            .scrollContentBackground(.hidden)
            .toolbarBackground(Theme.cGreen, for: .navigationBar)
            .toolbar {
                ToolbarItem {
                    Button(action: {}/*addItem*/) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

extension Records {
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
