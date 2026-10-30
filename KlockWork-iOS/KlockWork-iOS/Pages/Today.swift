//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct PageHeader: View {
    public var title: String
    public var description: String = ""
    @AppStorage("global.showPageHeaders") private var showPageHeaders: Bool = false

    var body: some View {
        if self.showPageHeaders {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(self.title)
                        .font(.title2)
                    Spacer()
                }
                HStack {
                    Text(self.description)
                        .font(.subheadline)
                        .foregroundStyle(Theme.lightWhite)
                    Spacer()
                }
            }
            .padding()
            .background(
                ZStack(alignment: .bottom) {
                    Theme.cPurple
                    LinearGradient(colors: [Theme.base, .clear], startPoint: .bottom, endPoint: .top)
                        .blendMode(.softLight)
                        .frame(height: 40)
                }
            )
        }
    }
}

struct SidebarTitle: View {
    public var title: String
    public var description: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(self.title)
                    .font(.body)
                    .bold()
                Spacer()
            }
            HStack {
                Text(self.description)
                    .font(.caption)
                    .foregroundStyle(Theme.lightWhite)
                Spacer()
            }
        }
        .padding(8)
        .background(Theme.lightBase.blendMode(.softLight))
    }
}

struct DateInformation: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("\(self.state.date.formatted(Date.FormatStyle().weekday())), \(DateHelper.todayShort(self.state.date, format: "MMMM d"))")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                Spacer()
            }
            HStack(alignment: .top, spacing: 0) {
                Text(
                    String(
                        format: "%@.%@ %@",
                        self.state.date.formatted(Date.FormatStyle().week(.twoDigits)),
                        self.state.date.formatted(Date.FormatStyle().weekday(.oneDigit)),
                        DateHelper.todayShort(self.state.date, format: "dd.MM.YYYY")
                    )
                )
                .font(.caption)
                .fontDesign(.monospaced)
                .foregroundStyle(DateHelper.isInCurrentYear(self.state.date) ? DateHelper.isToday(self.state.date) ? .yellow : Theme.lightWhite : .gray)
            }
        }
        .padding([.leading, .trailing])
    }
}

struct Today: View {
    typealias EntityType = PageConfiguration.EntityType
    typealias PlanType = PageConfiguration.PlanType

    @EnvironmentObject private var state: AppState
    public var inSheet: Bool
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records
    @State private var jobs: [Job] = []
    @State private var isPresented: Bool = false
    @State private var path = NavigationPath()
    @State private var text: String = "" // @TODO: remove code that requires this
    @AppStorage("today.viewMode") private var viewMode: Int = 0
    @AppStorage("home.backgroundColour") public var homeBackgroundColourChoice: Int = 0
    @AppStorage("home.backgroundWallpaper") public var homeWallpaper: String = ""
    @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false
    @FocusState private var textFieldActive: Bool
    private let page: PageConfiguration.AppPage = .today

    var body: some View {
        NavigationStack(path: $path) {
            VStack(alignment: .leading, spacing: 0) {
                if !inSheet {
                    Header(page: self.page, path: $path)
                }
                ZStack(alignment: .topLeading) {
                    switch(self.viewMode) {
                    case 1:
                        ZStack(alignment: .bottomTrailing) {
                            Tabs.Content.List.HierarchyExplorer(inSheet: false)
                            Home.QuickCreateWidget()
                                .padding(.trailing)
                                .padding(.bottom, self.state.job != nil ? 16 : 0)
                        }
                    case 2:
                        Widget.ActivityCalendar(searchTerm: $text, showActivity: false)
                    case 3:
                        Tabs.Content.Posts.Records(job: self.$job, date: self.state.date, inSheet: false)
                    default:
                        main
                    }
                    GASidebar()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            // @TODO: remove weird duplicity here
            .onChange(of: self.state.job) {self.job = self.state.job}
            .onChange(of: self.job) {self.actionOnJobChange()}
            .background(
                ZStack {
                    if !self.shouldUseWPImage {
                        self.page.primaryColour
                    } else {
                        Image("wallpaper-\(self.homeWallpaper)")
                    }
                }
                .ignoresSafeArea(.all)
            )
        }
    }

    var main: some View {
        VStack(alignment: .leading, spacing: 0) {
            PageHeader(
                title: "By Entity Type",
                description: self.selected.filterDescription
            )
            ZStack(alignment: .bottomLeading) {
                Tabs(inSheet: inSheet, job: $job, selected: $selected)
                if !inSheet {
                    Home.QuickCreateWidget()
                        .padding(.trailing)
                        .padding(.bottom, self.state.job != nil ? 16 : 0)
                    if self.state.job != nil {
                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 50)
                            .opacity(0.1)
                    }
                }
            }

            if !inSheet {
                if selected == .records {
                    Editor(job: $job, entityType: $selected, focused: _textFieldActive)
                }
            }
        }
    }
}

struct PageTitle: View {
    public let text: String

