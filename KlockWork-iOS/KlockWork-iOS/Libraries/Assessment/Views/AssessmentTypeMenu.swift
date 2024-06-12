//
//  AssessmentTypeIntersitial.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

// @TODO: remove or repurpose
struct AssessmentTypeMenu: View {
    @Environment(\.managedObjectContext) var moc
    public var assessment: Assessment?
    @Binding public var assessmentStatuses: [AssessmentThreshold]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider().background(.gray).frame(height: 1)
                ZStack(alignment: .topLeading) {
                    List {
                        NavigationLink {
                            AssessmentThresholdForm(assessmentStatuses: $assessmentStatuses)
                        } label: {
                            Text("Status")
                        }
                        .listRowBackground(Theme.textBackground)
                        .navigationTitle("Assessment Configuration")
                        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                        .toolbarTitleDisplayMode(.inline)

                        if let ass = self.assessment {
                            NavigationLink {
                                AssessmentFactorForm(assessment: ass)
                            } label: {
                                Text("Factors")
                            }
                            .listRowBackground(Theme.textBackground)
                            .navigationTitle("Assessment Configuration")
                            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
                            .toolbarBackground(.visible, for: .navigationBar)
                            .toolbarTitleDisplayMode(.inline)
                        }
                    }

                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                        .opacity(0.1)
                }
            }
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .presentationDetents([.medium, .large])
        .scrollDismissesKeyboard(.immediately)
        .toolbarTitleDisplayMode(.inline)
        .presentationBackground(Theme.cGreen)
        .navigationTitle("Assessment Configuration")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarTitleDisplayMode(.inline)
        .onAppear(perform: self.actionOnAppear)
    }
}

extension AssessmentTypeMenu {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        assessmentStatuses = CDAssessmentThreshold(moc: self.moc).all()
    }
}
