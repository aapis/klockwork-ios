//
//  OverviewWidget.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct OverviewWidget: View {
    public var assessment: Assessment
    @State private var active: [AssessmentFactor] = []
    @State private var score: Int = 0
    @State private var weight: ActivityWeight = .empty
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
                            AssessmentTypeIntersitial(assessment: assessment)
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
                                weight.colour
                                Text(String(score))
                                    .font(.system(size: 50))
                                    .fontWeight(.bold)
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
        .onAppear(perform: {
            assessment.assessables.evaluate()
            active = assessment.assessables.active()
            score = assessment.assessables.score
            weight = assessment.assessables.weight
        })
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
