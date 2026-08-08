//
//  TaskSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-03-08.
//

import SwiftUI

extension Widget {
    struct TaskSelector {
        struct FormField: View {
            @Binding public var company: Company?
            @Binding public var isCompanySelectorPresented: Bool
            public var orientation: FieldOrientation = .vertical

            var body: some View {
                if self.orientation == .vertical {
                    Section("Company") {
                        Button {
                            isCompanySelectorPresented.toggle()
                        } label: {
                            if company == nil {
                                Text("Select Company...")
                            } else {
                                Text(company!.name!)
                                    .padding(5)
                                    .background(Theme.base.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .listRowBackground(self.company == nil ? Theme.textBackground : Color.fromStored(self.company?.colour ?? Theme.rowColourAsDouble))
                } else if self.orientation == .horizontal {
                    HStack(alignment: .center) {
                        Text("Company")
                            .foregroundStyle(.white)

                        Button {
                            isCompanySelectorPresented.toggle()
                        } label: {
                            if company == nil {
                                Text("Select...")
                            } else {
                                Text(company!.name!)
                                    .padding(5)
                                    .background(Theme.base.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .listRowBackground(self.company == nil ? Theme.textBackground : Color.fromStored(self.company!.colour ?? Theme.rowColourAsDouble))
                }
            }
        }

        struct Single: View {
            typealias Row = Tabs.Content.Individual.SingleTaskSelectable

            @FetchRequest private var items: FetchedResults<LogTask>
            @Binding public var showing: Bool
            @Binding public var tasks: [LogTask]

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        Capsule()
                            .fill(Theme.lightWhite)
                            .frame(width: 100, height: 6)
                            .opacity(0.7)
                        Spacer()
                    }
                    .padding()
                    List {
                        Section("Recent") {
                            if self.items.count > 0 {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(self.items, id: \.objectID) { item in
                                        Row(task: item, callback: {
                                            self.tasks.append(item)
                                            self.showing.toggle()
                                        })
                                        .listRowInsets(.none)
                                        .listRowSpacing(.none)
                                        .listRowSeparator(.hidden)
                                    }
                                }
                            } else {
                                StatusMessage.Warning(message: "No tasks found")
                            }
                        }
                        .listSectionSpacing(0)
                    }
                    .padding(-20)
                    .listStyle(.inset)
                    .scrollContentBackground(.hidden)
                }
            }

            init(showing: Binding<Bool>, tasks: Binding<[LogTask]>) {
                _showing = showing
                _tasks = tasks
                _items = CoreDataTasks.all()
            }
        }

        struct Multi: View {
            var body: some View {
                Text("Hi")
            }
        }
    }
}
