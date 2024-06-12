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
        @State public var month: String = "_DEFAULT_MONTH"
        @State public var open: Bool = true
        @State public var cumulativeScore: Int = 0
        @State private var date: Date = Date()
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
            Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 0) {
                GridRow(alignment: .center) {
                    Button {
                        self.open.toggle()
                    } label: {
                        HStack {
                            Text("Activity Calendar")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            Image(systemName: self.open ? "minus" : "plus")
                        }
                        .padding()
                        .background(Theme.rowColour)
                    }
                }
                .clipShape(
                    .rect(
                        topLeadingRadius: 16,
                        bottomLeadingRadius: self.open ? 0 : 16,
                        bottomTrailingRadius: self.open ? 0 : 16,
                        topTrailingRadius: 16
                    )
                )

                if self.open {
                    // Month row
                    GridRow {
                        HStack {
                            HStack {
                                Text(self.month)
                                Image(systemName: "chevron.right")
                            }
                            .foregroundStyle(.yellow)
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 8)
                            .background(Theme.rowColour)
                            .mask(Capsule(style: .continuous))
                            .overlay { // @TODO: only this date selector doesn't is broken in iOS 18 - bug?
                                DatePicker(
                                    "Date picker",
                                    selection: $date,
                                    displayedComponents: [.date]
                                )
                                .labelsHidden()
//                                .background(.red)
                                .opacity(0.011)
                            }

                            Button {
                                self.state.date = Date()
                            } label: {
                                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                    .font(.title2)
                            }

                            Spacer()

                            Text("Score: \(self.cumulativeScore)")
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom], 8)
                                .background(Theme.rowColour)
                                .foregroundStyle(.gray)
                                .mask(Capsule(style: .continuous))
                        }
                        .padding()
                    }
                    .border(width: 1, edges: [.bottom], color: Theme.cGreen)
                    .background(Theme.rowColour)

                    // Day of week
                    GridRow {
                        ZStack(alignment: .bottomLeading) {
                            LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .bottom)
                                .frame(height: 50)
                                .opacity(0.05)
                            LazyVGrid(columns: self.columns, alignment: .center) {
                                ForEach(weekdays) {sym in
                                    Text(sym.symbol)
                                        .foregroundStyle(sym.current ? .yellow : .white)
                                }
                                .font(.caption)
                            }
                            .padding([.leading, .trailing, .top])
                            .padding(.bottom, 5)
                        }
                    }
                    .background(Theme.rowColour)

                    // List of days representing 1 month
                    Month(month: $month, searchTerm: searchTerm)
                        .background(Theme.rowColour)

                    // Legend
                    Legend()
                        .border(width: 1, edges: [.top], color: .gray.opacity(0.7))
                }
            }
            .background(Theme.cGreen)
            .onAppear(perform: actionOnAppear)
            .onChange(of: self.state.date) { self.actionChangeDate()}
            // @TODO: swipe between months
//            .swipe([.left, .right]) { swipe in
//                if swipe == .left {
//
//                } else if swipe == .right {
//
//                }
//            }
        }
    }
}

extension Widget.ActivityCalendar {
    /// Get month string from date
    /// - Returns: Void
    private func actionChangeDate() -> Void {
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.state.date)
        self.date = self.state.date // Used by DatePicker
        print("DERPO date set \(self.date)")
    }
    
    /// Onload handler, creates assessment statuses (if required)
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.actionChangeDate()
    }

    /// <#Description#>
    /// - Returns: <#description#>
    private func redraw() -> Void {
        
    }
}
