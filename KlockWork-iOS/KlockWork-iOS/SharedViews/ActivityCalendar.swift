//
//  ActivityCalendar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI

// MARK: Definition
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
    public var months: [Month] = [
        Month(name: "Jan"),
        Month(name: "Feb"),
        Month(name: "Mar"),
        Month(name: "Apr"),
        Month(name: "May"),
        Month(name: "Jun"),
        Month(name: "Jul"),
        Month(name: "Aug"),
        Month(name: "Sep"),
        Month(name: "Oct"),
        Month(name: "Nov"),
        Month(name: "Dec")
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
                            }
                            .font(.caption)
                        }
                        .padding([.leading, .trailing, .top])
                        .padding(.bottom, 5)
                    }
                }
                .background(Theme.rowColour)


                // Days
                ActivityAssessment.ViewFactory.Month(date: $date, cumulativeScore: $cumulativeScore, searchTerm: searchTerm)
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

// MARK: Method definitions
extension ActivityCalendar {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        // Get month string from date
        let df = DateFormatter()
        df.dateFormat = "MMM"
        self.month = df.string(from: self.date)
    }
}

extension ActivityCalendar.Day {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if assessment != nil {
            if isToday {
                bgColour = .blue
            } else {
                if isWeekend! {
                    // IF we worked on the weekend, highlight the tile in red (this is bad and should be highlighted)
                    if ![.empty].contains(assessment!.weight) {
                        bgColour = .red
                    } else {
                        bgColour = .clear
                    }
                } else {
                    bgColour = assessment!.weight.colour
                }

            }
        }
    }
}

extension ActivityCalendar.AssessmentsPanel {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if let ass = self.assessment {
            assessmentDate = ass.date
        }
    }
}

// MARK: Data structures
extension ActivityCalendar {
    /// An individual calendar day "tile"
    public struct Day: View, Identifiable {
        public let id: UUID = UUID()
        public let day: Int
        public let isToday: Bool
        public var isWeekend: Bool? = false
        public var assessment: ActivityAssessment?
        @State private var bgColour: Color = .clear
        @State private var isPresented: Bool = false
        private let gridSize: CGFloat = 40

        var body: some View {
            Button {
                isPresented.toggle()
            } label: {
                if self.day > 0 {
                    Text(String(self.day))
                }
            }
            .frame(minWidth: self.gridSize, minHeight: self.gridSize)
            .background(self.bgColour)
            .clipShape(.rect(cornerRadius: 6))
            .onAppear(perform: actionOnAppear)
            .sheet(isPresented: $isPresented) {
                AssessmentsPanel(assessment: assessment)
            }
        }
    }

    struct DayOfWeek: Identifiable {
        let id: UUID = UUID()
        let symbol: String
    }

    struct Month: Identifiable {
        var id: UUID = UUID()
        var name: String
    }

    public struct AssessmentsPanel: View {
        public let assessment: ActivityAssessment?
        @State private var assessmentDate: Date = Date()

        var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 20) {
                    if let ass = assessment {
                        VStack(alignment: .leading, spacing: 0) {
                            Divider().background(.gray).frame(height: 1)
                            ZStack(alignment: .topLeading) {
                                AssessmentOverviewWidget(assessment: ass)
                                    .navigationTitle(ass.date.formatted(date: .abbreviated, time: .omitted))
                                    .toolbarTitleDisplayMode(.inline)
                                    .toolbar {
                                        NavigationLink {
                                            Today(inSheet: true, date: $assessmentDate)
                                        } label: {
                                            HStack(alignment: .top, spacing: 5) {
                                                Text("Details")
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    }
                                    .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                                    .toolbarBackground(.visible, for: .navigationBar)

                                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 50)
                                    .opacity(0.1)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .onAppear(perform: self.actionOnAppear)
            .presentationDetents([.medium, .large])
            .presentationBackground(Theme.cGreen)
            .scrollDismissesKeyboard(.immediately)
        }
    }

    struct AssessmentOverviewWidget: View {
        public let assessment: ActivityAssessment
        private let scoreDiameter: CGFloat = 100

        var body: some View {
            VStack {
                Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                    GridRow(alignment: .top) {
                        HStack {
                            Text("Assessment")
                                .foregroundStyle(.yellow)
                            Spacer()

                            NavigationLink {
                                AssessmentFactorForm(assessment: self.assessment)
                                    .toolbarTitleDisplayMode(.inline)
                            } label: {
                                HStack {
                                    Spacer()
                                    Image(systemName: "gear")
                                }
                            }
                            .foregroundStyle(.yellow)
                            .help("Modify assessment factors")
                        }
                        .padding([.leading, .trailing])
                    }
                }
                Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 5) {
                    if assessment.score == 0 {
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text("No activity recorded")
                                Spacer()
                            }
                        }
                    } else {
                        GridRow(alignment: .top) {
                            Text("Score")
                            Text("Factors")
                            Image(systemName: "plusminus")
                        }
                        .foregroundStyle(.gray)

                        Divider()
                            .background(.gray)

                        GridRow(alignment: .top) {
                            VStack(alignment: .center) {
                                ZStack {
                                    assessment.weight.colour
                                    Text(String(assessment.score))
                                        .font(.system(size: 50))
                                        .fontWeight(.bold)
                                }
                                .frame(width: self.scoreDiameter, height: self.scoreDiameter)
                                .mask(Circle())

                                Text(assessment.weight.label)
                                    .foregroundStyle(.gray)
                            }
                            .padding([.leading, .trailing, .top], 10)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(assessment.assessables.active()) { factor in
                                    FactorDescription(factor: factor)
                                }
                            }
                            .padding([.top], 10)

                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(assessment.assessables.active()) { factor in
                                    FactorCalculation(factor: factor)
                                }
                            }
                            .padding([.top], 10)
                        }
                    }
                }
                .padding()
                .background(Theme.textBackground)
                .clipShape(.rect(cornerRadius: 16))
            }
            .padding()
        }
    }

    struct Legend: View {
        private var columns: [GridItem] {
            return Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
        }

        var body: some View {
            GridRow {
                VStack(alignment: .leading) {
                    GridRow {
                        Text("Legend")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.gray)
                    }
                    LazyVGrid(columns: columns, alignment: .leading) {
                        ForEach(ActivityAssessment.ActivityWeightAssessment.allCases, id: \.self) { assessment in
                            Legend.Row(assessment: assessment)
                        }
                    }
                }
            }
            .padding()
            .background(Theme.textBackground)
        }
    }
}

extension ActivityCalendar.Legend {
    struct Row: View {
        public let assessment: ActivityAssessment.ActivityWeightAssessment

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(assessment.colour)
                        .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: .gray)

                    Text(assessment.label)
                        .font(.caption)
                }
            }
        }
    }
}

extension ActivityCalendar.AssessmentOverviewWidget {
    struct FactorDescription: View {
        public let factor: AssessmentFactor

        var body: some View {
            HStack(alignment: .center, spacing: 5) {
                Text(factor.desc!.uppercased())
                Spacer()

            }
            .font(.caption)
        }
    }

    struct FactorCalculation: View {
        public let factor: AssessmentFactor

        var body: some View {
            HStack(spacing: 2) {
                Image(systemName: "plus")
                Text("\(factor.count * factor.weight)")
            }
            .font(.caption)
        }
    }
}

