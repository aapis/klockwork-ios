//
//  TaskForecast.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-12.
//

import SwiftUI

struct TaskForecast: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) var colourScheme

    public var callback: (() -> Void)? = nil
    public var daysToShow: Double = 14
    @State private var forecast: [Forecast] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: 0) {
                    ForEach(self.forecast, id: \.id) { row in row }
                }
            }
            .background(.black.opacity(0.6))
        }
        .onAppear(perform: self.actionOnAppear)
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.forecast = []
        let dates = Date()..<DateHelper.daysAhead(self.daysToShow)
        let hrs24: TimeInterval = 60*60*24

        for date in stride(from: dates.lowerBound, to: dates.upperBound, by: hrs24) {
            self.forecast.append(
                Forecast(date: date, callback: self.callback)
            )
        }
    }
}

struct Forecast: View, Identifiable {
    @EnvironmentObject private var state: AppState
    @Environment(\.colorScheme) var colourScheme

    var id: UUID = UUID()
    var date: Date
    public var callback: (() -> Void)? = nil
    public var isForecastMember: Bool = true
    @State public var itemsDue: Int = 0
    @State private var dateStrip: String = ""
    @State private var dateStripMonth: String = ""
    @State private var dateStripDay: String = ""
    @State private var isSelected: Bool = false
    @FetchRequest private var upcomingTasks: FetchedResults<LogTask>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.isForecastMember {
                VStack(alignment: .center, spacing: 1) {
                    Text(self.dateStrip)
                        .multilineTextAlignment(.leading)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(self.isSelected ? self.state.theme.tint : .white)
                        .opacity(self.itemsDue == 0 ? 0.4 : 1)

                    Button {
                        self.state.date = self.date

                        if self.isSelected {
                            if let cb = self.callback { cb() }
                        }
                    } label: {
                        ZStack {
                            VStack(alignment: .center, spacing: 0) {
                                if self.upcomingTasks.count > 0 {
                                    ForEach(self.upcomingTasks) { task in
                                        Rectangle()
                                            .foregroundStyle(task.owner?.backgroundColor ?? Theme.rowColour)
                                    }
                                } else {
                                    Color.green
                                }
                            }
                            .mask(Circle().frame(width: 35))

                            Theme.base
                                .mask(Circle().frame(width: 25))

                            Text(String(self.itemsDue))
                                .multilineTextAlignment(.leading)
                                .font(.system(.headline, design: .monospaced))
                                .bold()
                                .foregroundStyle(.white)
                        }
                        .frame(width: 50, height: 50)
                    }
                    .opacity(self.itemsDue == 0 ? 0.4 : 1)
                }
            } else {
                HStack(alignment: .center, spacing: 8) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(self.dateStripMonth)
                            .multilineTextAlignment(.leading)
                        Divider()
                            .background(self.state.theme.tint)
                            .frame(width: 15)
                        Text(self.dateStripDay)
                            .multilineTextAlignment(.leading)
                    }
                    .font(.system(.callout, design: .monospaced))
                    .foregroundStyle(self.isSelected ? self.state.theme.tint : .white)

                    Button {
                        self.state.date = self.date

                        if self.isSelected {
                            if let cb = self.callback { cb() }
                        }
                    } label: {
                        ZStack {
                            VStack(alignment: .center, spacing: 0) {
                                if self.upcomingTasks.count > 0 {
                                    ForEach(self.upcomingTasks) { task in
                                        Rectangle()
                                            .foregroundStyle(task.owner?.backgroundColor ?? Theme.rowColour)
                                    }
                                } else {
                                    Color.green
                                }
                            }
                            .mask(Circle().frame(width: 35))

                            Theme.base
                                .mask(Circle().frame(width: 25))

                            Text(String(self.itemsDue))
                                .multilineTextAlignment(.leading)
                                .font(.system(.headline, design: .monospaced))
                                .bold()
                                .foregroundStyle(self.itemsDue == 0 ? .gray : .white)
                        }
                    }
                }
                .frame(width: 70, height: 35)
//                .opacity(self.itemsDue == 0 ? 0.4 : 1)
            }
        }
        .padding(8)
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.state.date) {
            self.actionOnAppear()
        }
    }

    init(date: Date, callback: (() -> Void)? = nil, isForecastMember: Bool = true) {
        self.date = date
        self.callback = callback
        self.isForecastMember = isForecastMember

        _upcomingTasks = CoreDataTasks.fetchDue(on: date)
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.itemsDue = self.upcomingTasks.count

        let df = DateFormatter()
        df.dateFormat = "MM-dd"
        df.timeZone = TimeZone.autoupdatingCurrent
        df.locale = NSLocale.current

        let df1 = DateFormatter()
        df1.dateFormat = "MM"
        df1.timeZone = TimeZone.autoupdatingCurrent
        df1.locale = NSLocale.current

        let df2 = DateFormatter()
        df2.dateFormat = "dd"
        df2.timeZone = TimeZone.autoupdatingCurrent
        df2.locale = NSLocale.current
        
        self.dateStripMonth = df1.string(from: self.date)
        self.dateStripDay = df2.string(from: self.date)
        self.dateStrip = df.string(from: self.date)
        let fSelected = df.string(from: self.state.date)
        self.isSelected = self.dateStrip == fSelected
    }
}
