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
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: {}) {
                            Text("No people found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }

            }
            .onAppear(perform: {
                items = CoreDataRecords(moc: moc).recent(3)
            })
            .scrollContentBackground(.hidden)
            .background(Theme.cGreen)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .scrollDismissesKeyboard(.immediately)
            .toolbar {
                ToolbarItem {
                    Button(action: {}/*addItem*/) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
#endif
        }
    }
}
