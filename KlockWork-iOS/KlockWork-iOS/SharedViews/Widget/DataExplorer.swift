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
        private let fgColour: Color = .yellow
        private var columns: [GridItem] {
            Array(repeating: .init(.flexible()), count: 2)
        }
        @State private var path = NavigationPath()
        @State private var entityCounts: [EntityTypePair] = []
        @State private var isPresented: Bool = false
        @State private var searchText: String = ""
        @State private var open: Bool = false

        var body: some View {
            NavigationStack(path: $path) {
                Grid(alignment: .leading, horizontalSpacing: 0, verticalSpacing: 1) {
                    GridRow(alignment: .center) {
                        Button {
                            self.open.toggle()
                        } label: {
                            HStack {
                                Text("Data Explorer")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                                Image(systemName: self.open ? "minus" : "plus")
                            }
                            .padding()
                            .background(Theme.rowColour)
                        }
                    }
                    .clipShape(
                        .rect(
                            topLeadingRadius: 16,
                            bottomLeadingRadius: self.open ? 0 : 16,
                            bottomTrailingRadius: self.open ? 0 : 16,
                            topTrailingRadius: 16
                        )
                    )
                    
                    if self.open {
                        ForEach(EntityType.allCases, id: \.self) { type in
                            GridRow {
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
                                    }
                                } label: {
                                    HStack {
                                        type.icon
                                            .foregroundStyle(fgColour)
                                        Text(type.label)
                                        Spacer()
                                        Text(String(entityCounts.first(where: {$0.key == type})?.value ?? 0))
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.gray)
                                    }
                                    .padding([.leading, .trailing])
                                    .padding([.top, .bottom], 10)
                                }
                                .background(Theme.textBackground)
                            }
                        }
                    }
                }
            }
            .tint(fgColour)
            .onAppear(perform: actionOnAppear)
        }
    }
}

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
                }

                entityCounts.append(EntityTypePair(key: type, value: count))
            }
        }
    }
}
