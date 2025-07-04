//
//  Home.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2025-06-23.
//

import SwiftUI
import CoreData

public enum TabbedWidget {
    case record, search, notes, jobs
}

struct Home: View {
    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var path = NavigationPath()
    @State private var backgroundColour: Color = Theme.cOrange
    @State private var date: Date = Date()
    @AppStorage("home.backgroundColour") public var homeBackgroundColourChoice: Int = 0
    @AppStorage("home.isQuickRecordFocused") private var isQuickRecordFocused: Bool = false
    private let page: PageConfiguration.AppPage = .today

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if !self.inSheet {
                    Header(page: self.page, path: $path)
                    Divider().background(.gray).frame(height: 1)
                }
                ZStack(alignment: .bottom) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading) {
                            QuickAccessTabs()
                            QuickHistory()
                            TasksGroup()
                        }
                    }
                    QuickCreateWidget()
                }
                .padding(8)
            }
            .background(self.backgroundColour)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(self.inSheet ? .visible : .hidden)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.homeBackgroundColourChoice) {
            self.actionOnAppear()
        }
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
                            HStack {
                                PageTitle(text: DateHelper.todayShort(self.state.date, format: "MMMM dd"))
                                Spacer()
                                Button {
                                    self.state.job = nil
                                } label: {
                                    Image(systemName: "arrow.clockwise")
                                        .padding([.leading, .trailing], 8)
                                        .padding([.top, .bottom], 6)
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(self.state.theme.tint)

                                NavigationLink {
                                    AppSettings()
                                } label: {
                                    Image(systemName: "gear")
                                        .font(.title3)
                                }
                            }
                            .padding(.bottom, 8)
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
        @FetchRequest private var tasks: FetchedResults<LogTask>
        public var colour: Color = .clear
        public var label: String = "Block"
        public var icon: String = "circle.circle.fill"
        public var predicate: NSPredicate
        public var target: AnyView? = nil
        public var des: Int = 0

        var body: some View {
            NavigationLink {
                if let trgt = self.target {
                    trgt
                        .navigationTitle(self.label)
                }
            } label: {
                if self.des == 0 {
                    self.desOne
                } else if self.des == 1 {
                    self.desTwo
                }
            }
        }

        var desOne: some View {
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
            .background(
                ZStack {
                    Theme.textBackground
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))
        }

        var desTwo: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    SectionTitle(
                        label: self.label,
                        uppercase: false,
                        fgColour: Theme.base,
                        icon: self.icon,
                        font: .body
                    )
                    Spacer()
                    SectionTitle(
                        label: String(self.tasks.count),
                        uppercase: false,
                        fgColour: Theme.base,
                        font: .body
                    )
                    Image(systemName: "chevron.right")
                        .opacity(0.3)
                }
                .bold()
                .padding(4)
