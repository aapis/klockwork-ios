//
//  Companies.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Companies: View {
    private let entityType: EntityType = .companies
    @State public var items: [Company] = []

    @Environment(\.managedObjectContext) var moc
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(items: items, type: entityType)
                        .listRowBackground(Theme.textBackground) // @TODO: SHOULD be unnecessary
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                CompanyDetail(company: item)
                            } label: {
                                Text(item.name!.capitalized)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: addItem) {
                            Text("No companies found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }

            }
            .onAppear(perform: {
                items = CoreDataCompanies(moc: moc).alive()
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

extension Companies {
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
