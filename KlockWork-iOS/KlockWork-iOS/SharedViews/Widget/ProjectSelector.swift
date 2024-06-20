//
//  ProjectSelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-19.
//

import SwiftUI

extension Widget {
    struct ProjectSelector {
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
                                Row(entity: item, callback: { project in
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

        struct Multi: View {
            var body: some View {
                Text("Hi")
            }
        }
    }
}
