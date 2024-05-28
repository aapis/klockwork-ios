//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    @Environment(\.managedObjectContext) var moc
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records
    @State private var date: Date = Date()

    @AppStorage("activeDate") public var ad: Double = Date.now.timeIntervalSinceReferenceDate
    private var activeDate: Date {
        set {ad = newValue.timeIntervalSinceReferenceDate}
        get {return Date(timeIntervalSinceReferenceDate: ad)}
    }

    private var idate: IdentifiableDay {
        return DateHelper.identifiedDate(for: activeDate, moc: moc)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(job: $job, date: $date, idate: idate)
                ZStack(alignment: .bottomLeading) {
                    Tabs(job: $job, selected: $selected, date: $date)
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                if selected == .records {
                    Editor(job: $job, entityType: $selected, date: $date)
                }

                Spacer().frame(height: 1)
            }
            .background(Theme.cPurple)
        }
    }
}

extension Today {
    struct Header: View {
        @Binding public var job: Job?
        @Binding public var date: Date
        public var idate: IdentifiableDay

        var body: some View {
            HStack(alignment: .center) {
                HStack(alignment: .center, spacing: 8) {
                    Text(DateHelper.isCurrentDay(idate) ? "Today" : date.formatted(date: .abbreviated, time: .omitted))
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
            if let job = CoreDataJob(moc: moc).byId(33.0) {
                let _ = CoreDataRecords(moc: moc).createWithJob(job: job, date: date, text: text)
                text = ""
            }
        }
    }
}
