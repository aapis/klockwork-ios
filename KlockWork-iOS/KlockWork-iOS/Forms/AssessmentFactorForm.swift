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
    public var assessment: ActivityAssessment
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
                    ActivityAssessment.ViewFactory.Factors(
                        assessables: assessment.assessables,
                        type: $selected
                    )
                    .environment(\.managedObjectContext, moc)
                )
            )
            Spacer()
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("Modify Assessment Factors")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
