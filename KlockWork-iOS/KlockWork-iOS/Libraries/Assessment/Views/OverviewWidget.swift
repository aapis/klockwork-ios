//
//  OverviewWidget.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct OverviewWidget: View {
    @EnvironmentObject private var state: AppState
    public var assessment: Assessment
    @State private var active: [AssessmentFactor] = []
    @State private var score: Int = 0
    @State private var weight: ActivityWeight = .empty
    @State private var scoreBackgroundColour: Color = .clear
    @State private var scoreForegroundColour: Color = .white
    private let scoreDiameter: CGFloat = 100

    var body: some View {
        VStack {
            Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                GridRow(alignment: .top) {
                    HStack {
                        Text("Assessment")
                            .foregroundStyle(self.state.theme.tint)
                        Spacer()

                        NavigationLink {
                            AssessmentTypeMenu(assessment: assessment)
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "gear")
                            }
                        }
                        .foregroundStyle(self.state.theme.tint)
                        .help("Modify assessment factors")
                    }
                    .padding([.leading, .trailing])
                }
            }
            Grid(alignment: .topLeading, horizontalSpacing: 5, verticalSpacing: 5) {
                if score == 0 {
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
                                self.scoreBackgroundColour
                                Text(String(self.score))
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
                                    .foregroundStyle(self.scoreForegroundColour)
                            }
                            .frame(width: self.scoreDiameter, height: self.scoreDiameter)
                            .mask(Circle())

                            Text(weight.label)
                                .foregroundStyle(.gray)
                        }
                        .padding([.leading, .trailing, .top], 10)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(active) { factor in
                                FactorDescription(factor: factor)
                            }
                        }
                        .padding([.top], 10)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(active) { factor in
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
        .onAppear(perform: self.actionOnAppear)
    }
}

extension OverviewWidget {
    struct FactorDescription: View {
        @State public var factor: AssessmentFactor

        var body: some View {
            HStack(alignment: .center, spacing: 5) {
                Text(factor.factorDescription().uppercased())
                Spacer()
            }
            .font(.caption)
        }
    }

    struct FactorCalculation: View {
        public var factor: AssessmentFactor
        @State private var weighting: Int64 = 0

        var body: some View {
            HStack(spacing: 2) {
                Image(systemName: "plus")
                Text(String(weighting))
            }
            .font(.caption)
            .onAppear(perform: {
                weighting = factor.count * factor.weight
            })
        }
    }
}

extension OverviewWidget {
    /// Onload handler, evaluates the day given the factors, statuses and other components it has received
    /// - Returns: Void
    public func actionOnAppear() -> Void {
        assessment.assessables.evaluate()
        self.active = assessment.assessables.active()
        self.score = assessment.assessables.score
        self.weight = assessment.assessables.weight

        if let newWeight = assessment.statuses.first(where: {$0.label == weight.label}) {
            if let stored = newWeight.colour {
                self.scoreBackgroundColour = Color.fromStored(stored)
                self.scoreForegroundColour = self.scoreBackgroundColour.isBright() ? Theme.cGreen : .white
            }
        }
    }
}
