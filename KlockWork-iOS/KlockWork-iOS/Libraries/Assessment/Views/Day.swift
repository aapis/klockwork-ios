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
    public var onCloseCallback: () -> Void
    @State private var bgColour: Color = .clear
    @State private var isPresented: Bool = false
    private let gridSize: CGFloat = 40

    var body: some View {
        Button {
            self.state.date = DateHelper.startOfDay(assessment.date)
            isPresented.toggle()
        } label: {
            if self.assessment.dayNumber > 0 {
                Text(String(self.assessment.dayNumber))
            }
        }
        .frame(minWidth: self.gridSize, minHeight: self.gridSize)
        .background(self.assessment.dayNumber > 0 ? self.bgColour : .clear)
        .foregroundColor(self.assessment.isToday || self.bgColour.isBright() ? Theme.cGreen : .white)
        .clipShape(.rect(cornerRadius: 6))
        .onAppear(perform: self.actionOnAppear)
        .sheet(isPresented: $isPresented) {
            Panel(assessment: assessment)
                .onDisappear(perform: self.onCloseCallback)
        }
    }
}

extension Day {
    /// Onload handler, determines tile background colour
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = self.assessment.backgroundColourFromWeight()
    }
}

/// A basic individual calendar day "tile"
struct SelectorDay: View, Identifiable {
    @EnvironmentObject private var state: AppState
    public let id: UUID = UUID()
    public var day: Int
    public var onCloseCallback: () -> Void
    @State private var bgColour: Color = .clear
    @AppStorage("today.viewMode") private var viewMode: Int = 0
    private let gridSize: CGFloat = 40

    var body: some View {
        Button {
            self.viewMode = 0
            self.state.date = DateHelper.dateForDayNumber(self.day)
        } label: {
            Text(String(self.day))
        }
        .frame(minWidth: self.gridSize, minHeight: self.gridSize)
        .background(self.bgColour)
        .foregroundColor(DateHelper.isToday(self.day) || self.bgColour.isBright() ? Theme.cGreen : .white)
        .clipShape(.rect(cornerRadius: 6))
        .onAppear(perform: self.actionOnAppear)
    }
}

extension SelectorDay {
    /// Onload handler, determines tile background colour
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.bgColour = .clear

        if DateHelper.isToday(self.day) {
            self.bgColour = self.state.theme.tint
        } else if self.state.date == DateHelper.dateForDayNumber(self.day) {
            self.bgColour = .blue
        }
    }
}
