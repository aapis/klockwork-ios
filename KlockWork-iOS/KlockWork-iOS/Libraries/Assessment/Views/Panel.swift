//
//  Panel.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct Panel: View {
    @EnvironmentObject private var state: AppState
    public var assessment: Assessment

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 0) {
                    Divider().background(.gray).frame(height: 1)
                    ZStack(alignment: .topLeading) {
                        OverviewWidget(assessment: assessment)
                            .navigationTitle(assessment.date.formatted(date: .abbreviated, time: .omitted))
                            .toolbarTitleDisplayMode(.inline)
                            .toolbar {
                                ToolbarItem(placement: .topBarTrailing) {
                                    NavigationLink {
                                        Today(inSheet: true)
                                    } label: {
                                        HStack(alignment: .top, spacing: 5) {
                                            Text("Details")
                                            Image(systemName: "chevron.right")
                                        }
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
                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Theme.cGreen)
        .scrollDismissesKeyboard(.immediately)
    }
}
