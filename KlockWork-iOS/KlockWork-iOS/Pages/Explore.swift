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
    @State private var entityCounts: [EntityTypePair] = []

    @Environment(\.managedObjectContext) var moc

    var body: some View {
        NavigationStack(path: $path) {
            List {
                Section("Entities") {
                    ForEach(EntityType.allCases, id: \.self) { type in
                        NavigationLink {
                            switch type {
                            case .companies:
                                Companies()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            case .jobs:
                                Jobs()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            case .notes:
                                Notes()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            case .people: // @TODO: implement people listing view
                                Notes()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            case .records: // @TODO: implement records listing view
                                Notes()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            case .tasks:
                                Tasks()
                                    .environment(\.managedObjectContext, moc)
                                    .navigationTitle(type.label)
                            }
                        } label: {
                            HStack {
                                type.icon
                                    .foregroundStyle(fgColour)
                                Text(type.label)
                                Spacer()
                                Text(String(entityCounts.first(where: {$0.key == type})?.value ?? 0))
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }
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
            for type in EntityType.allCases {
                var count: Int = 0

                switch type {
                case .companies:
                    count = CoreDataCompanies(moc: moc).countAll()
                case .jobs:
                    count = CoreDataJob(moc: moc).countAll()
                case .notes:
                    count = CoreDataNotes(moc: moc).alive().count
                case .people:
                    count = 0
                case .records:
                    count = 0
                case .tasks:
                    count = CoreDataTasks(moc: moc).countAllTime()
                }

                entityCounts.append(EntityTypePair(key: type, value: count))
            }
        }
    }
}
