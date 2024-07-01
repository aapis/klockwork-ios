//
//  Companies.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Companies: View {
    typealias EntityType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    private let entityType: EntityType = .companies
    @State public var items: [Company] = []
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(placeholder: "ACME, Contoso, Initech", items: items, type: entityType)
                        .listRowBackground(Theme.textBackground)
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                CompanyDetail(company: item)
                                    .background(Theme.cGreen)
                                    .scrollContentBackground(.hidden)
                            } label: {
                                Text(item.name!)
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
                items = CoreDataCompanies(moc: self.state.moc).alive()
            })
            .scrollContentBackground(.hidden)
            .background(Theme.cGreen)
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
