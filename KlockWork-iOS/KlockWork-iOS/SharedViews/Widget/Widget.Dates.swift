//
//  Widget.Dates.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-26.
//

import SwiftUI

extension Widget {
    struct Dates {
        struct Header: View {
            @EnvironmentObject private var state: AppState
            @State private var isCalendarPresented: Bool = false
            @AppStorage("today.viewMode") private var viewMode: Int = 0

            var body: some View {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Button {
                            self.isCalendarPresented.toggle()
                        } label: {
                            Text("\(self.state.date.formatted(Date.FormatStyle().weekday())), \(DateHelper.todayShort(self.state.date, format: "MMMM dd"))")
                                .font(.title)
                                .bold()
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    .padding([.leading, .trailing])
                    HStack(alignment: .top) {
                        Text(DateHelper.todayShort(self.state.date, format: "dd/MM/YYYY"))
                            .font(.caption)
                            .fontDesign(.monospaced)
                            .padding(.leading)
                            .foregroundStyle(self.state.theme.tint)
                        Spacer()
                    }
                }
                .onChange(of: self.isCalendarPresented) {
                    if self.isCalendarPresented {
                        self.viewMode = 2
                    } else {
                        self.viewMode = 0
                    }
                }
            }
        }
    }
}
