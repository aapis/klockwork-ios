//
//  RecordFilter.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-07-01.
//

import SwiftUI

struct RecordsGroupedByDate: Identifiable {
    var id: UUID = UUID()
    var date: String
    var records: [LogRecord]
}

struct GroupedRecordDateRow: View {
    public let date: String

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(systemName: "calendar")
            Text(date)
            Spacer()
        }
        .padding(8)
    }
}

struct RecordFilter: View {
    typealias Record = Tabs.Content.Individual.SingleRecord

    @EnvironmentObject private var state: AppState
    public var job: Job?
    public var page: PageConfiguration.AppPage = .create
    @FetchRequest private var records: FetchedResults<LogRecord>
    @State private var groupedRecords: [RecordsGroupedByDate] = []
    @State private var searchText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                ScrollView(showsIndicators: false) {
                    ForEach(groupedRecords) { group in
                        VStack(alignment: .leading, spacing: 1) {
                            GroupedRecordDateRow(date: group.date)

                            ForEach(group.records) { record in
                                Record(record: record)
                            }
                        }
                    }
                }
                LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                    .frame(height: 50)
                    .opacity(0.1)
            }

            QueryField(prompt: "Search for keywords or phrases", onSubmit: self.actionOnSubmit, action: .search, text: $searchText)
        }
        .onAppear(perform: self.actionOnAppear)
        .navigationTitle("Records")
        .background(self.page.primaryColour)
        .scrollContentBackground(.hidden)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
#endif
        .scrollDismissesKeyboard(.immediately)
    }

    init(job: Job?) {
        self.job = job
        _records = CoreDataRecords.fetch(job: self.job!)
    }
}

extension RecordFilter {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.groupedRecords = []
        if self.records.count > 0 {
            let grouped = Dictionary(grouping: self.records, by: {$0.timestamp!.formatted(date: .abbreviated, time: .omitted)})
            let sorted = Array(grouped)
                .sorted(by: {
                    let df = DateFormatter()
                    df.dateStyle = .medium
                    df.timeStyle = .none

                    if let d1 = df.date(from: $0.key) {
                        if let d2 = df.date(from: $1.key) {
                            return d1 < d2
                        }
                    }
                    return false
                })

            for group in sorted {
                self.groupedRecords.append(
                    RecordsGroupedByDate(date: group.key, records: group.value.sorted(by: {$0.timestamp! < $1.timestamp!}))
                )
            }
        }
    }
    
    /// Plaintext search onsubmit handler
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        self.groupedRecords = []
        if self.records.count > 0 {
            let grouped = Dictionary(grouping: self.records, by: {$0.timestamp!.formatted(date: .abbreviated, time: .omitted)})
            let sorted = Array(grouped)
                .sorted(by: {
                    let df = DateFormatter()
                    df.dateStyle = .medium
                    df.timeStyle = .none

                    if let d1 = df.date(from: $0.key) {
                        if let d2 = df.date(from: $1.key) {
                            return d1 < d2
                        }
                    }
                    return false
                })

            for group in sorted {
                if self.searchText.isEmpty {
                    self.groupedRecords.append(
                        RecordsGroupedByDate(date: group.key, records: group.value.sorted(by: {$0.timestamp! < $1.timestamp!}))
                    )
                } else {
                    let matchingRecords = group.value.filter({$0.message?.contains(self.searchText.lowercased()) ?? false})
                    self.groupedRecords.append(
                        RecordsGroupedByDate(date: group.key, records: matchingRecords.sorted(by: {$0.timestamp! < $1.timestamp!}))
                    )
                }
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
