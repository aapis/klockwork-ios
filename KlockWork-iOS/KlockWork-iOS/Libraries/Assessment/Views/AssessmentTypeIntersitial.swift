//
//  AssessmentTypeIntersitial.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

struct AssessmentTypeIntersitial: View {
    @Environment(\.managedObjectContext) var moc
    public var assessment: Assessment?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Divider().background(.gray).frame(height: 1)
                ZStack(alignment: .topLeading) {
                    List {
                        NavigationLink {
                            AssessmentThresholdForm()
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
    }
}
