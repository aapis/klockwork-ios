//
//  AssessmentThresholdForm.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

struct AssessmentThresholdForm: View {
    @Environment(\.managedObjectContext) var moc
    @State private var thresholds: [AssessmentThreshold] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider().background(.gray).frame(height: 1)
            ZStack(alignment: .topLeading) {
                List {
                    ForEach(thresholds.sorted(by: {$0.defaultValue < $1.defaultValue})) { threshold in
                        Row(threshold: threshold)
                            .listRowBackground(Color.fromStored(threshold.colour!))
                    }
                }

                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 50)
                    .opacity(0.1)
            }

            Spacer()
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("Modify Status")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear(perform: actionOnAppear)
    }
}

extension AssessmentThresholdForm {
    struct Row: View {
        @Environment(\.managedObjectContext) var moc
        public let threshold: AssessmentThreshold

        var body: some View {
            RowBasic(colour: Color.fromStored(threshold.colour!), label: threshold.label!, model: threshold)
        }
    }

    struct RowBasic: View {
        public let colour: Color
        public let label: String
        public let model: AssessmentThreshold
        @State private var value: Int = 0
        private let by1to20: StrideTo<Int> = stride(from: 0, to: 20, by: 1)
        private let by5to50: StrideTo<Int> = stride(from: 20, to: 49, by: 5)
        private let by10to100: StrideTo<Int> = stride(from: 50, to: 101, by: 10)
        private var range: [Int] {
            let g1 = Array(by1to20)
            let g2 = Array(by5to50)
            let g3 = Array(by10to100)

            return g1 + g2 + g3
        }

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Picker(label, selection: $value) {
                        ForEach(range, id: \.self) {Text($0.string).tag(Int($0))}
                    }
                    .onSubmit {
                        self.actionOnSubmit()
                    }
                }
            }
            .onAppear(perform: actionOnAppear)
        }
    }
}

extension AssessmentThresholdForm {
    /// Determine the threshold values by either creating new ones based on ActivityWeight data, or by querying the database
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if thresholds.isEmpty  {
            for weight in ActivityWeight.allCases {
                self.thresholds.append(
                    CDAssessmentThreshold(moc: self.moc).createAndReturn(
                        colour: weight.colour,
                        value: 0,
                        defaultValue: weight.defaultValue,
                        label: weight.label
                    )
                )
            }

            PersistenceController.shared.save()
        } else {
            // @TODO: delete this, it'll clear out all the AT's but we don't want to do that each time
//            Task {
//                CDAssessmentThreshold(moc: self.moc).delete()
//            }

            self.thresholds = CDAssessmentThreshold(moc: self.moc).all()
        }
    }
}

extension AssessmentThresholdForm.RowBasic {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if model.value > 0 {
            value = Int(model.value)
        } else {
            value = Int(model.defaultValue)
        }
    }
    
    /// On submit handler
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        self.model.value = Int64(value)
    }
}