//                .font(.caption)
                .foregroundStyle(Theme.base)
                .background(self.colour == .clear ? self.tasks.count < 10 ? .yellow : self.tasks.count < 20 ? .orange : .red : self.colour)
            }
            .background(Theme.textBackground)
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))
        }
    }

    struct QuickAccessButton: View {
        @EnvironmentObject private var state: AppState
        @AppStorage("home.backgroundColour") public var homeBackgroundColourChoice: Int = 0
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
                    .background(
                        ZStack {
                            switch self.entity {
                            case .notes, .tasks, .terms :
                                self.state.job?.backgroundColor ?? Theme.textBackground
                            default:
                                Theme.textBackground
                            }
                            LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(4)

                    Image(systemName: "plus")
                        .font(.subheadline)
                        .foregroundStyle(Theme.base)
                        .background(self.state.theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .buttonStyle(.plain)
        }
    }

    struct QuickHistory: View {
        @EnvironmentObject private var state: AppState
        private var col2: [GridItem] { Array(repeating: .init(.flexible()), count: 2) }

        var body: some View {
            VStack(alignment: .leading) {
                SectionTitle(
                    label: "Quick History",
                    fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                )
                .padding([.leading, .top], 4)
                LazyVGrid(columns: self.col2, alignment: .leading) {
                    RecentJobsWidget()
                    JobOverviewWidget()
                }
            }
            .padding(4)
            .background(
                ZStack {
                    self.state.job?.backgroundColor ?? Theme.textBackground
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    struct QuickCreateWidget: View {
        @EnvironmentObject private var state: AppState
        @State private var backgroundColour: Color = Theme.cOrange
        @AppStorage("home.backgroundColour") public var homeBackgroundColourChoice: Int = 0

        var body: some View {
            HStack(alignment: .center) {
                Spacer()
                AddButton(plain: false)
                    .foregroundStyle(
                        self.state.job?.backgroundColor.isBright() ?? false ?
                            self.backgroundColour
                        :
                            self.state.theme.tint
                    )
                    .foregroundStyle(self.state.theme.tint)
                    .clipShape(.capsule(style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 2)
                    .padding()
                Spacer()
            }
            .onAppear(perform: {
                switch self.homeBackgroundColourChoice {
                case 1: self.backgroundColour = Theme.cPurple
                case 2: self.backgroundColour = Theme.cGreen
                case 3: self.backgroundColour = Theme.cRoyal
                case 4: self.backgroundColour = Theme.cRed
                default: self.backgroundColour = Theme.cOrange
                }
            })
        }
    }

    struct TasksGroup: View {
        @EnvironmentObject private var state: AppState
        private var col2: [GridItem] { Array(repeating: .init(.flexible()), count: 2) }

        var body: some View {
            VStack(alignment: .leading) {
                SectionTitle(
                    label: "Task Overview",
                    uppercase: true,
                    fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                )
                .padding([.leading, .top], 4)
                VStack(alignment: .leading, spacing: 1) {
                    LazyVGrid(columns: self.col2, alignment: .leading) {
                        VStack(spacing: 1) {
                            Block(
                                colour: .green,
                                label: "Today",
                                icon: "exclamationmark.circle.fill",
                                predicate: NSPredicate(
                                    format: "due > %@ && due < %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                    DateHelper.startOfDay(self.state.date - 86400) as CVarArg,
                                    DateHelper.endOfDay(self.state.date)! as CVarArg,
                                ),
                                target: AnyView(PlanTabs.Overdue()),
                                des: 1
                            )
                            VStack {
                                StatisticRow(
                                    label: "Completed"
                                )
                                StatisticRow(
                                    label: "Created"
                                )
                                StatisticRow(
                                    label: "Updated"
                                )
                            }
                            .padding(4)
                            .background(
                                ZStack {
                                    Theme.textBackground
                                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                }
                            )
                            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Block(
                                colour: .blue,
                                label: "Upcoming",
                                icon: "tray.circle.fill",
                                predicate: NSPredicate(
                                    format: "due > %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                    self.state.date as CVarArg
                                ),
                                target: AnyView(PlanTabs.Upcoming()),
                                des: 1
                            )
                            VStack {
                                StatisticRow(
                                    label: "Today"
                                )
                                StatisticRow(
                                    label: "Next Week"
                                )
                                StatisticRow(
                                    label: "This Month"
                                )
                            }
                            .padding(4)
                            .background(
                                ZStack {
                                    Theme.textBackground
                                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                }
                            )
                            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Block(
                                colour: .red,
                                label: "Overdue",
                                icon: "exclamationmark.circle.fill",
                                predicate: NSPredicate(
                                    format: "due < %@ && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                    self.state.date as CVarArg
                                ),
                                target: AnyView(PlanTabs.Overdue()),
                                des: 1
                            )
                            VStack {
                                StatisticRow(
                                    label: "Yesterday"
                                )
                                StatisticRow(
                                    label: "Last Week"
                                )
                                StatisticRow(
                                    label: "This Month"
                                )
                            }
                            .padding(4)
                            .background(
                                ZStack {
                                    Theme.textBackground
                                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                }
                            )
                            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            Block(
                                label: "Delayed",
                                icon: "tray.circle.fill",
                                predicate: NSPredicate(
                                    format: "(created != due && due > %@) && (completedDate == nil && cancelledDate == nil && owner.project.company.hidden == false)",
                                    self.state.date as CVarArg
                                ),
                                target: AnyView(PlanTabs.Upcoming()),
                                des: 1
                            )
                            VStack {
                                StatisticRow(
                                    label: "Today"
                                )
                                StatisticRow(
                                    label: "Next Week"
                                )
                                StatisticRow(
                                    label: "This Month"
                                )
                            }
                            .padding(4)
                            .background(
                                ZStack {
                                    Theme.textBackground
                                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                                }
                            )
                            .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4))
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(Theme.lightWhite)
            }
            .padding(4)
            .background(
                ZStack {
                    (self.state.job?.backgroundColor ?? Theme.textBackground)
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .bottom, endPoint: .top)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    struct QuickAccessTabs: View {
        @EnvironmentObject private var state: AppState
        @State private var selectedWidgetTab: TabbedWidget = .record

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Tabs
                HStack(spacing: 1) {
                    Button {
                        self.selectedWidgetTab = .record
                    } label: {
                        Image(systemName: PageConfiguration.EntityType.records.iconString)
                            .padding(8)
                            .padding([.top, .bottom], 1)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(self.selectedWidgetTab == .record ? self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint : Theme.lightWhite)
                    .background(
                        ZStack(alignment: .bottom) {
                            (self.selectedWidgetTab == .record ? self.state.job?.backgroundColor ?? Theme.textBackground : .clear)
                            LinearGradient(colors: [.clear, (self.selectedWidgetTab == .record && self.state.job != nil ? Color.black : Color.clear).opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                .blendMode(.softLight)
                                .frame(height: 15)
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))

                    Button {
                        self.selectedWidgetTab = .search
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(8)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(self.selectedWidgetTab == .search ? self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint : Theme.lightWhite)
                    .background(
                        ZStack(alignment: .bottom) {
                            (self.selectedWidgetTab == .search ? self.state.job?.backgroundColor ?? Theme.textBackground : .clear)
                            LinearGradient(colors: [.clear, (self.selectedWidgetTab == .search && self.state.job != nil ? Color.black : Color.clear).opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                .blendMode(.softLight)
                                .frame(height: 15)
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))

                    Button {
                        self.selectedWidgetTab = .notes
                    } label: {
                        Image(systemName: PageConfiguration.EntityType.notes.iconString)
                            .padding(8)
                            .padding([.top, .bottom], 1)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(self.selectedWidgetTab == .notes ? self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint : Theme.lightWhite)
                    .background(
                        ZStack(alignment: .bottom) {
                            (self.selectedWidgetTab == .notes ? self.state.job?.backgroundColor ?? Theme.textBackground : .clear)
                            LinearGradient(colors: [.clear, (self.selectedWidgetTab == .notes && self.state.job != nil ? Color.black : Color.clear).opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                .blendMode(.softLight)
                                .frame(height: 15)
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))

                    Button {
                        self.selectedWidgetTab = .jobs
                    } label: {
                        Image(systemName: PageConfiguration.EntityType.jobs.iconString)
                            .padding([.leading, .trailing], 8)
                            .padding([.top, .bottom], 6)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(self.selectedWidgetTab == .jobs ? self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint : Theme.lightWhite)
                    .background(
                        ZStack(alignment: .bottom) {
                            (self.selectedWidgetTab == .jobs ? self.state.job?.backgroundColor ?? Theme.textBackground : .clear)
                            LinearGradient(colors: [.clear, (self.selectedWidgetTab == .jobs && self.state.job != nil ? Color.black : Color.clear).opacity(0.7)], startPoint: .top, endPoint: .bottom)
                                .blendMode(.softLight)
                                .frame(height: 15)
                        }
                    )
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))
                }
                .font(.system(.body, design: .monospaced))
                .padding(.leading, 8)

                // View bodies
                if self.selectedWidgetTab == .record {
                    QuickRecordPanel()
                } else if self.selectedWidgetTab == .search {
                    QuickSearchPanel()
                } else if self.selectedWidgetTab == .notes {
                    FavouriteNotes()
                } else if self.selectedWidgetTab == .jobs {
                    FavouriteJobs()
                }
            }
        }
    }
}

extension Home.QuickAccessTabs {
    struct QuickRecordPanel: View {
        @EnvironmentObject private var state: AppState
        @State private var content: String = ""
        @State private var defaultJob: Job? = nil
        @FocusState public var hasFocus: Bool
        @AppStorage("home.isQuickRecordFocused") private var isQuickRecordFocused: Bool = false
        private let page: PageConfiguration.AppPage = .today

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    SectionTitle(
                        label: "Quick Record",
                        fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                    )
                    .padding([.leading, .top], 4)
                    Spacer()
                    if let dJob = self.defaultJob {
                        if self.state.job == nil {
                            SectionTitle(
                                label: "~/\(dJob.project?.company?.abbreviation ?? "404")/\(dJob.project?.abbreviation ?? "404")/\(dJob.title ?? dJob.jid.string)",
                                fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite
                            )
                            .padding([.trailing], 4)
                        } else {
                            SectionTitle(
                                label: "~/\(self.state.job!.project?.company?.abbreviation ?? "404")/\(self.state.job!.project?.abbreviation ?? "404")/\(self.state.job!.title ?? self.state.job!.jid.string)",
                                fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite
                            )
                            .padding([.trailing], 4)
                        }
                    }
                }
                HStack {
                    ZStack(alignment: .trailing) {
                        TextField("Start typing...", text: $content)
                            .onSubmit(self.actionOnSubmit)
                            .padding()
                            .lineLimit(3...)
                            .multilineTextAlignment(.leading)
                            .textFieldStyle(.plain)
                            .focused(self.$hasFocus)
                            .onChange(of: self.hasFocus) {
                                if self.hasFocus == false {
                                    self.isQuickRecordFocused = false
                                } else {
                                    self.isQuickRecordFocused = true
                                }
                            }
                            .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : .white)

                        if self.content != "" {
                            Button {
                                self.content = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .bold()
                                    .padding(.trailing)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .background(
                    ZStack {
                        Theme.textBackground.opacity(self.hasFocus ? 1 : 0.5)
                        LinearGradient(colors: [.clear, Theme.textBackground.opacity(self.hasFocus ? 1 : 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .tint(self.state.theme.tint)
            .padding(4)
            .background(
                ZStack {
                    (self.state.job?.backgroundColor ?? Theme.textBackground)
                    LinearGradient(colors: [.clear, Theme.textBackground.opacity(self.hasFocus ? 1 : 0.4)], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onAppear(perform: self.actionOnAppear)
        }
    }

    struct QuickSearchPanel: View {
        @EnvironmentObject private var state: AppState
        @FetchRequest public var savedSearchTerms: FetchedResults<SavedSearch>

        var body: some View {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    SectionTitle(
                        label: "Quick Search",
                        uppercase: true,
                        fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                    )
                    Spacer()
//                    Button {
//
//                    } label: {
//                        Image(systemName: "slider.horizontal.2.square")
//                    }
//                    .buttonStyle(.plain)
                }
                .padding([.leading, .top], 4)
                .padding(.bottom, 8)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 1) {
                        ForEach(self.savedSearchTerms, id: \.self) { term in
                            SavedTerm(savedSearch: term)
                        }
                    }
                }
                .frame(height: 130)
            }
            .tint(self.state.theme.tint)
            .foregroundStyle(self.state.theme.tint)
            .padding(4)
            .background(
                ZStack {
                    (self.state.job?.backgroundColor ?? Theme.textBackground)
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }

        struct SavedTerm: View {
            @EnvironmentObject private var state: AppState
            public var savedSearch: SavedSearch

            var body: some View {
                NavigationLink {
                    Find(text: self.savedSearch.term ?? "")
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                        if let term = self.savedSearch.term {
                            Text(term)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle((self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint).opacity(0.3))
                    }
                    .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : self.state.theme.tint)
                    .padding(4)
                    .background(Theme.textBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }

    struct FavouriteNotes: View {
        @EnvironmentObject private var state: AppState
        @FetchRequest private var items: FetchedResults<Note>

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    SectionTitle(
                        label: "Favourite Notes",
                        fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                    )
                    .padding([.leading, .top], 4)
                    Spacer()
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 1) {
                        ForEach(self.items, id: \.self) { entity in
                            FavouriteItem(item: entity, link: AnyView(NoteDetail(note: entity)))
                        }
                    }
                }
                .frame(height: 130)
            }
            .tint(self.state.theme.tint)
            .padding(4)
            .background(
                ZStack {
                    (self.state.job?.backgroundColor ?? Theme.textBackground)
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
//            .onAppear(perform: self.actionOnAppear)
        }
    }

    struct FavouriteJobs: View {
        @EnvironmentObject private var state: AppState
        @FetchRequest private var items: FetchedResults<Job>

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    SectionTitle(
                        label: "Favourite Jobs",
                        fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.base : Theme.lightWhite
                    )
                    .padding([.leading, .top], 4)
                    Spacer()
                }
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 1) {
                        ForEach(self.items, id: \.self) { entity in
                            HStack(spacing: 0) {
                                FavouriteItem(item: entity, link: nil)
//                                Text(self.state.job == entity ? "Active" : "Inactive")
                            }
                        }
                    }
                }
                .frame(height: 130)
            }
            .tint(self.state.theme.tint)
            .padding(4)
            .background(
                ZStack {
                    (self.state.job?.backgroundColor ?? Theme.textBackground)
                    LinearGradient(colors: [.clear, Theme.textBackground], startPoint: .topLeading, endPoint: .bottomTrailing)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
//            .onAppear(perform: self.actionOnAppear)
        }
    }

    struct FavouriteItem: View {
        @EnvironmentObject private var state: AppState
        public var item: NSManagedObject
        public var link: AnyView?

        var body: some View {
            if self.link == nil {
                Button {
                    switch self.item {
                    case is Job: self.state.job = (self.item as! Job)
                    default: {}()
                    }
                } label: {
                    self.label
                }
            } else {
                NavigationLink {
                    self.link
                } label: {
                    self.label
                }
            }
        }

        var label: some View {
            HStack {
                Image(systemName: "hammer.circle.fill")
                switch self.item {
                case is Note:
                    Text((self.item as! Note).title ?? "Invalid note title")
                        .lineLimit(1)
                case is Job:
                    Text((self.item as! Job).title ?? (self.item as! Job).jid.string)
                        .lineLimit(1)
                default:
                    Text("Invalid type")
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .opacity(0.3)
            }
            .padding(4)
            .foregroundStyle(
                ((self.item as? Job)?.backgroundColor ?? (self.item as? Note)?.mJob?.backgroundColor ?? Theme.textBackground).isBright() ?
                    Theme.base
                :
                    self.state.theme.tint
            )
            .background(
                (self.item as? Job)?.backgroundColor ?? (self.item as? Note)?.mJob?.backgroundColor ?? Theme.textBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

extension Home.QuickAccessTabs.QuickSearchPanel {

}

extension Home.QuickAccessTabs.FavouriteNotes {
    init() {
        _items = CoreDataNotes.fetchNotes(favouritesOnly: true)
    }
}

extension Home.QuickAccessTabs.FavouriteJobs {
    init() {
        _items = CoreDataJob.fetchAll(favsOnly: true)
    }
}

extension Home.QuickAccessTabs.QuickSearchPanel {
    init() {
        // 1 year in the past
        let interval: TimeInterval = (86400*365) * -1

        _savedSearchTerms = CDSavedSearch.createdBetween(
            DateHelper.startOfMonth(for: Date().addingTimeInterval(interval)),
            DateHelper.endOfMonth(for: Date())
        )
    }
}

extension Home.TasksGroup {
    struct StatisticRow: View {
        public var label: String
        public var value: Int = 0

        var body: some View {
            HStack {
                Text(self.label)
                Spacer()
                Text(String(self.value))
            }
        }
    }
}

extension Home.QuickHistory {
    struct RecentJobsWidget: View {
        @EnvironmentObject private var state: AppState
        @State private var suggestedJobs: [Job] = []
        @FetchRequest private var recentJobs: FetchedResults<Job>
        @FetchRequest private var suggestedJobsFromTasks: FetchedResults<LogTask>

        var body: some View {
            VStack(alignment: .leading) {
                ScrollView(.vertical) {
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 1) {
                            if let job = self.state.job {
                                SectionTitle(
                                    label: "",
                                    uppercase: false,
                                    fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite,
                                    icon: "hammer",
                                    alignment: .trailing
                                )
                                    .padding(4)
                                TappableRowWithIcon(job: job, icon: "hammer.circle.fill")
                            }
                            if self.suggestedJobs.count > 0 {
                                SectionTitle(
                                    label: "",
                                    uppercase: false,
                                    fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite,
                                    icon: "checklist",
                                    alignment: .trailing
                                )
                                    .padding(4)
                                ForEach(self.suggestedJobs.sorted(by: {$0.lastUpdate ?? Date() > $1.lastUpdate ?? Date()}), id: \.self) { job in
                                    TappableRowWithIcon(job: job, icon: "hammer.circle.fill")
                                }
                            }
                            if self.recentJobs.count > 0 {
                                SectionTitle(
                                    label: "",
                                    uppercase: false,
                                    fgColour: self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite,
                                    icon: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                                    alignment: .trailing
                                )
                                    .padding(4)
                                ForEach(self.recentJobs.sorted(by: {$0.lastUpdate ?? Date() > $1.lastUpdate ?? Date()}), id: \.self) { job in
                                    TappableRowWithIcon(job: job, icon: "hammer.circle.fill")
                                }
                            } else {
                                HStack {
                                    Image(systemName: "hammer.circle")
                                    Text("None")
                                        .lineLimit(1)
                                        .font(.caption)
                                    Spacer()
                                }
                                .padding(4)
                                .background(.gray.opacity(0.4))
                                .foregroundStyle(Theme.base)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(1)
                .background(Theme.textBackground)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(height: 130)
                .onAppear(perform: self.actionOnAppear)
            }
        }
    }

    struct JobOverviewWidget: View {
        @EnvironmentObject private var state: AppState
        @State private var recentInteractions: [String] = []
        @State private var job: Job? = nil

        var body: some View {
            VStack(alignment: .leading) {
                ScrollView(.vertical) {
                    if self.state.job != nil {
                        VStack(alignment: .leading, spacing: 1) {
                            GenericTappableRowWithIcon(
                                title: self.state.job!.project?.company?.name ?? "404",
                                icon: PageConfiguration.EntityType.companies.iconSelectedString,
                                iconColour: self.state.job!.project?.company?.backgroundColor ?? Theme.base,
                                callback: AnyView(CompanyDetail(company: self.state.job!.project!.company!))
                            )
                            GenericTappableRowWithIcon(
                                title: self.state.job!.project?.name ?? "404",
                                icon: PageConfiguration.EntityType.projects.iconSelectedString,
                                iconColour: self.state.job!.project?.backgroundColor ?? Theme.base,
                                callback: AnyView(ProjectDetail(project: self.state.job!.project!))
                            )
                            GenericTappableRowWithIcon(
                                title: self.state.job!.title ?? self.state.job!.jid.string,
                                icon: PageConfiguration.EntityType.jobs.iconSelectedString,
                                iconColour: self.state.job!.backgroundColor,
                                callback: AnyView(JobDetail(job: self.state.job!))
                            )
                            SectionTitle(
                                label: "Interactions",
                                fgColour: self.state.job!.backgroundColor.isBright() ? Theme.base : Theme.lightWhite,
                                alignment: .trailing
                            )
                            .padding(4)
                            .background(Theme.textBackground)
                            VStack(alignment: .leading, spacing: 1) {
                                ForEach(self.recentInteractions, id: \.self) { timestamp in
                                    GenericTappableRowWithIcon(
                                        title: timestamp,
                                        icon: "calendar",
                                        callback: AnyView(
                                            Tabs.Content.List.Records(
                                                job: self.$job,
                                                date: DateHelper.date(from: timestamp, format: "MMM, dd, yyyy") ?? Date(),
                                                inSheet: false
                                            )
                                            .background(Theme.cPurple)
                                            .navigationTitle(timestamp)
                                        )
                                    )
                                }
                            }
                            Spacer()
                        }
                        .font(.caption)
                        .foregroundStyle(self.state.job!.backgroundColor.isBright() ? Theme.base : self.state.theme.tint)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    } else {
                        VStack(alignment: .leading, spacing: 1) {
                            GenericTappableRowWithIcon(
                                title: "N/A",
                                icon: PageConfiguration.EntityType.companies.iconSelectedString,
                                iconColour: Theme.lightWhite
                            )
                            GenericTappableRowWithIcon(
                                title: "N/A",
                                icon: PageConfiguration.EntityType.projects.iconSelectedString,
                                iconColour: Theme.lightWhite
                            )
                            GenericTappableRowWithIcon(
                                title: "N/A",
                                icon: PageConfiguration.EntityType.jobs.iconSelectedString,
                                iconColour: Theme.lightWhite
                            )
                        }
                    }
                }

            }
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.state.job) {
                self.actionOnAppear()
            }
            .frame(height: 130)
        }
    }

    struct TappableRowWithIcon: View {
        @EnvironmentObject private var state: AppState
        public let job: Job
        public var icon: String = "hammer.circle.fill"

        var body: some View {
            Button {
                if self.state.job == self.job {
                    self.state.job = nil
                } else {
                    self.state.job = self.job
                }
            } label: {
                HStack {
                    Image(systemName: self.icon)
                    Text(self.job.title ?? "No title")
                        .lineLimit(1)
                    Spacer()
                    if self.state.job == self.job {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.caption)
                .padding(4)
                .background(self.job.backgroundColor)
                .foregroundStyle(self.job.backgroundColor.isBright() ? Theme.base : .white)
            }
            .buttonStyle(.plain)
        }
    }

    struct GenericTappableRowWithIcon: View {
        @EnvironmentObject private var state: AppState
        public var title: String
        public var icon: String = "hammer.circle.fill"
        public var colour: Color = Theme.textBackground
        public var iconColour: Color? = nil
        public var callback: AnyView? = nil

        var body: some View {
            NavigationLink {
                if self.callback != nil {
                    self.callback!
                }
            } label: {
                HStack {
                    if self.iconColour != nil {
                        Image(systemName: self.icon)
                            .foregroundStyle(self.iconColour!)
                    } else {
                        Image(systemName: self.icon)
                    }
                    Text(self.title)
                        .lineLimit(1)
                    Spacer()
                    if self.callback != nil {
                        Image(systemName: "chevron.right")
                    }
                }
                .font(.caption)
                .padding(4)
                .background(self.colour)
//                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
        }
    }
}

extension Home.QuickHistory.JobOverviewWidget {
    /// Fires on appear
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.recentInteractions = []
        if let job = self.state.job {
            self.job = job
            let interactions = CoreDataRecords(moc: self.state.moc).find(for: job)
            let grouped = Dictionary(grouping: interactions, by: {($0.timestamp ?? Date()).formatted(date: .abbreviated, time: .omitted)})
            let sorted = Array(grouped)
                .sorted(by: {
                    let df = DateFormatter()
                    df.dateStyle = .medium
                    df.timeStyle = .none
                    if let d1 = df.date(from: $0.key) {
                        if let d2 = df.date(from: $1.key) {
                            return d1 > d2
                        }
                    }
                    return false
                })

            for group in sorted {
                self.recentInteractions.append(group.key)
            }
        }
    }
}

extension Home.QuickHistory.RecentJobsWidget {
    /// Init
    init() {
        _recentJobs = CoreDataJob.fetchRecent(limit: 8)
        _suggestedJobsFromTasks = CoreDataTasks.fetchDue()
    }
    
    /// Fires on appear
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.suggestedJobs = []
        var sJobs: Set<Job> = []

        if !self.suggestedJobsFromTasks.isEmpty {
            for task in self.suggestedJobsFromTasks {
                if let job = task.owner {
                    sJobs.insert(job)
                }
            }
            self.suggestedJobs = Array(sJobs)
        }
    }
}

extension Home {
    /// Fires when view appears or some settings are changed
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        switch self.homeBackgroundColourChoice {
        case 1: self.backgroundColour = Theme.cPurple
        case 2: self.backgroundColour = Theme.cGreen
        case 3: self.backgroundColour = Theme.cRoyal
        case 4: self.backgroundColour = Theme.cRed
        default: self.backgroundColour = Theme.cOrange
        }
    }
}

extension Home.Block {
    init(colour: Color = .clear, label: String, icon: String, predicate: NSPredicate, target: AnyView? = nil, des: Int = 0) {
        self.colour = colour
        self.label = label
        self.icon = icon
        self.target = target
        self.predicate = predicate
        self.des = des
        _tasks = CoreDataTasks.fetch(with: predicate)
    }
}

extension Home.QuickAccessTabs.QuickRecordPanel {
    /// Fires when view appears
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let job = CoreDataJob(moc: self.state.moc).getDefault() {
            self.defaultJob = job
        }
    }

    /// Fires on submit/return
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        if self.state.job == nil {
            if let job = CoreDataJob(moc: self.state.moc).getDefault() {
                CoreDataRecords(moc: self.state.moc).createWithJob(
                    job: job,
                    date: self.state.date,
                    text: self.content
                )
            }
        } else {
            CoreDataRecords(moc: self.state.moc).createWithJob(
                job: self.state.job!,
                date: self.state.date,
                text: self.content
            )
        }

        self.content = ""
    }
}

struct SectionTitle: View {
    public let label: String
    public var uppercase: Bool = true
    public var fgColour: Color = .white.opacity(0.6)
    public var icon: String? = nil
    public var alignment: Alignment = .leading
    public var font: Font = .caption

    var body: some View {
        HStack(spacing: self.label == "" ? 0 : 8) {
            if self.alignment == .trailing {
                Spacer()
            }
            if let icon = self.icon {
                Image(systemName: icon)
            }
            Text(self.uppercase ? self.label.uppercased() : self.label)
                .lineLimit(1)
        }
        .font(self.font)
        .foregroundStyle(self.fgColour)
    }
}

struct SectionSubTitle: View {
    public let label: String
    public var uppercase: Bool = true
    public var fgColour: Color = .white.opacity(0.6)

    var body: some View {
        HStack {
            Text(self.uppercase ? self.label.uppercased() : self.label)
                .font(.caption2)
                .foregroundStyle(self.fgColour)
        }
    }
}

struct ScrollIndicator: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        HStack(spacing: 0) {
            Divider()
                .foregroundStyle(.white.opacity(0.6))
            VStack {
                Image(systemName: "chevron.up")
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(2)
            .font(.system(size: 6))
            .foregroundStyle(self.state.job?.backgroundColor.isBright() ?? false ? Theme.lightBase : Theme.lightWhite)
        }
    }
}
