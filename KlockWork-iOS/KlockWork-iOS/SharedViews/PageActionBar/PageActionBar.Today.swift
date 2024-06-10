//
//  Today.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

extension PageActionBar {
    struct Today: View {
        @Environment(\.managedObjectContext) var moc
        @Binding public var job: Job?
        @State private var selectedJobs: [Job] = []
        @State private var id: UUID = UUID()
        @Binding public var isSheetPresented: Bool

        var body: some View {
            PageActionBar(
                groupView: AnyView(Group),
                sheetView: AnyView(
                    Widget.JobSelector.Single(showing: $isSheetPresented, job: $job)
                        .presentationBackground(Theme.cPurple)
                ),
                isSheetPresented: $isSheetPresented
            )
            .id(self.id)
            .onChange(of: self.job) { // sheet/group view are essentially static unless we manually refresh them, @TODO: fix this
                self.id = UUID()
            }
        }

        @ViewBuilder var Group: some View {
            HStack(alignment: .center, spacing: 10) {
                AddButton
                Spacer()
            }
            .background(self.job == nil ? Theme.cPurple.opacity(0.5) : self.job?.backgroundColor.opacity(0.5))
        }

        @ViewBuilder var AddButton: some View {
            Button {
                self.isSheetPresented.toggle()
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "chevron.up.circle.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    if job == nil {
                        Text("Choose a job to get started")
                            .fontWeight(.bold)
                    } else {
                        Text("Selected: \(self.job!.title ?? self.job!.jid.string)")
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
            }
            .padding(8)
        }
    }
}
