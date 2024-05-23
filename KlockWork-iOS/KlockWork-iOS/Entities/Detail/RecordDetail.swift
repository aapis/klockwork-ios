//
//  RecordDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-23.
//

import SwiftUI

struct RecordDetail: View {
    public let record: LogRecord

    @State private var isDefault: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    Toggle("Default company", isOn: $isDefault)
                        .listRowBackground(Theme.textBackground)
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

    }
}

