//
//  PageActionBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-08.
//

import SwiftUI

/// Page action bar whose primary functionality occurs through interaction with another sheet
struct PageActionBar: View {
    @EnvironmentObject private var state: AppState
    public let page: PageConfiguration.AppPage
    @State public var groupView: AnyView? = AnyView(EmptyView())
    @State public var sheetView: AnyView? = AnyView(EmptyView())
    @Binding public var isPresented: Bool

    var body: some View {
        VStack(alignment: .leading) {
            groupView
        }
        .foregroundStyle(self.state.theme.tint)
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 2)
        .padding()
        .sheet(isPresented: $isPresented) {
            sheetView
        }
    }

    struct Today: View {
        @EnvironmentObject private var state: AppState
        public var title: String = "What are you working on now?"
        public var prompt: String = "Choose a job"
        @Binding public var job: Job?
        @State private var selectedJobs: [Job] = []
        @State private var selectedJobTitle: String = ""
        @State private var id: UUID = UUID()
        @Binding public var isPresented: Bool
        public var page: PageConfiguration.AppPage = .today
        private let buttonLineLengthLimit: Int = 25

        var body: some View {
            PageActionBar(
                page: self.page,
                groupView: AnyView(Group),
                sheetView: AnyView(
                    Widget.JobSelector.Single(title: self.title, job: $job)
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
                ChooseJobButton
                Spacer()
                AddButton()
                    .foregroundStyle((self.job?.backgroundColor ?? self.page.primaryColour).isBright() ? self.page.primaryColour : self.state.theme.tint)
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

        @ViewBuilder var ChooseJobButton: some View {
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

/// An action bar meant to perform a single action
/// @TODO: rename, this is criminal
struct PageActionBarSingleAction: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public let page: PageConfiguration.AppPage
    @Binding public var job: Job?
    public let onSave: () -> Void
    @State private var isSaveAlertPresented: Bool = false

    var body: some View {
        VStack {
            Button {
                self.onSave()
            } label: {
                HStack(alignment: .center) {
                    Image(systemName: "plus.circle.fill")
                        .fontWeight(.bold)
                        .font(.largeTitle)
                    Text("Save note")
                        .bold()
                    Spacer()
                }
            }
            .padding(8)
            .background(job?.backgroundColor ?? self.page.primaryColour)
            .foregroundStyle((job?.backgroundColor ?? self.page.primaryColour).isBright() ? Theme.cPurple : self.state.theme.tint)
        }
        .clipShape(.capsule(style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 6, x: 2, y: 2)
        .padding()
    }
}

extension PageActionBar.Today {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if self.job != nil {
            let tmpTitle = (self.job!.title ?? self.job!.jid.string).prefix(self.buttonLineLengthLimit)

            self.selectedJobTitle = tmpTitle.count < self.buttonLineLengthLimit ? "\(tmpTitle)" : "\(tmpTitle)..."
            self.state.job = self.job
        } else {
            self.job = self.state.job
        }
    }
}
