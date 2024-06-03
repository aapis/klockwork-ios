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

struct IdentifiableMonth: Identifiable {
    var id: UUID = UUID()
    var name: String
}

struct ActivityCalendar: View {
    @Binding public var date: Date
    @Binding public var searchTerm: String
    @Environment(\.managedObjectContext) var moc
    @State public var month: String = "_DEFAULT_MONTH"
    @State public var week: Int = 0
    @State public var days: [Day] = []
    @State public var open: Bool = true
    @State public var cumulativeScore: Int = 0
    public var weekdays: [DayOfWeek] = [
        DayOfWeek(symbol: "Sun"),
        DayOfWeek(symbol: "Mon"),
        DayOfWeek(symbol: "Tues"),
        DayOfWeek(symbol: "Wed"),
        DayOfWeek(symbol: "Thurs"),
        DayOfWeek(symbol: "Fri"),
        DayOfWeek(symbol: "Sat")
    ]
    public var months: [IdentifiableMonth] = [
        IdentifiableMonth(name: "Jan"),
        IdentifiableMonth(name: "Feb"),
        IdentifiableMonth(name: "Mar"),
        IdentifiableMonth(name: "Apr"),
        IdentifiableMonth(name: "May"),
        IdentifiableMonth(name: "Jun"),
        IdentifiableMonth(name: "Jul"),
        IdentifiableMonth(name: "Aug"),
        IdentifiableMonth(name: "Sep"),
        IdentifiableMonth(name: "Oct"),
        IdentifiableMonth(name: "Nov"),
        IdentifiableMonth(name: "Dec")
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
                        .overlay {
                            DatePicker(
                                "Date picker",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .contentShape(Rectangle())
                            .opacity(0.011)
                        }

                        Button {
                            CDAssessmentFactor(moc: self.moc).delete()
                            self.date = Date()
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
                Month(date: $date, cumulativeScore: $cumulativeScore, searchTerm: searchTerm)
                    .environment(\.managedObjectContext, moc)
                    .background(Theme.rowColour)

                // Legend
                Legend()
                    .border(width: 1, edges: [.top], color: .gray.opacity(0.7))
            }
        }
        .background(Theme.cGreen)
        .onAppear(perform: actionOnAppear)
        .onChange(of: self.date) { self.actionOnAppear()}
        // @TODO: swipe between months
//                .swipe([.left, .right]) { swipe in
//                    if swipe == .left {
//
//                    } else if swipe == .right {
//
//                    }
//                }
    }
}

extension ActivityCalendar {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        // Get month string from date
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.date)
        print("DERPO date changed to \(self.date)")
        // @TODO: create assessment for the day here
        
    }
}
