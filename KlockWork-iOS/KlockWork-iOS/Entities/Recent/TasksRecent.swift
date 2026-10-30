//
//  TasksRecent.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-25.
//

import SwiftUI

struct TasksRecent: View {
    @EnvironmentObject private var state: AppState
    @FetchRequest private var items: FetchedResults<LogTask>
    @State private var isOpen: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.easeInOut) {
                    self.isOpen.toggle()
                }
            } label: {
                MiniTitleBarCustom(
                    title: "SUGGESTIONS",
                    icon: self.isOpen ? "minus" : "plus",
                )
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
        _items = CoreDataTasks.fetch(
            with: NSPredicate(format: "isSuggested == true"),
            sort: [NSSortDescriptor(keyPath: \LogTask.created?, ascending: true)]
        )
    }

    struct ActionButton: View {
        public var entity: LogTask
        @AppStorage("entity.task.title") public var title: String = ""
        @AppStorage("entity.task.content") public var content: String = ""

        var body: some View {
            Button {
                if let title = self.entity.title {
                    self.title = title
                }
                if let content = self.entity.content {
                    self.content = content
                }
            } label: {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Text(self.entity.title ?? self.entity.content ?? "N/A")
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
