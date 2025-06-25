//
//  Home.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2025-06-23.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var path = NavigationPath()
    private let page: PageConfiguration.AppPage = .today
    private var col2: [GridItem] { Array(repeating: .init(.flexible()), count: 2) }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if !self.inSheet {
                    Header(page: self.page, path: $path)
                    Divider().background(.gray).frame(height: 1)
                }
                VStack(alignment: .leading) {
                    SectionTitle(label: "Tasks")
                    LazyVGrid(columns: self.col2, alignment: .center) {
                        Block(
                            colour: .red,
                            label: "Overdue",
                            icon: "exclamationmark.circle.fill",
                            predicate: NSPredicate(
                                format: "due < %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                self.state.date as CVarArg
                            ),
                            target: AnyView(PlanTabs.Overdue())
                        )
                        Block(
                            colour: .blue,
                            label: "Upcoming",
                            icon: "tray.circle.fill",
                            predicate: NSPredicate(
                                format: "due > %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                self.state.date as CVarArg
                            ),
                            target: AnyView(PlanTabs.Upcoming())
                        )
                    }
                    .padding(.bottom)

                    SectionTitle(label: "Quick Create")
                    HStack(spacing: 1) {
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.notes)
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.tasks)
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.jobs)
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.companies)
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.projects)
                        QuickAccessButton(colour: .white, entity: PageConfiguration.EntityType.terms)
                    }
                }
                .padding()

                List {
                    Section("Organization") {
                        NavigationLink {
                            Planning(inSheet: true)
                        } label: {
                            HStack {
                                Image(systemName: self.state.plan != nil ? "circle.hexagongrid.fill" : "hexagon")
                                    .foregroundStyle(self.state.theme.tint)
                                Text("Planning")
                            }
                        }
                        .listRowBackground(Theme.textBackground)

                        NavigationLink {
                            Widget.DataExplorer()
                        } label: {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundStyle(self.state.theme.tint)
                                Text("Data Explorer")
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .background(Theme.cPurple)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(self.inSheet ? .visible : .hidden)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
    }
}

extension Home {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = DateHelper.startOfDay()
        @State private var isCreateSheetPresented: Bool = false
        @State private var isCalendarPresented: Bool = false
        @AppStorage("today.viewMode") private var viewMode: Int = 0
        public let page: PageConfiguration.AppPage
        @Binding public var path: NavigationPath

        var body: some View {
            HStack(alignment: .center, spacing: 0) {
                ZStack(alignment: .bottom) {
                    LinearGradient(gradient: Gradient(colors: [Theme.base, .clear]), startPoint: .bottom, endPoint: .top)
                        .opacity(0.2)
                        .blendMode(.softLight)
                        .frame(height: 45)

                    HStack(spacing: 8) {
                        Button {
                            self.isCalendarPresented.toggle()
                        } label: {
                            HStack(spacing: 0) {
                                PageTitle(text: "KlockWork")
                                    .padding(.bottom)
                                PageTitle(text: "1.0")
                                    .foregroundStyle(.gray)
                                    .padding(.bottom)
                            }
                        }
                        .buttonStyle(.plain)
                        .opacity(self.viewMode == 0 || self.viewMode == 1 ? 1 : 0.5)
                        Spacer()
                    }
                }
            }
            .onAppear(perform: {
                self.date = self.state.date
            })
            .onChange(of: self.date) {
                if self.state.date != self.date {
                    self.state.date = DateHelper.startOfDay(self.date)
                }
            }
            .onChange(of: self.isCalendarPresented) {
                if self.isCalendarPresented {
                    self.viewMode = 2
                } else {
                    self.viewMode = 0
                }
            }
        }
    }

    struct Block: View {
        @EnvironmentObject private var state: AppState
        public var colour: Color = .clear
        public var label: String = "Block"
        public var icon: String = "circle.circle.fill"
        public var predicate: NSPredicate
        public var target: AnyView? = nil
        @FetchRequest public var tasks: FetchedResults<LogTask>

        var body: some View {
            NavigationLink {
                if let trgt = self.target {
                    trgt
                        .navigationTitle(self.label)
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Image(systemName: self.icon)
                            .font(.title)
                            .foregroundStyle(self.colour)
                        Spacer()
                        Text(String(self.tasks.count))
                            .font(.title2)
                            .bold()
                    }
                    .padding(.bottom, 25)
                    HStack(alignment: .center) {
                        Text(self.label)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.subheadline)
                            .opacity(0.3)
                    }
                }
                .padding()
                .background(Theme.textBackground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
    }

    struct QuickAccessButton: View {
        @EnvironmentObject private var state: AppState
        public var colour: Color = .clear
        public var label: String = "Button"
        public var entity: PageConfiguration.EntityType

        var body: some View {
            NavigationLink {
                switch self.entity {
                case .tasks:
                    TaskDetail()
                case .notes:
                    NoteDetail()
                case .people:
                    PersonDetail()
                case .companies:
                    CompanyDetail()
                case .projects:
                    ProjectDetail()
                case .jobs:
                    JobDetail()
                case .terms:
                    TermDetail()
                default:
                    Text("Nope")
                    // do nothing
                }
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    HStack {
                        self.entity.icon
                            .font(.headline)
                            .foregroundStyle(self.colour)
                            .bold()
                    }
                    .frame(height: 25)
                    .padding()
                    .background(Theme.textBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                    Image(systemName: "plus")
                        .font(.subheadline)
                        .foregroundStyle(Theme.cPurple)
                        .background(self.state.theme.tint)
                        .clipShape(UnevenRoundedRectangle(bottomTrailingRadius: 4))
                }
            }
            .buttonStyle(.plain)
        }
    }
}

extension Home.Block {
    init(colour: Color, label: String, icon: String, predicate: NSPredicate, target: AnyView? = nil) {
        self.colour = colour
        self.label = label
        self.icon = icon
        self.target = target
        self.predicate = predicate
        _tasks = CoreDataTasks.fetch(with: predicate)
    }
}

struct SectionTitle: View {
    public let label: String

    var body: some View {
        Text(self.label.uppercased())
            .font(.caption)
            .foregroundStyle(.white.opacity(0.6))
            .padding(.leading)
    }
}
