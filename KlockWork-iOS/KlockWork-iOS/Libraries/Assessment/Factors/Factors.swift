//
//  Factors.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

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
    
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.factors = assessables.byType(type)
    }
}
