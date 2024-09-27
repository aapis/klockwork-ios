//
//  CompanySelector.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-19.
//

import SwiftUI

enum FieldOrientation {
    case horizontal, vertical
}

extension Widget {
    struct CompanySelector {
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
            typealias Row = Tabs.Content.Individual.SingleCompanyDetailedCustomButton

            @FetchRequest private var items: FetchedResults<Company>
            @Binding public var showing: Bool
            @Binding public var entity: Company?

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
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

                    List {
                        if items.filter({$0.alive == true}).count > 0 {
                            ForEach(items.filter({$0.alive == true}), id: \.objectID) { corpo in
                                Row(entity: corpo, callback: { company in
                                    self.entity = company
                                    self.showing.toggle()
                                })
                            }
                        } else {
                            StatusMessage.Warning(message: "No companies found")
                        }
                    }
                    .listStyle(.plain)
                    .listRowInsets(.none)
                    .listRowSeparator(.hidden)
#if os(iOS)
                    .listRowSpacing(.none)
                    .listSectionSpacing(0)
#endif
                    .scrollContentBackground(.hidden)
                }
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
