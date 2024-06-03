//
//  QueryFieldSelectJob.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct QueryFieldSelectJob: View {
    enum Field {
        // Apparently you need to use an existing UITextContentType
        case organizationName
    }

    public let prompt: String
    public var onSubmit: () -> Void
    @Environment(\.managedObjectContext) var moc
    @Binding public var text: String
    @Binding public var job: Job?
    @Binding public var entityType: EntityType
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                if job == nil {
                    HStack {
                        Button {
                            entityType = .jobs
                        } label: {
                            Text("Select a job")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.yellow)
                        }
                    }
                    .padding()
                } else {
                    QueryField(prompt: prompt, onSubmit: self.onSubmit, text: $text)
                }
            }
            .border(width: 1, edges: [.top], color: job != nil && text.isEmpty ? .gray : .yellow)
        }
        .onSubmit(self.onSubmit)
    }
}
