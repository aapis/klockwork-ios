//
//  ActivityCalendar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI

struct DayOfWeek: Identifiable {
    let id: UUID = UUID()
    let symbol: String
    var current: Bool {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        let symbol = df.string(from: Date())

        return self.symbol == symbol
    }
}

extension Widget {
    struct ActivityCalendar: View {
        @EnvironmentObject private var state: AppState
        @Binding public var searchTerm: String
        public var showActivity: Bool = true
        public var showRecords: Bool = true
        public var inSheet: Bool = false
        public var page: PageConfiguration.AppPage = .explore
        @State public var month: String = "_DEFAULT_MONTH"
        @State private var job: Job? = nil // @TODO: remove the code that requires this
        @State private var date: Date = Date()
        @State private var legendId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
        @State private var calendarId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
        @State private var selected: PageConfiguration.EntityType = .records
        private let weekdays: [DayOfWeek] = [
            DayOfWeek(symbol: "Sun"),
            DayOfWeek(symbol: "Mon"),
            DayOfWeek(symbol: "Tues"),
            DayOfWeek(symbol: "Wed"),
            DayOfWeek(symbol: "Thurs"),
            DayOfWeek(symbol: "Fri"),
            DayOfWeek(symbol: "Sat")
        ]
        private var columns: [GridItem] {
            return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
        }
        @AppStorage("home.backgroundWallpaper") private var homeWallpaper: String = ""
        @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false
        @AppStorage("today.viewMode") private var viewMode: Int = 0

