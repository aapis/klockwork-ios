//
//  Day.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

/// An individual calendar day "tile"
struct Day: View, Identifiable {
    public let id: UUID = UUID()
    public let day: Int
    public let isToday: Bool
    public var isWeekend: Bool? = false
    public var assessment: ActivityAssessment
    @Binding public var calendarDate: Date
    @State private var bgColour: Color = .clear
    @State private var isPresented: Bool = false
    private let gridSize: CGFloat = 40

    var body: some View {
        Button {
            calendarDate = assessment.date
            isPresented.toggle()
        } label: {
            if self.day > 0 {
                Text(String(self.day))
            }
        }
        .frame(minWidth: self.gridSize, minHeight: self.gridSize)
        .background(self.day > 0 ? self.bgColour : .clear)
        .clipShape(.rect(cornerRadius: 6))
        .onAppear(perform: actionOnAppear)
        .sheet(isPresented: $isPresented) {
            Panel(assessment: assessment)
        }
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if isToday {
            bgColour = .blue
        } else {
            if isWeekend! {
                // IF we worked on the weekend, highlight the tile in red (this is bad and should be highlighted)
                if assessment.weight != .empty {
                    bgColour = .red
                } else {
                    bgColour = .clear
                }
            } else {
                bgColour = assessment.weight.colour
            }
        }
    }
}
