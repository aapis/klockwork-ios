//
//  GADateNavigation.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-29.
//
import SwiftUI

struct GADateNavigation: View {
    @EnvironmentObject private var state: AppState
    @AppStorage("home.isWriting") public var isWriting: Bool = false

    var body: some View {
        if !self.isWriting {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Button {
                        self.state.date -= 86400
                        self.state.calendar.selected = self.state.date
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                            Text(DateHelper.todayShort((self.state.date - 86400), format: "MMMM d"))
                                .lineLimit(1)
                                .bold()
                            Spacer()
                        }
                    }
                    .opacity(0.6)
                    .padding(12)
                    .background(
                        ZStack {
                            (DateHelper.isToday(self.state.date - 86400) ? Color.yellow : Color.clear)
                            LinearGradient(colors: [.clear, Theme.base], startPoint: .leading, endPoint: .trailing)
                                .blendMode(.softLight)
                        }
                    )
                    .foregroundStyle(DateHelper.isToday(self.state.date - 86400) ? Theme.cPurple : Theme.lightWhite)
                    Button {
                        self.state.date = Date()
                        self.state.calendar.selected = self.state.date
                    } label: {
                        Image(systemName: DateHelper.isToday(self.state.date) ? "moon.stars.fill" : "moon")
                            .bold()
                    }
                    .shadow(color: .white, radius: DateHelper.isToday(self.state.date) ? 4 : 0)
                    .padding(12)
                    .frame(height: 45)
                    .foregroundStyle(DateHelper.isToday(self.state.date) ? Theme.cPurple : Theme.lightWhite)
                    .background(DateHelper.isToday(self.state.date) ? .yellow : .clear)
                    Button {
                        self.state.date += 86400
                        self.state.calendar.selected = self.state.date
                    } label: {
                        HStack {
                            Spacer()
                            Text(DateHelper.todayShort((self.state.date + 86400), format: "MMMM d"))
                                .lineLimit(1)
                                .bold()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }
                    }
                    .opacity(0.8)
                    .padding(12)
                    .background(
                        ZStack {
                            (DateHelper.isToday(self.state.date + 86400) ? Color.yellow : Color.clear)
                            LinearGradient(colors: [.clear, Theme.base], startPoint: .trailing, endPoint: .leading)
                                .blendMode(.softLight)
                        }
                    )
                    .foregroundStyle(DateHelper.isToday(self.state.date + 86400) ? Theme.cPurple : Theme.lightWhite)
                }
                .background(Color.white.opacity(0.2))
                .clipShape(.rect(cornerRadius: 16))
                .disabled(self.isWriting)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Theme.lightWhite, lineWidth: 1)
                        .blendMode(.softLight)
                }
                .padding([.leading, .trailing], 8)
                .padding([.bottom, .top], 12)
            }
            .background(
                ZStack {
                    Theme.cPurple
                    LinearGradient(colors: [.clear, Theme.base], startPoint: .top, endPoint: .bottom)
                        .blendMode(.softLight)
                        .opacity(0.2)
                }
            )
        }
    }
}
