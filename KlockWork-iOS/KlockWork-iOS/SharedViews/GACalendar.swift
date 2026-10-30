//
//  GACalendar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-29.
//
import SwiftUI

struct GACalendar: View {
    @EnvironmentObject private var state: AppState
    @State private var days: [Day] = []
    @State private var isMinimized: Bool = false
    private var columns: [GridItem] {
        return Array(repeating: .init(.flexible()), count: 7)
    }
    @AppStorage("home.isWriting") public var isWriting: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LazyVGrid(columns: self.columns, alignment: .center) {
                ForEach(self.days) { day in day }
            }
            .frame(minHeight: 100, idealHeight: 300, maxHeight: 300)
        }
        .padding(8)
        .background(
            ZStack {
                Theme.cPurple
                LinearGradient(colors: [Theme.lightWhite, .clear], startPoint: .top, endPoint: .bottom)
                    .blendMode(.softLight)
                    .opacity(0.6)
            }
        )
        .clipShape(.rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Theme.lightWhite, lineWidth: 1)
                .blendMode(.softLight)
        }
        .padding([.leading, .trailing], 8)
        .padding([.bottom, .top], 12)
        .background(
            ZStack(alignment: .top) {
                Theme.cPurple
                VStack {
                    LinearGradient(colors: [Theme.base, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 20)
                        .blendMode(.softLight)
                    Spacer()
                    LinearGradient(colors: [.clear, Theme.base], startPoint: .top, endPoint: .bottom)
                        .frame(height: 20)
                        .blendMode(.softLight)
                }
            }
        )
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.date) {
            self.actionOnAppear()
        }
        .onChange(of: self.isWriting) {
            self.isMinimized = self.isWriting
        }
        .swipe([.left, .right]) { swipe in
            if !self.isWriting {
                if swipe == .left {
                    self.state.date += (86400 * 30)
                } else if swipe == .right {
                    self.state.date -= (86400 * 30)
                }
            }
        }
        .onTapGesture(count: 2) {
            self.isMinimized.toggle()
        }
    }

    /// Fires onload. Sets view state
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.days = []
        self.state.calendar.selected = self.state.date

//        if self.isWriting {
//            self.isMinimized = true
//        }

        if let startOfMonth = self.state.date.startOfMonth {
            if let endOfMonth = self.state.date.endOfMonth {
                let calendar = SwiftUI.Calendar.autoupdatingCurrent
                let firstDayComponents = calendar.dateComponents([.weekday], from: startOfMonth)
                let eom = calendar.dateComponents([.day], from: endOfMonth)
                if let lastDayOfMonth = eom.day {
                    let days = (0...(lastDayOfMonth - 1)).map { // always prints 1 Day too many unless we do this
                        calendar.date(byAdding: .day, value: $0, to: startOfMonth)
                    }

                    // Add day of week markers
                    for day in ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"] {
                        self.days.append(Day(title: day))
                    }

                    // Add empty day spots to put the days in the right order
                    if let ordinal = firstDayComponents.weekday {
                        if (ordinal - 2) > 0 { // still unsure why these need to be -2
                            for _ in 0...(ordinal - 2) {
                                self.days.append(Day())
                            }
                        }
                    }

                    // Add regular days
                    for day in days {
                        self.days.append(Day(date: day))
                    }
                }
            }
        }
    }

    // MARK: Feed.UI.ControlPanel.Calendar.Day
    // @TODO: this SUUUCKS, too many if statements controlling styling, redo it
    struct Day: View, Identifiable {
        @EnvironmentObject private var state: AppState
        public var id: UUID =  UUID()
        public var date: Date? = nil
        public var title: String? = nil

        var body: some View {
            ZStack {
                (((DateHelper.isToday(self.date ?? Date.now) || SwiftUI.Calendar.autoupdatingCurrent.isDate(self.state.calendar.selected, inSameDayAs: self.date ?? Date.now)) && self.title == nil && self.date != nil) ? Color.yellow : .clear)
                if self.title != nil {
                    Text(self.title!)
                        .foregroundStyle(DateHelper.todayShort(self.state.calendar.selected, format: "EEE") == self.title! ? .yellow : Theme.lightWhite)
                        .bold(DateHelper.todayShort(self.state.calendar.selected, format: "EEE") == self.title!)
                        .shadow(radius: 3)
                } else if self.date == nil {
                    Text("")
                } else {
                    Button {
                        self.state.date = self.date!
                        self.state.calendar.selected = self.state.date
                    } label: {
                        Text(DateHelper.todayShort(self.date!, format: "d"))
                    }
                    .padding([.bottom, .top], 8)
                    .foregroundStyle(DateHelper.isToday(self.date!) || SwiftUI.Calendar.autoupdatingCurrent.isDate(self.state.calendar.selected, inSameDayAs: self.date ?? Date.now) && self.title == nil && self.date != nil ? Theme.slate : .white)
                    .opacity(self.date! < (Date.now + 600) ? 0.4 : 1)
                    .shadow(radius: 3)
                }
            }
            .mask {
                (self.title == nil && self.date != nil ? RoundedRectangle(cornerRadius: 50) : RoundedRectangle(cornerRadius: 0))
            }
        }
    }
}
