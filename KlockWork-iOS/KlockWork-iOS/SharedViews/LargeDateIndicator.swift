//
//  LargeDateIndicator.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-13.
//
import SwiftUI

struct LargeDateIndicator: View {
    @EnvironmentObject private var state: AppState

    var body: some View {
        Text("\(self.state.date.formatted(date: .abbreviated, time: .omitted))")
            .padding(7)
            .background(self.state.isToday() ? .yellow : Theme.rowColour)
            .foregroundStyle(self.state.isToday() ? Theme.cOrange : .white)
            .fontWeight(.bold)
            .cornerRadius(7)
            .padding(.trailing)
    }
}