        var body: some View {
            NavigationStack {
                VStack {
                    Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                        MonthNav(date: $date, page: self.page)

                        // Day of week
                        GridRow {
                            ZStack(alignment: .bottomLeading) {
                                LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 50)
                                    .opacity(0.05)
                                LazyVGrid(columns: self.columns, alignment: .center) {
                                    ForEach(weekdays) {sym in
                                        Text(sym.symbol)
                                            .foregroundStyle(sym.current ? self.state.theme.tint : .white)
                                    }
                                    .font(.caption)
                                }
                                .padding([.leading, .trailing, .top])
                                .padding(.bottom, 5)
                            }
                        }
                        .background(Theme.rowColour)
                        
                        VStack {
                            // List of days representing 1 month
                            Month(month: $month, id: $calendarId, searchTerm: searchTerm, showActivity: self.showActivity)
                                .id(self.calendarId)
                            Spacer()
                        }
                        .background(Theme.rowColour)

                        if self.showRecords {
                            MiniTitleBarCustom(title: "QUICK LOOK")
                            VStack(alignment: .leading, spacing: 4) {
                                Home.RecordBlock(
                                    colour: .indigo,
                                    fgColour: Theme.base,
                                    label: "Records \(DateHelper.todayShort(DateHelper.daysAhead(-14, from: self.state.date), format: "MMM dd")) - \(DateHelper.todayShort(self.state.date, format: "MMM dd"))",
                                    icon: "tray.circle.fill",
                                    predicate: NSPredicate(
                                        format: "timestamp > %@ && timestamp <= %@",
                                        DateHelper.daysAhead(-14, from: self.state.date) as CVarArg,
                                        DateHelper.endOfDay(self.state.date)! as CVarArg
                                    ),
                                    infoView: AnyView(Home.DetailedInformation()),
                                    des: 1,
                                    help: "Published only"
                                )
                                Home.TaskBlock(
                                    colour: .indigo,
                                    fgColour: Theme.base,
                                    label: "Tasks \(DateHelper.todayShort(DateHelper.daysAhead(-14, from: self.state.date), format: "MMM dd")) - \(DateHelper.todayShort(self.state.date, format: "MMM dd"))",
                                    icon: "checkmark.circle.fill",
                                    predicate: NSPredicate(
                                        format: "((due > %@ && due <= %@) || (completedDate > %@ && completedDate <= %@)) && owner.project.company.hidden == false",
                                        DateHelper.daysAhead(-14, from: self.state.date) as CVarArg,
                                        DateHelper.endOfDay(self.state.date)! as CVarArg,
                                        DateHelper.daysAhead(-14, from: self.state.date) as CVarArg,
                                        DateHelper.endOfDay(self.state.date)! as CVarArg
                                    ),
                                    infoView: AnyView(Home.DetailedInformation()),
                                    des: 1,
                                    help: "All statuses"
                                )
                            }
                            .padding()
                        }

                        if self.showActivity {
                            // Legend
                            Legend(id: $legendId, calendarId: $calendarId)
                                .border(width: 1, edges: [.top], color: .gray.opacity(0.7))
                                .id(self.legendId)
                        }
                    }
                    Spacer()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(self.inSheet ? .visible : .hidden)
                .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollDismissesKeyboard(.immediately)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.date) {
                    self.actionChangeDate()
                    // Resets view mode to tabular
//                    self.viewMode = 2
                }
                .navigationTitle("Activity Calendar")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            self.state.date = DateHelper.startOfDay()
                            self.date = self.state.date
                        } label: {
                            Image(systemName: "clock.arrow.circlepath")
                        }
                    }
                }
                .swipe([.left, .right]) { swipe in
                    self.actionOnSwipe(swipe)
                }
            }
        }

        struct MonthNav: View {
            @EnvironmentObject private var state: AppState
            @Binding public var date: Date
            public var page: PageConfiguration.AppPage = .explore
            @State private var isCurrentMonth: Bool = false // @TODO: implement
            @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false

            var body: some View {
                GridRow {
                    HStack {
                        MonthNavButton(orientation: .leading, page: self.page, date: $date)
                        Spacer()

                        DatePicker(
                            "Date picker",
                            selection: $date,
                            displayedComponents: [.date]
                        )
                        .background(self.isCurrentMonth ? self.state.theme.tint : Theme.rowColour)
                        .labelsHidden()
                        .mask(Capsule(style: .continuous))
                        .foregroundStyle(self.isCurrentMonth ? Theme.cGreen : .gray)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 12)
                        .shadow(color: .white.opacity(0.1), radius: 7, x: 0, y: 0)
                        Spacer()
                        MonthNavButton(orientation: .trailing, page: self.page, date: $date)
                    }
                }
                .border(width: 1, edges: [.bottom], color: .gray)
                .background(self.shouldUseWPImage ? Theme.textBackground : self.page.primaryColour)
            }
        }

        struct MonthNavButton: View {
            @EnvironmentObject private var state: AppState
            public var orientation: UnitPoint
            public var page: PageConfiguration.AppPage = .explore
            @Binding public var date: Date
            @State private var previousMonth: String = ""
            @State private var nextMonth: String = ""
            @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false

            var body: some View {
                HStack {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [self.shouldUseWPImage ? .clear : Theme.textBackground, self.shouldUseWPImage ? .clear : Theme.cGreen]), startPoint: self.orientation, endPoint: self.orientation == .leading ? .trailing : .leading)
                        Button {
                            self.actionOnTap()
                        } label: {
                            HStack {
                                Image(systemName: self.orientation == .leading ? "chevron.left" : "chevron.right")
                            }
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 12)
                            .background(self.page.primaryColour)
                        }
                        .clipShape(.capsule(style: .continuous))
                        .shadow(color: .black.opacity(0.2), radius: 2, x: 1, y: 1)
                    }
                }
                .frame(width: 80, height: 75)
            }
            
            /// Navigate between months by tapping on the button
            /// @TODO: shared functionality with ActivityCalendar.actionOnSwipe, refactor!
            /// - Returns: Void
            private func actionOnTap() -> Void {
                let oneMonthMs: Double = 2592000

                if self.orientation == .leading {
                    self.date = self.state.date - oneMonthMs
                } else {
                    self.date = self.state.date + oneMonthMs
                }
            }
        }
    }
}

extension Widget.ActivityCalendar {
    /// Get month string from date
    /// - Returns: Void
    private func actionChangeDate() -> Void {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.date)
        self.state.date = DateHelper.startOfDay(self.date)
    }
    
    /// Onload handler. Used by DatePicker, should be AppState.date by default
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.date = self.state.date
    }
    
    /// Navigate between months using swipe gestures
    /// @TODO: shared functionality with MonthNavButton.actionOnTap, refactor!
    /// - Parameter swipe: Swipe
    /// - Returns: Void
    public func actionOnSwipe(_ swipe: Swipe) -> Void {
        let oneMonthMs: Double = 2592000

        if swipe == .right {
            self.date = self.state.date - oneMonthMs
        } else {
            self.date = self.state.date + oneMonthMs
        }
    }
}
