//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    @FetchRequest private var records: FetchedResults<LogRecord>

    var body: some View {
        VStack {
            if records.count > 0 {
                VStack(alignment: .leading) {
                    Text("Today")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(records) { record in
                                SingleRecord(record: record)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    
                    Editor()
                    Spacer()
                }
                
            } else {
                Text("No records found for \(Date().formatted())")
            }
        }
        .background(Theme.cPurple)
    }
    
    init() {
        _records = CoreDataRecords.fetchForDate(Date())
    }
}

struct SingleRecord: View {
    public let record: LogRecord
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(record.message!)
                .foregroundStyle(record.job!.backgroundColor.isBright() ? .black : .white)
                .padding(5)
            Spacer()
            Text(record.timestamp!.formatted(date: .omitted, time: .shortened))
                .foregroundStyle(.gray)
                .padding(5)
        }
        .background(record.job!.backgroundColor)
    }
}

struct Editor: View {
    @State private var text: String = ""

    var body: some View {
        VStack {
            TextField("What are you working on?", text: $text)
                .textSelection(.enabled)
                .lineLimit(1)
                .padding()
        }
        .background(Theme.textBackground)
    }
}
