//
//  Day.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

/// An individual calendar day "tile"
struct Day: View, Identifiable {
    @EnvironmentObject private var state: AppState
    public let id: UUID = UUID()
    public var assessment: Assessment
    @State private var bgColour: Color = .clear
    @State private var isPresented: Bool = false
    private let gridSize: CGFloat = 40

    var body: some View {
        Button {
//            if let selectedDate = assessment.date {
//                self.state.date = selectedDate
//            }

            isPresented.toggle()
        } label: {
            if self.assessment.dayNumber > 0 {
                Text(String(self.assessment.dayNumber))
            }
        }
        .frame(minWidth: self.gridSize, minHeight: self.gridSize)
        .background(self.assessment.dayNumber > 0 ? self.bgColour : .clear)
//        .foregroundColor(self.isToday && !self.isSelected ? .black : .white)
        .foregroundColor(self.assessment.isToday ? Theme.cGreen : .white)
        .clipShape(.rect(cornerRadius: 6))
        .onAppear(perform: self.actionOnAppear)
        .sheet(isPresented: $isPresented) {
            Panel(assessment: assessment)
                .onDisappear(perform: self.actionOnDisappear)
        }
    }
}

extension Day {
    /// Onload handler, determines tile background colour
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = self.assessment.backgroundColourFromWeight()
    }

    private func actionOnDisappear() -> Void {
//        self.state.activities.changed = true
    }
}
