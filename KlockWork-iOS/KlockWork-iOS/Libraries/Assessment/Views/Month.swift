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
    public var searchTerm: String
    @State private var days: [Day] = []
    @State private var id: UUID = UUID()
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
            self.days = []
            self.actionOnAppear()
        }
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.days.isEmpty {
            for ass in self.state.activities.assessed {
                self.days.append(
                    Day(assessment: ass)
                )
            }
        }
    }
}
