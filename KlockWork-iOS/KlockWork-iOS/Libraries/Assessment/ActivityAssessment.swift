//
//  ActivityAssessment.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-28.
//

import SwiftUI
import CoreData

// MARK: Definition
public class ActivityAssessment {
    public var date: Date
    public var moc: NSManagedObjectContext
    public var weight: ActivityWeight = .empty
    public var score: Int = 0
    public var searchTerm: String = "" // @TODO: will have to refactor a fair bit to make this possible
    @Published public var assessables: Assessables
    private var defaultFactors: [FactorProxy] {
        return [
            FactorProxy(date: self.date, weight: 1, type: .records, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .jobs, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .jobs, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .tasks, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .tasks, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .notes, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .notes, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .companies, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .companies, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .people, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .people, action: .interaction),
            FactorProxy(date: self.date, weight: 1, type: .projects, action: .create),
            FactorProxy(date: self.date, weight: 1, type: .projects, action: .interaction)
        ]
    }

    init(for date: Date, moc: NSManagedObjectContext, searchTerm: String = "") {
        self.date = date
        self.moc = moc
        self.searchTerm = searchTerm
        self.assessables = Assessables(
            factors: CDAssessmentFactor(moc: self.moc).all(for: self.date),
            moc: self.moc
        )

        // Create all the AssessmentFactor objects
        if self.assessables.isEmpty {
            for factor in self.defaultFactors {
                self.assessables.factors.append(factor.create(using: self.moc))
            }
        }

        // Perform the assessment by iterating over all the things and calculating the score
        self.score = self.assessables.score
        self.weight = self.assessables.weight
    }
}

// MARK: Data structures
extension ActivityAssessment {
    /// Create prebuilt views
    struct ViewFactory {
        

        struct Factors: View {
            public var assessables: Assessables
            @Binding public var type: EntityType
            @State private var factors: [AssessmentFactor] = []

            var body: some View {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        if factors.isEmpty {
                            HStack {
                                Text("\(type.label) provide no factors")
                                Spacer()
                            }
                            .padding()
                            .background(Theme.rowColour)
                            .clipShape(.rect(cornerRadius: 16))
                        } else {
                            ForEach(factors) { factor in
                                Factor(factor: factor, assessables: self.assessables)
                            }
                        }
                    }
                    .onAppear(perform: self.actionOnAppear)
                    .onChange(of: self.type) {
                        self.actionOnAppear()
                    }
                }
                .padding([.top, .leading, .trailing])
            }

            private func actionOnAppear() -> Void {
                self.factors = assessables.byType(type)
            }
        }

        struct Factor: View {
            @Environment(\.managedObjectContext) var moc
            public let factor: AssessmentFactor
            public let assessables: Assessables
            @State private var weight: Int = 0
            @State private var description: String = ""
            @State private var count: Int = 0
            @State private var threshold: Int = 1

            var body: some View {
                HStack(alignment: .center, spacing: 10) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 10) {
                        GridRow(alignment: .top) {
                            HStack {
                                Text("Description")
                                Spacer()
                                Text("Threshold")
                                Text("Weight")
                            }
                        }
                        .foregroundStyle(.gray)
                        .padding([.top, .leading, .trailing])

                        Divider()
                            .background(.gray)

                        GridRow {
                            HStack {
                                Text(description)
                                Spacer()
                                Picker("Threshold", selection: $threshold) {
                                    ForEach(0..<10) { Text($0.string)}
                                }
                                Picker("Weight", selection: $weight) {
                                    ForEach(0..<6) { Text($0.string)}
                                }
                            }

                        }
                        .padding([.leading, .trailing])
                    }
                    .background(count < threshold ? Theme.base : Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 16))
                }
                .onAppear(perform: self.actionOnAppear)
                .onChange(of: self.threshold) {self.assessables.threshold(factor: self.factor, threshold: self.threshold)}
                .onChange(of: self.weight) {self.assessables.weight(factor: self.factor, weight: self.weight)}
            }

            private func smartDisableFactor() -> Void {
                self.threshold = count < threshold ? count == 0 ? 0 : 1 : count + 1
            }

            private func actionOnAppear() -> Void {
                weight = Int(self.factor.weight)
                threshold = Int(self.factor.threshold)
                count = Int(self.factor.count)

                if let desc = self.factor.desc {
                    description = desc
                }
            }
        }
    }
}
