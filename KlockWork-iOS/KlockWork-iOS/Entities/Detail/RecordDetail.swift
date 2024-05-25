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
                        "Created on",
                        selection: $timestamp,
                        displayedComponents: [.date]
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
            .background(Theme.cPurple)
            Spacer()
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle("Inspecting Record")
        .toolbarBackground(Theme.cPurple, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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

