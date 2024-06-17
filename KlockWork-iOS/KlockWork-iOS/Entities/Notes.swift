//
//  Notes.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Notes: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PageType = PageConfiguration.AppPage

    @EnvironmentObject private var state: AppState
    private let entityType: EntityType = .notes
    private let detailPageType: PageType = .modify
    @State public var items: [Note] = []
    @State private var isPresented: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(placeholder: "Note title or partial content", items: items, type: entityType)
                        .listRowBackground(Theme.textBackground)
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                NoteDetail(note: item, isPresented: $isPresented, page: self.detailPageType)
                            } label: {
                                Text(item.title!.capitalized)
                            }
                        }
                        .onDelete(perform: deleteItems)
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: addItem) {
                            Text("No notes found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataNotes(moc: self.state.moc).alive()
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
                    Button(action: self.toggleCreateSheet) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresented) {
                if let defaultCompany = CoreDataCompanies(moc: self.state.moc).findDefault() {
                    let projects = defaultCompany.projects!.allObjects as! [Project]
                    if let _ = projects.first {
                        NavigationStack {
                            NoteDetail.Sheet(
                                page: self.detailPageType,
                                isPresented: $isPresented
                            )
                        }
                    } else {
                        ErrorView.MissingProject(isPresented: $isPresented)
                    }
                } else {
                    ErrorView.MissingCompany(isPresented: $isPresented)
                }
            }
        }
    }
}

extension Notes {
    /// Shows or hides the create job sheet
    /// - Returns: Void
    private func toggleCreateSheet() -> Void {
        self.isPresented.toggle()
    }

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
