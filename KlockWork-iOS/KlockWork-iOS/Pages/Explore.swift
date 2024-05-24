//
//  Home.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Explore: View {
    private let fgColour: Color = .yellow
    private var columns: [GridItem] {
        Array(repeating: .init(.flexible()), count: 2)
    }

    @State private var path = NavigationPath()
    @State private var entityCounts: (Int, Int, Int, Int) = (0,0,0,0)

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Entities") {
                    NavigationLink {
                        Companies()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Companies")
                    } label: {
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundStyle(fgColour)
                            Text("Companies")
                            Spacer()
                            Text(String(entityCounts.0))
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    NavigationLink {
                        Jobs()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Jobs")
                    } label: {
                        HStack {
                            Image(systemName: "hammer")
                                .foregroundStyle(fgColour)
                            Text("Jobs")
                            Spacer()
                            Text(String(entityCounts.1))
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    
                    NavigationLink {
                        Notes()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Notes")
                    } label: {
                        HStack {
                            Image(systemName: "note.text")
                                .foregroundStyle(fgColour)
                            Text("Notes")
                            Spacer()
                            Text(String(entityCounts.2))
                        }
                    }
                    .listRowBackground(Theme.textBackground)

                    NavigationLink {
                        Tasks()
                            .environment(\.managedObjectContext, moc)
                            .navigationTitle("Tasks")
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                                .foregroundStyle(fgColour)
                            Text("Tasks")
                            Spacer()
                            Text(String(entityCounts.3))
                        }
                    }
                    .listRowBackground(Theme.textBackground)
                }
            }
            .background(Theme.cGreen)
            .scrollContentBackground(.hidden)
            .navigationTitle("Explore")
            .toolbarBackground(Theme.cGreen, for: .navigationBar)
            .toolbar {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(fgColour)
            }
        }
        .tint(fgColour)
        .onAppear(perform: actionOnAppear)
    }
}

extension Explore {
    private func actionOnAppear() -> Void {
        Task {
            entityCounts = (
                CoreDataCompanies(moc: moc).countAll(),
                CoreDataJob(moc: moc).countAll(),
                CoreDataNotes(moc: moc).alive().count,
                CoreDataTasks(moc: moc).countAllTime()
            )
        }
    }
}