    var body: some View {
        Text(self.text)
            .font(.title2)
            .padding([.leading], 10)
            .bold()
            .foregroundStyle(.white)
    }
}

extension Today {
    struct Header: View {
        @EnvironmentObject private var state: AppState
        @State public var date: Date = DateHelper.startOfDay()
        public let page: PageConfiguration.AppPage
        @Binding public var path: NavigationPath
        @State private var isCreateSheetPresented: Bool = false
        @State private var isCalendarPresented: Bool = false
        @AppStorage("today.viewMode") private var viewMode: Int = 0

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
//                HStack {
//                    Button {
//                        self.isCalendarPresented.toggle()
//                    } label: {
//                        Text("\(self.state.date.formatted(Date.FormatStyle().weekday())), \(DateHelper.todayShort(self.state.date, format: "MMMM dd"))")
//                            .font(.title)
//                            .bold()
//                    }
//                    .buttonStyle(.plain)
//                    Spacer()
//                }
//                .padding([.leading, .trailing])
                DateInformation()
                HStack(alignment: .top) {

//                    Text(DateHelper.todayShort(self.state.date, format: "dd/MM/YYYY"))
//                        .font(.caption)
//                        .fontDesign(.monospaced)
//                        .padding(.leading)
//                        .foregroundStyle(self.state.theme.tint)
                    Spacer()
                    CreateEntitiesButton(isViewModeSelectorVisible: true, isForecastVisible: false, page: self.page)
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

    struct Editor: View {
        @EnvironmentObject private var state: AppState
        public var prompt: String = "What are you working on?"
        @Binding public var job: Job?
        @Binding public var entityType: EntityType
        @FocusState public var focused: Bool
        @State private var text: String = ""
        @State private var isPersonSelectorShowing: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                if self.isPersonSelectorShowing {
                    PersonSelector(text: self.$text, isShowing: self.$isPersonSelectorShowing)
                }
                if self.state.job != nil {
                    QueryField(
                        prompt: "Add something to ~/\(self.job?.project?.company?.abbreviation ?? "404")/\(self.job?.project?.abbreviation ?? "404")/\(self.job?.titleOrId() ?? "_INVALID_JOB")",
                        onSubmit: self.actionOnSubmit,
                        text: $text
                    )
                    .focused($focused)
                }
            }
            .onChange(of: self.text) {
                if self.text.contains("@") {
                    self.isPersonSelectorShowing = true
                } else {
                    self.isPersonSelectorShowing = false
                }
            }
            .onAppear(perform: {
                self.job = self.state.job

                if self.job != nil {
                    self.focused = true
                }
            })
        }

        /// Form action
        /// - Returns: Void
        private func actionOnSubmit() -> Void {
            if !self.text.isEmpty {
                if let job = self.job {
                    let model = CoreDataRecords(moc: self.state.moc)
                    let record = model.createWithJobAndReturn(
                        job: job,
                        date: Date(),
                        text: self.text,
                        people: self.state.today.associatedEntityStorage.person
                    )

                    model.addLinks(from: self.text, record: record)
                    self.text = ""
                    self.state.today.associatedEntityStorage.clear()
                }
            }
        }

