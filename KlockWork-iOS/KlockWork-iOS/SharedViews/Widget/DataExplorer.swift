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

        @Binding public var date: Date
        private let fgColour: Color = .yellow
        private var columns: [GridItem] {
            Array(repeating: .init(.flexible()), count: 2)
        }
        @State private var path = NavigationPath()
        @State private var entityCounts: [EntityTypePair] = []
        @State private var isPresented: Bool = false
        @State private var searchText: String = ""
        @State private var open: Bool = false

        @Environment(\.managedObjectContext) var moc

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
                                        People()
                                            .environment(\.managedObjectContext, moc)
                                            .navigationTitle(type.label)
                                    case .records: // @TODO: implement records listing view
                                        Records()
                                            .environment(\.managedObjectContext, moc)
                                            .navigationTitle(type.label)
                                    case .tasks:
                                        Tasks()
                                            .environment(\.managedObjectContext, moc)
                                            .navigationTitle(type.label)
                                    case .projects:
                                        Projects()
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
                    count = CoreDataCompanies(moc: moc).countAll()
                case .jobs:
                    count = CoreDataJob(moc: moc).countAll()
                case .notes:
                    count = CoreDataNotes(moc: moc).alive().count
                case .people:
                    count = CoreDataPerson(moc: moc).countAll()
                case .records:
                    count = CoreDataRecords(moc: moc).countAll()
                case .tasks:
                    count = CoreDataTasks(moc: moc).countAllTime()
                case .projects:
                    count = CoreDataProjects(moc: moc).countAll()
                }

                entityCounts.append(EntityTypePair(key: type, value: count))
            }
        }
    }
}
