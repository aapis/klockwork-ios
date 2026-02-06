//
//  RecordRecent.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-04.
//

import SwiftUI

struct RecordRecent: View {
    @EnvironmentObject private var state: AppState
    @FetchRequest private var items: FetchedResults<LogRecord>
    @State private var isOpen: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut) {
                    self.isOpen.toggle()
                }
            } label: {
                MiniTitleBarCustom(
                    title: "RECENT",
                    icon: self.isOpen ? "minus" : "plus",
                    fgColour: self.isOpen ? self.state.theme.tint : .gray
                )
                    .border(width: 1, edges: [.bottom], color: self.isOpen ? self.state.theme.tint : .gray)
            }
            .buttonStyle(.plain)

            if self.items.count > 0 {
                if self.isOpen {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(self.items, id: \.id) { entity in
                                ActionButton(entity: entity)
                            }
                        }
                    }
                    .frame(height: 150)
                }
            } else {
                Text("No recent items to display")
            }
        }
    }

    init() {
        _items = CoreDataRecords.fetchRecent(max: 5)
    }

    struct ActionButton: View {
        public var entity: LogRecord
        @AppStorage("entity.record.message") public var message: String = ""

        var body: some View {
            Button {
                if let msg = self.entity.message {
                    self.message = msg
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Text(self.entity.message ?? "N/A")
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .padding(8)
                .background(Theme.textBackground)
            }
            .buttonStyle(.plain)
        }
    }
}
