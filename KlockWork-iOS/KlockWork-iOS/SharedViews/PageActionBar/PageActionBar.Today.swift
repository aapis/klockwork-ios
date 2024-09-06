//
//  Today.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

extension PageActionBar {
    struct Today: View {
        @EnvironmentObject private var state: AppState
        public var title: String = "What are you working on now?"
        public var prompt: String = "Choose a job to get started"
        @Binding public var job: Job?
        @State private var selectedJobs: [Job] = []
        @State private var selectedJobTitle: String = ""
        @State private var id: UUID = UUID()
        @Binding public var isPresented: Bool
        private let page: PageConfiguration.AppPage = .today
        private let buttonLineLengthLimit: Int = 25

        var body: some View {
            PageActionBar(
                page: self.page,
                groupView: AnyView(Group),
                sheetView: AnyView(
                    Widget.JobSelector.Single(title: self.title, showing: $isPresented, job: $job)
                        .presentationBackground(Theme.cPurple)
                ),
                isPresented: $isPresented
            )
            .id(self.id)
            .onAppear(perform: self.actionOnAppear)
            .onChange(of: self.job) { // sheet/group view are essentially static unless we manually refresh them, @TODO: fix this
                self.id = UUID()
                self.actionOnAppear()
            }
            .onChange(of: self.state.job) {
                self.id = UUID()
                self.actionOnAppear()
            }
        }

        @ViewBuilder var Group: some View {
            HStack(alignment: .center, spacing: 10) {
                AddButton
                Spacer()
            }
            .background(
                ZStack {
                    if self.job == nil {
                        self.page.primaryColour
                        Color.white.blendMode(.softLight)
                    } else {
                        self.job?.backgroundColor
                    }
                }
            )
        }

        @ViewBuilder var AddButton: some View {
            Button {
                self.isPresented.toggle()
                // clear job before setting, may add a dedicated clear button at some point
                self.state.job = nil
                self.job = nil
            } label: {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: "hammer.circle.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    if job == nil {
                        Text(self.prompt)
                            .multilineTextAlignment(.leading)
                            .fontWeight(.bold)
                    } else {
                        // @TODO: this is not ideal, but changing view modes doesn't fire actionOnAppear and this was
                        // @TODO: quicker than finding out why
                        let tmpTitle = (self.job!.title ?? self.job!.jid.string).prefix(self.buttonLineLengthLimit)
                        Text(tmpTitle.count < self.buttonLineLengthLimit ? "\(tmpTitle)" : "\(tmpTitle)...")
                            .multilineTextAlignment(.leading)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }
                .foregroundStyle((self.job?.backgroundColor ?? self.page.primaryColour).isBright() ? self.page.primaryColour : self.state.theme.tint)
            }
            .padding(8)
        }
    }
}

extension PageActionBar.Today {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.job != nil {
            let tmpTitle = (self.job!.title ?? self.job!.jid.string).prefix(self.buttonLineLengthLimit)

            self.selectedJobTitle = tmpTitle.count < self.buttonLineLengthLimit ? "\(tmpTitle)" : "\(tmpTitle)..."
        }
    }
}
