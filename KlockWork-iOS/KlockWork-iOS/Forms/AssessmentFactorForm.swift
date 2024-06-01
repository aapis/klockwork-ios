//
//  AssessmentFactorForm.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-30.
//

import SwiftUI

struct AssessmentFactorForm: View {
    public let assessment: ActivityAssessment
    @FetchRequest private var assessables: FetchedResults<AssessmentFactor>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().background(.gray).frame(height: 1)
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading) {
                    ForEach(self.assessables) { ass in
                        Text(ass.desc!)
                    }
                }
                .padding()

                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 50)
                    .opacity(0.1)
            }
            Spacer()
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("\(assessables.count) Factors")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    init(assessment: ActivityAssessment) {
        self.assessment = assessment
        _assessables = CDAssessmentFactor.fetchAll(for: self.assessment.date)
    }
}
