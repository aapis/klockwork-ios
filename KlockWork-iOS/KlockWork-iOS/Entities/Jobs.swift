//
//  Jobs.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Jobs: View {
    typealias EntityType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    private let entityType: EntityType = .jobs
    @State public var items: [Job] = []
    @State private var isCreateEditorPresented: Bool = false
    private let page: PageConfiguration.AppPage = .create

    var body: some View {
        NavigationStack {
            List {
                Section {
                    SearchBar(placeholder: "Job name or ID", items: items, type: entityType)
                        .listRowBackground(Theme.textBackground)
                }

                Section {
                    if items.count > 0 {
                        ForEach(items) { item in
                            NavigationLink {
                                JobDetail(job: item)
                            } label: {
                                Text(item.title != nil ? item.title!.isEmpty ? item.jid.string : item.title!.capitalized : item.jid.string)
                            }
                        }
//                        .onDelete(perform: deleteItems)
                        .listRowBackground(Theme.textBackground)
                    } else {
                        Button(action: self.toggleCreateSheet) {
                            Text("No jobs found. Create one!")
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
            }
            .onAppear(perform: {
                items = CoreDataJob(moc: self.state.moc).all(true)
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
            .sheet(isPresented: $isCreateEditorPresented) {
                if let defaultCompany = CoreDataCompanies(moc: self.state.moc).findDefault() {
                    let projects = defaultCompany.projects!.allObjects as! [Project]
                    if let _ = projects.first {
                        NavigationStack {
                            JobDetail(job: DefaultObjects.job)
                        }
                    } else {
                        ErrorView.MissingProject(isPresented: $isCreateEditorPresented)
                    }
                } else {
                    ErrorView.MissingCompany(isPresented: $isCreateEditorPresented)
                }
            }
        }
    }
}

extension Jobs {
    /// Shows or hides the create job sheet
    /// - Returns: Void
    private func toggleCreateSheet() -> Void {
        self.isCreateEditorPresented.toggle()
    }
    
    /// Delete items
    /// - Parameter offsets: IndexSet
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
//                self.state.moc.delete(offsets[index])
//                modelContext.delete(items[index])
            }
        }
    }
}

