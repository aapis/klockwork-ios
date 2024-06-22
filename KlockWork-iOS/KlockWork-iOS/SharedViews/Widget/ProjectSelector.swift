//
//  ProjectSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-19.
//

import SwiftUI

extension Widget {
    struct ProjectSelector {
        struct FormField: View {
            @Binding public var project: Project?
            @Binding public var company: Company?
            @Binding public var isProjectSelectorPresented: Bool
            public var orientation: FieldOrientation = .vertical

            var body: some View {
                if self.orientation == .vertical {
                    Section("Project") {
                        Button {
                            isProjectSelectorPresented.toggle()
                        } label: {
                            if project == nil {
                                Text("Select Project...")
                            } else {
                                Text(project!.name!)
                                    .padding(5)
                                    .background(Theme.base.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        .disabled(company == nil)
                    }
                    .listRowBackground(project == nil ? Theme.textBackground : Color.fromStored(project!.colour ?? Theme.rowColourAsDouble))
                } else if self.orientation == .horizontal {
                    HStack(alignment: .center) {
                        if project == nil {
                            Text("Project")
                                .foregroundStyle(.gray)
                        }

                        Button {
                            isProjectSelectorPresented.toggle()
                        } label: {
                            if project == nil {
                                Text("Select...")
                            } else {
                                Text(project!.name!)
                                    .padding(5)
                                    .background(Theme.base.opacity(0.2))
                                    .cornerRadius(5)
                            }
                        }
                        .disabled(company == nil)
                    }
                    .listRowBackground(self.project == nil ? Theme.textBackground : Color.fromStored(self.project!.colour ?? Theme.rowColourAsDouble))
                }
            }
        }

        // Select a single job from the list
        struct Single: View {
            typealias Row = Tabs.Content.Individual.SingleProjectCustomButton

            @FetchRequest private var items: FetchedResults<Project>
            @Binding public var showing: Bool
            @Binding public var entity: Project?
            public let company: Company

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Choose a project")
                                .font(.title2)
                            Spacer()
                            Button {
                                showing.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding()

                        if items.count > 0 {
                            ForEach(items) { item in
                                Row(entity: item, callback: { project  in
                                    self.entity = project
                                    self.showing.toggle()
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No projects found")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }

            init(showing: Binding<Bool>, entity: Binding<Project?>, company: Company) {
                _showing = showing
                _entity = entity
                self.company = company
                _items = CoreDataProjects.fetch(by: self.company) // @TODO: fetch request is probably unnecessary
            }
        }

        /// Allows selection of multiple projects from the list
        struct Multi: View {
            typealias Row = Tabs.Content.Individual.SingleProjectCustomButtonTwoState

            @FetchRequest private var items: FetchedResults<Project>
            @Binding public var showing: Bool
            @Binding private var selected: [Project]

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Projects")
                                .font(.title2)
                            Spacer()
                            Button {
                                showing.toggle()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                        .padding()

                        HStack(alignment: .center, spacing: 5) {
                            Spacer()
                            Text("Selected: \(selected.count)")
                        }
                        .padding()

                        if items.count > 0 {
                            ForEach(items) { entity in
                                Row(entity: entity, alreadySelected: self.isSelected(entity), callback: { project, action in
                                    if action == .add {
                                        selected.append(project)
                                    } else if action == .remove {
                                        if let index = selected.firstIndex(where: {$0 == project}) {
                                            selected.remove(at: index)
                                        }
                                    }
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No projects found")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }

            init(showing: Binding<Bool>, selected: Binding<[Project]>) {
                _showing = showing
                _selected = selected
                _items = CoreDataProjects.fetchUnowned()
            }

            /// Determine if a given project has been selected
            /// - Parameter project: Project
            /// - Returns: Bool
            private func isSelected(_ project: Project) -> Bool {
                return selected.firstIndex(where: {$0 == project}) != nil
            }
            
            /// Selector for interacting with the multi-select field
            struct FormField: View {
                typealias Row = Tabs.Content.Individual.SingleProjectCustomButtonTwoState

                @Binding public var projects: [Project]
                @Binding public var company: Company?
                @Binding public var isProjectSelectorPresented: Bool
                public var orientation: FieldOrientation = .vertical

                var body: some View {
                    if projects.isEmpty {
                        Button {
                            isProjectSelectorPresented.toggle()
                        } label: {
                            HStack {
                                Text("Select...")
                                Spacer()
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    } else {
                        ForEach(projects) { project in
                            Row(entity: project, alreadySelected: self.isSelected(project), callback: { project, action in
                                if action == .add {
                                    projects.append(project)
                                } else if action == .remove {
                                    if let index = projects.firstIndex(where: {$0 == project}) {
                                        projects.remove(at: index)
                                    }
                                }
                            })
                        }
                    }
                }

                /// Determine if a given project has been selected
                /// - Parameter project: Project
                /// - Returns: Bool
                private func isSelected(_ project: Project) -> Bool {
                    return projects.firstIndex(where: {$0 == project}) != nil
                }
            }
        }
    }
}
