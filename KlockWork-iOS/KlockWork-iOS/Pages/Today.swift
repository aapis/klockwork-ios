//
//  Today.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Today: View {
    @Environment(\.managedObjectContext) var moc
    @State private var job: Job? = nil
    @State private var selected: EntityType = .records

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header(job: $job)
                ZStack(alignment: .bottomLeading) {
                    Tabs(job: $job, selected: $selected)
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                if selected == .records {
                    Editor(job: $job, entityType: $selected)
                }

                Spacer()
                .frame(height: 1)
            }
            .background(Theme.cPurple)
        }
    }
}

extension Today {
    struct Header: View {
        @Binding public var job: Job?

        var body: some View {
            HStack(spacing: 0) {
                Text("Today")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                Spacer()
                Button {
                    job = nil
                } label: {
                    if let jerb = job {
                        HStack(alignment: .center, spacing: 5) {
                            Image(systemName: "xmark")
                            Text("\(jerb.title ?? jerb.jid.string)")
                        }
                        .padding(7)
                        .background(jerb.backgroundColor)
                        .foregroundStyle(jerb.backgroundColor.isBright() ? Theme.cPurple : .white)
                        .cornerRadius(7)
                    }
                }

                .padding(.trailing)
            }
        }
    }

    struct Editor: View {
        enum Field {
            // Apparently you need to use an existing UITextContentType
            case organizationName
        }

        @Binding public var job: Job?
        @Binding public var entityType: EntityType
        @Environment(\.managedObjectContext) var moc
        @State private var text: String = ""
        @FocusState public var focused: Field?

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    if job == nil {
                        HStack {
                            Button("Select a job") {
                                entityType = .jobs
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.yellow)
                        }
                        .padding()
                    } else {
                        TextField(
                            "",
                            text: $text,
                            prompt: Text("What are you working on?")
                            //                        .foregroundStyle(job != nil ? job!.backgroundColor.isBright() ? Theme.cPurple : .white : .gray)
                                .foregroundStyle(.gray),
                            axis: .horizontal // @TODO: we want .vertical but need to find a way to trigger .onSubmit if we do that
                        )
                        .disableAutocorrection(false)
                        .focused($focused, equals: .organizationName)
                        .disabled(job == nil)
                        .textContentType(.organizationName)
                        .submitLabel(.return)
                        .textSelection(.enabled)
                        .padding()

                        Spacer()

                        Button {
                            if !text.isEmpty {
                                self.actionOnSubmit()
                            }
                        } label: {
                            Image(systemName: "arrow.up")
                                .foregroundStyle(text.isEmpty ? .gray : .yellow)
                        }
                        .padding(.trailing)
                    }
                }
                .border(width: 1, edges: [.top], color: job != nil && text.isEmpty ? .gray : .yellow)
            }
            .onSubmit(self.actionOnSubmit)
        }
    }
}

extension Today.Editor {
    private func actionOnSubmit() -> Void {
        if !text.isEmpty {
            if let job = CoreDataJob(moc: moc).byId(33.0) {
                let _ = CoreDataRecords(moc: moc).createWithJob(job: job, date: Date(), text: text)
                text = ""
            }
        }
    }
}
