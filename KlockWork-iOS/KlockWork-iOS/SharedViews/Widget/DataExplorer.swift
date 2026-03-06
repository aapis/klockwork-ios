//
//  DataExplorer.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

extension Widget {
    struct DataExplorer: View {
        typealias EntityType = PageConfiguration.EntityType
        typealias EntityTypePair = PageConfiguration.EntityTypePair

        @EnvironmentObject private var state: AppState
        private let title: String = "Data Explorer"
        private var columns: [GridItem] {
            Array(repeating: .init(.flexible()), count: 2)
        }
        @State private var entityCounts: [EntityTypePair] = []
        @State private var isPresented: Bool = false
        @State private var searchText: String = ""
        @State private var open: Bool = false

        var body: some View {
            NavigationStack {
                VStack {
                    List {
                        ForEach(EntityType.allCases, id: \.self) { type in
                            EntityButton(type: type, entityCounts: $entityCounts)
                        }
                    }
                    Spacer()
                }
                .scrollContentBackground(.hidden)
                .navigationBarTitleDisplayMode(.inline)
                .background(Theme.cGreen)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollDismissesKeyboard(.immediately)
                .navigationTitle(self.title)
            }
            .tint(self.state.theme.tint)
            .onAppear(perform: actionOnAppear)
        }
    }
}

// MARK: Data structures
extension Widget.DataExplorer {
    struct EntityButton: View {
        @EnvironmentObject private var state: AppState
        public let type: EntityType
        @Binding public var entityCounts: [EntityTypePair]

        var body: some View {
            NavigationLink {
                switch type {
                case .companies:
                    Companies()
                        .navigationTitle(type.label)
                case .jobs:
                    Jobs()
                        .navigationTitle(type.label)
                case .notes:
                    Notes()
                        .navigationTitle(type.label)
                case .people:
                    People()
                        .navigationTitle(type.label)
                case .records:
                    Records()
                        .navigationTitle(type.label)
                case .tasks:
                    Tasks()
                        .navigationTitle(type.label)
                case .projects:
                    Projects()
                        .navigationTitle(type.label)
                case .terms:
                    EmptyView() // @TODO: implement
                        .navigationTitle(type.label)
                }
            } label: {
                HStack {
                    type.icon
                        .foregroundStyle(self.state.theme.tint)
                    Text(type.label)
                    Spacer()
                    Text(String(entityCounts.first(where: {$0.key == type})?.value ?? 0))
                }
            }
            .listRowBackground(Theme.textBackground)
        }
    }
}

// MARK: Method definitions
extension Widget.DataExplorer {
    private func actionOnAppear() -> Void {
        Task {
            for type in EntityType.allCases {
                var count: Int = 0

                switch type {
                case .companies:
                    count = CoreDataCompanies(moc: self.state.moc).countAll()
                case .jobs:
                    count = CoreDataJob(moc: self.state.moc).countAll()
                case .notes:
                    count = CoreDataNotes(moc: self.state.moc).alive().count
                case .people:
                    count = CoreDataPerson(moc: self.state.moc).countAll()
                case .records:
                    count = CoreDataRecords(moc: self.state.moc).countAll()
                case .tasks:
                    count = CoreDataTasks(moc: self.state.moc).countAllTime()
                case .projects:
                    count = CoreDataProjects(moc: self.state.moc).countAll()
                case .terms:
                    count = CoreDataTaxonomyTerms(moc: self.state.moc).countAll()
                }

                entityCounts.append(EntityTypePair(key: type, value: count))
            }
        }
    }
}
