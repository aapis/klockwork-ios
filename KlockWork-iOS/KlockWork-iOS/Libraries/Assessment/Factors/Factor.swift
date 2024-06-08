//
//  Factor.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

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
    
    /// Set the threshold to a value higher than it's count to disable, set to 0 to re-enable.
    /// @TODO: CURRENTLY UNUSED
    /// - Returns: Void
    private func smartDisableFactor() -> Void {
        self.threshold = count < threshold ? count == 0 ? 0 : 1 : count + 1
    }
    
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        weight = Int(self.factor.weight)
        threshold = Int(self.factor.threshold)
        count = Int(self.factor.count)
        description = self.factor.factorDescription()
    }
}
