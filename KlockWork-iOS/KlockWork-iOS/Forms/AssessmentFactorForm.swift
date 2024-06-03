//
//  AssessmentFactorForm.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-30.
//

import SwiftUI

// @TODO: move to ActivityAssessment.ViewFactory
struct AssessmentFactorForm: View {
    @Environment(\.managedObjectContext) var moc
    public let assessment: ActivityAssessment
    @FetchRequest private var factors: FetchedResults<AssessmentFactor>
    @State private var assessables: ActivityAssessment.Assessables = ActivityAssessment.Assessables()
    @State private var job: Job?
    @State private var selected: EntityType = .records
    @State private var date: Date = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().background(.gray).frame(height: 1)
            Tabs(
                inSheet: true,
                job: $job,
                selected: $selected,
                date: $date,
                content: AnyView(
                    ActivityAssessment.ViewFactory.EntitySelect(
                        inSheet: true,
                        selected: $selected,
                        assessables: self.assessables
                    )
                    .environment(\.managedObjectContext, moc)
                )
            )
            Spacer()
        }
        .onAppear(perform: self.actionOnAppear)
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("Modify Assessment Factors")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    init(assessment: ActivityAssessment) {
        self.assessment = assessment
        _factors = CDAssessmentFactor.fetchAll(for: self.assessment.date)
    }
}

extension AssessmentFactorForm {
    private func actionOnAppear() -> Void {
        assessables.clear()

        for factor in factors {
            assessables.factors.append(factor)
        }
    }
}
