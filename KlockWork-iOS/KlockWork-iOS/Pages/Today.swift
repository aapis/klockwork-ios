//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    public var inSheet: Bool
    @Binding public var date: Date
    @Environment(\.managedObjectContext) var moc
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                if !inSheet {
                    Header(job: $job, date: $date)
                }

                ZStack(alignment: .bottomLeading) {
                    Tabs(inSheet: inSheet, job: $job, selected: $selected, date: $date)
                    if !inSheet {
                        LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                            .frame(height: 50)
                            .opacity(0.1)
                    }
                }

                if !inSheet {
                    if selected == .records {
                        Editor(job: $job, entityType: $selected, date: $date)
                    }

                    Spacer().frame(height: 1)
                }
            }
            .background(Theme.cPurple)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(inSheet ? .visible : .hidden)
            .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

extension Today {
    struct Header: View {
        @Binding public var job: Job?
        @Binding public var date: Date

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(Calendar.autoupdatingCurrent.isDateInToday(date) ? "Today" : date.formatted(date: .abbreviated, time: .omitted))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding([.leading, .top, .bottom])
                        .overlay {
                            DatePicker(
                                "Date picker",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .contentShape(Rectangle())
                            .opacity(0.011)
                        }
                    Image(systemName: "chevron.right")
                }

                Spacer()

                Button {
                    job = nil
                } label: {
                    if let jerb = job {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "xmark")
                            Text("\(jerb.title ?? jerb.jid.string)")
                        }
                        .padding(7)
                        .background(jerb.backgroundColor)
                        .foregroundStyle(jerb.backgroundColor.isBright() ? Theme.cPurple : .white)
                        .cornerRadius(7)
                    }
                }

                .padding(.trailing)
            }
        }
    }

    struct Editor: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var job: Job?
        @Binding public var entityType: EntityType
        @Binding public var date: Date
        @State private var text: String = ""
        
        var body: some View {
            if job == nil {
                QueryFieldSelectJob(
                    prompt: "What are you working on?",
                    onSubmit: self.actionOnSubmit,
                    text: $text,
                    job: $job,
                    entityType: $entityType
                )
            } else {
                QueryField(
                    prompt: "What are you working on?",
                    onSubmit: self.actionOnSubmit,
                    text: $text
                )
            }
        }
    }
}

extension Today.Editor {
    /// Form action
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
            if let job = self.job {
                CoreDataRecords(moc: moc).createWithJob(
                    job: job,
                    date: Date(), // LogRecord.createdDate == CURRENT DATE
                    text: text
                )
                text = ""
            }
        }
    }
}
