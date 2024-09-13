//
//  DateStrip.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-13.
//

import SwiftUI

struct DateStrip: View {
    @EnvironmentObject private var state: AppState
    @State public var date: Date = Date()
    @State private var dateStripMonth: String = ""
    @State private var dateStripDay: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(self.dateStripMonth)
                .multilineTextAlignment(.leading)
            Divider()
                .background(self.state.theme.tint)
                .frame(width: 15)
            Text(self.dateStripDay)
                .multilineTextAlignment(.leading)
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(self.state.theme.tint)
        .padding(.leading, 10)
        .onAppear(perform: {
            DefaultObjects.deleteDefaultObjects()

            self.createDateWidget()
        })
        .onChange(of: self.state.date) {
            self.createDateWidget()
        }
    }
}

extension DateStrip {
    /// Sets month/day values from State.date
    /// - Returns: Void
    private func createDateWidget() -> Void {
        let df1 = DateFormatter()
        df1.dateFormat = "MM"
        df1.timeZone = TimeZone.autoupdatingCurrent
        df1.locale = NSLocale.current

        let df2 = DateFormatter()
        df2.dateFormat = "dd"
        df2.timeZone = TimeZone.autoupdatingCurrent
        df2.locale = NSLocale.current

        self.dateStripMonth = df1.string(from: self.date)
        self.dateStripDay = df2.string(from: self.date)
    }
}

