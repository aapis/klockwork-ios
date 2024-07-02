//
//  RecordFilter.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-07-01.
//

import SwiftUI

struct RecordsGroupedByDate: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var records: [LogRecord]
}

struct RecordFilter: View {
    typealias Button = Tabs.Content.Individual.SingleRecord
    public let job: Job
    public var page: PageConfiguration.AppPage = .create
    @FetchRequest private var records: FetchedResults<LogRecord>
    @State private var groupedRecords: [RecordsGroupedByDate] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(showsIndicators: false) {
                ForEach(groupedRecords) { group in
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "calendar")
                            Text(group.date.formatted(date: .abbreviated, time: .omitted))
                            Spacer()
                        }
                        .padding(8)

                        ForEach(records) { record in
                            Button(record: record)
                        }
                    }
                }
            }
        }
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle("Records")
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollDismissesKeyboard(.immediately)
    }

    init(job: Job) {
        self.job = job
        _records = CoreDataRecords.fetch(job: self.job)
    }
}

extension RecordFilter {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.groupedRecords = []
        if self.records.count > 0 {
            let grouped = Array(self.records)
                .sliced(by: [.year, .month, .day], for: \.timestamp!)
                .sorted(by: {$0.key > $1.key})

            for group in grouped {
                self.groupedRecords.append(
                    RecordsGroupedByDate(date: group.key, records: group.value)
                )
            }
        }
    }
}

/// Thank you https://stackoverflow.com/a/64496966
extension Array {
  func sliced(by dateComponents: Set<Calendar.Component>, for key: KeyPath<Element, Date>) -> [Date: [Element]] {
    let initial: [Date: [Element]] = [:]
    let groupedByDateComponents = reduce(into: initial) { acc, cur in
      let components = Calendar.current.dateComponents(dateComponents, from: cur[keyPath: key])
      let date = Calendar.current.date(from: components)!
      let existing = acc[date] ?? []
      acc[date] = existing + [cur]
    }

    return groupedByDateComponents
  }
}
