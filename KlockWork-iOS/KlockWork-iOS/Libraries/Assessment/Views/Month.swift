//
//  Month.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct Month: View {
    @EnvironmentObject private var state: AppState
    @Binding public var month: String
    @Binding public var id: UUID
    public var searchTerm: String
    @State private var days: [Day] = []
    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 7)
    }

    var body: some View {
        GridRow {
            LazyVGrid(columns: self.columns, alignment: .leading) {
                ForEach(self.days) {view in view}
            }
        }
        .padding([.leading, .trailing, .bottom])
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.month) {
            self.reset()
        }
    }
}

extension Month {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.days.isEmpty {
            for ass in self.state.activities.assessed {
                self.days.append(
                    Day(assessment: ass, onCloseCallback: self.reset)
                )
            }
        }
    }
    
    /// Reset the view by regenerating all tiles
    /// - Returns: Void
    private func reset() -> Void {
        self.days = []
        self.state.activities.assess()
        self.actionOnAppear()
    }
}
