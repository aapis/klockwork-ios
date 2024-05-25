//
//  RecordDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct RecordDetail: View {
    public let record: LogRecord

    @State private var date = Date()

    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    DatePicker(
                        "Created on",
                        selection: $date,
                        displayedComponents: [.date]
                    )
                    .listRowBackground(Theme.textBackground)

                    // @TODO: implement JobPicker as a sheet
                }
            }
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
        if let timestamp = record.timestamp {
            date = timestamp
        }
    }
}

