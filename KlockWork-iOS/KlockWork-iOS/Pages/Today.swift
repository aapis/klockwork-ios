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
                ForEach(records) { record in
                    SingleRecord(record: record)
                }
            } else {
                Text("No records :((((")
            }
        }
    }
    
    init() {
        _records = CoreDataRecords.fetchForDate(Date())
    }
}

struct SingleRecord: View {
    public let record: LogRecord
    
    var body: some View {
        Text(record.message!)
    }
}
