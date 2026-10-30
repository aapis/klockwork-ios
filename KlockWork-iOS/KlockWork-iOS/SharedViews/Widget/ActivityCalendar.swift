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
        @State public var month: String = "_DEFAULT_MONTH"
        @State private var date: Date = Date()
        @State private var legendId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
        @State private var calendarId: UUID = UUID() // @TODO: remove this gross hack once views refresh properly
        public var weekdays: [DayOfWeek] = [
            DayOfWeek(symbol: "Sun"),
            DayOfWeek(symbol: "Mon"),
            DayOfWeek(symbol: "Tues"),
            DayOfWeek(symbol: "Wed"),
            DayOfWeek(symbol: "Thurs"),
            DayOfWeek(symbol: "Fri"),
            DayOfWeek(symbol: "Sat")
        ]
        public var columns: [GridItem] {
            return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
        }

        var body: some View {
            NavigationStack {
                VStack {
                    Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                        MonthNav(date: $date)

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

                            Spacer() // @TODO: put a new set of stats or something here?
                        }
                        .background(Theme.rowColour)

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
                .background(Theme.cGreen)
                .toolbarBackground(.visible, for: .navigationBar)
                .scrollDismissesKeyboard(.immediately)
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.date) { self.actionChangeDate()}
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
            @State private var isCurrentMonth: Bool = false // @TODO: implement

            var body: some View {
                GridRow {
                    HStack {
                        MonthNavButton(orientation: .leading, date: $date)
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
                        MonthNavButton(orientation: .trailing, date: $date)
                    }
                }
                .border(width: 1, edges: [.bottom], color: .gray)
                .background(Theme.cGreen)
            }
        }

        struct MonthNavButton: View {
            @EnvironmentObject private var state: AppState
            public var orientation: UnitPoint
            @Binding public var date: Date
            @State private var previousMonth: String = ""
            @State private var nextMonth: String = ""

            var body: some View {
                HStack {
                    ZStack {
                        LinearGradient(gradient: Gradient(colors: [Theme.textBackground, Theme.cGreen]), startPoint: self.orientation, endPoint: self.orientation == .leading ? .trailing : .leading)
                        Button {
                            self.actionOnTap()
                        } label: {
                            HStack {
                                Image(systemName: self.orientation == .leading ? "chevron.left" : "chevron.right")
                            }
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 12)
                            .background(Theme.cPurple)
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
