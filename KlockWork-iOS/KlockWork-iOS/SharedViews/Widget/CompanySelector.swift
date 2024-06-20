//
//  CompanySelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-19.
//

import SwiftUI

extension Widget {
    struct CompanySelector {
        struct FormField: View {
            @Binding public var company: Company?
            @Binding public var isCompanySelectorPresented: Bool

            var body: some View {
                Section("Company") {
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

        struct Single: View {
            typealias Row = Tabs.Content.Individual.SingleCompanyCustomButton

            @FetchRequest private var items: FetchedResults<Company>
            @Binding public var showing: Bool
            @Binding public var entity: Company?

            private var columns: [GridItem] {
                return Array(repeating: GridItem(.flexible(), spacing: 1), count: 1) // @TODO: allow user to select more than 1
            }

            var body: some View {
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 0) {
                            Text("Choose a company")
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
                            ForEach(items) { corpo in
                                Row(company: corpo, callback: { company in
                                    self.entity = company
                                    self.showing.toggle()
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies found")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }

            init(showing: Binding<Bool>, entity: Binding<Company?>) {
                _showing = showing
                _entity = entity
                _items = CoreDataCompanies.all()
            }
        }

        struct Multi: View {
            var body: some View {
                Text("Hi")
            }
        }
    }
}
