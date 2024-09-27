//
//  AssessmentFactorForm.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-30.
//

import SwiftUI

struct AssessmentFactorForm: View {
    typealias EntityType = PageConfiguration.EntityType

    @EnvironmentObject private var state: AppState
    public var assessment: Assessment
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
                content: AnyView(
                    Factors(
                        assessables: assessment.assessables,
                        type: $selected
                    )
                    .environment(\.managedObjectContext, self.state.moc)
                )
            )
            Spacer()
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("Modify Assessment Factors")
#if os(iOS)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarTitleDisplayMode(.inline)
#endif
    }
}
