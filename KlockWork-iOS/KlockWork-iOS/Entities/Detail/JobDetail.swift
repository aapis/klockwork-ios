//
//  JobDetail.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct JobDetail: View {
    public let job: Job
    
    @State private var alive: Bool = false

    var body: some View {
        VStack {
            List {
                Section("Settings") {
                    Toggle("Published", isOn: $alive)
                }
                .listRowBackground(Theme.textBackground)
            }
            .listStyle(.grouped)
        }
        .onAppear(perform: actionOnAppear)
        .navigationTitle(job.title != nil ? job.title!.capitalized : "Job #\(job.jid.string)")
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            Button("Save") {

            }
        }
    }
}

extension JobDetail {
    private func actionOnAppear() -> Void {
        alive = job.alive
//        projects = company.projects?.allObjects as! [Project]
    }
}
