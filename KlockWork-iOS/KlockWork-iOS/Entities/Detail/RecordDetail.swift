//
//  RecordDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct RecordDetail: View {
    public let record: LogRecord

    @State private var timestamp = Date()
    @State private var message: String = ""

    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    DatePicker(
                        "Created",
                        selection: $timestamp,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    // @TODO: implement JobPicker as a sheet
                }
                .listRowBackground(Theme.textBackground)

                Section("Message") {
                    TextField("Record content", text: $message, axis: .vertical)
                }
                .listRowBackground(Theme.textBackground)
            }
            .listStyle(.grouped)
            Spacer()
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle("Editing: Record")
        .toolbar {
            Button("Save") {

            }
        }
    }
}

extension RecordDetail {
    private func actionOnAppear() -> Void {
        if let tmstmp = record.timestamp {
            timestamp = tmstmp
        }

        if let msg = record.message {
            message = msg
        }
    }
}