        struct PersonSelector: View {
            @EnvironmentObject private var state: AppState
            @Binding public var text: String
            @Binding public var isShowing: Bool
            @State private var allPeople: [Person] = []

            var body: some View {
                HStack(alignment: .center) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.title)
                        .foregroundStyle(.linearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom))
                        .blendMode(.overlay)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(self.allPeople.sorted(by: {$0.company?.name ?? "" < $1.company?.name ?? ""}), id: \.self) { person in
                                Button {
                                    self.actionOnTap(person)
                                } label: {
                                    Text(person.shortUsername)
                                }
                                .buttonStyle(.plain)
                                .padding(4)
                                .foregroundStyle((person.company?.backgroundColor ?? Theme.rowColour).isBright() ? Theme.base : .white)
                                .background(person.company?.backgroundColor ?? .gray)
                                .clipShape(.rect(cornerRadius: 4))
                            }
                            Spacer()
                        }
                    }
                    Button {
                        self.isShowing = false
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding(4)
                    .foregroundStyle(.linearGradient(colors: [Theme.base, Theme.cPurple], startPoint: .top, endPoint: .bottom))
                    .background(
                        ZStack(alignment: .top) {
                            self.state.theme.tint
                            LinearGradient(colors: [Theme.base, .clear], startPoint: .bottomLeading, endPoint: .topTrailing)
                                .blendMode(.softLight)
                        }
                    )
                    .buttonStyle(.plain)
                    .clipShape(.rect(cornerRadius: 4))
                }
                .padding(8)
                .background(
                    ZStack(alignment: .top) {
                        Theme.textBackground
                        LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                            .blendMode(.softLight)
                    }
                )
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.text) {
                    self.actionOnTextChange()
                }
            }
            
            /// Onload handler. Creates initial people list
            /// - Returns: Void
            private func actionOnAppear() -> Void {
                self.allPeople = CoreDataPerson(moc: self.state.moc).all()
            }
            
            /// Fires when text changes
            /// - Returns: Void
            private func actionOnTextChange() -> Void {
                self.allPeople = []

                for person in CoreDataPerson(moc: self.state.moc).all() {
                    if let name = person.name {
                        let titleCaseName = name.replacingOccurrences(of: " ", with: "")
                        let nameMatches = self.text.matches(of: /@([A-Za-z]+)/)

                        for match in nameMatches {
                            if titleCaseName.lowercased().contains(match.output.1.lowercased()) {
                                self.allPeople.append(person)
                            }
                        }
                    }
                }
            }
            
            /// Fires when you tap a suggested person
            /// - Returns: Void
            private func actionOnTap(_ person: Person) -> Void {
                self.allPeople = []
                let nameMatches = self.text.matches(of: /@([A-Za-z]+)/)

                if !nameMatches.isEmpty {
                    for match in nameMatches {
                        self.text = self.text.replacingOccurrences(of: match.output.1, with: person.shortUsername)
                    }
                } else {
                    self.text = self.text.replacingOccurrences(of: "@", with: person.shortUsername)
                }

                self.state.today.associatedEntityStorage.person.append(person)
                self.isShowing = false
            }
        }
    }
}

extension Today {
    /// Handler for callback when self.job changes value
    /// - Returns: Void
    private func actionOnJobChange() -> Void {
        if self.job != nil {
            self.textFieldActive = true
        }
    }
}

extension Today.Header {
    /// Callback that fires when the CreateSheet disappears
    /// - Returns: Void
    private func actionOnCreateSheetDismissed() -> Void {
        DefaultObjects.deleteDefaultJobs()
    }
}

struct DatePickerDateAwareTitle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .center, spacing: 0) {
            Label(configuration)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding([.leading, .top, .bottom])
        }
    }
}
