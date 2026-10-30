//
//  CommentDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-24.
//

import SwiftUI

struct CommentDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    public var comment: LogRecordComment?
    @State private var timestamp: Date = Date()
    @State private var record: LogRecord?
    @State private var message: String = ""
    @State private var isSaveAlertPresented: Bool = false
    @State private var isDeleteAlertPresented: Bool = false
    private let page: PageConfiguration.AppPage = .create

    var body: some View {
        VStack {
            PageHeader(
                title: "Add a comment"
            )
            List {
                Section("Comment") {
                    TextField("Comment", text: self.$message, axis: .vertical)
                        .lineLimit(15, reservesSpace: true)
                }
                .listRowBackground(Theme.textBackground)

                if self.comment != nil {
                    Button("Delete Comment", role: .destructive, action: self.actionInitiateDelete)
                        .alert("Are you sure?", isPresented: $isDeleteAlertPresented) {
                            Button("Yes", role: .destructive) {
                                self.actionOnDelete()
                            }
                        } message: {
                            Text("This comment will be permanently deleted.")
                        }
                        .listRowBackground(Color.red)
                        .foregroundStyle(.white)
                }
            }
            Spacer()
        }
        .background(self.page.primaryColour)
        .onAppear(perform: self.actionOnAppear)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .scrollContentBackground(.hidden)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // Creates new entity on tap, then sends user back to Today
                Button {
                    self.actionOnSave()
                } label: {
                    Text("Save")
                }
                .foregroundStyle(self.state.theme.tint)
            }
        }
    }

    /// Onload handler. Sets timestamp and message fields.
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.message = self.comment?.message ?? ""
        self.record = self.comment?.record
        self.timestamp = self.comment?.timestamp ?? Date.now
    }

    /// Save handler
    /// - Returns: Void
    private func actionOnSave() -> Void {
        if self.comment != nil {
            self.comment?.message = self.message
            self.comment?.record = self.record
        } else {
            // Create a new one
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Soft delete a Task
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if self.comment != nil {
            self.state.moc.delete(self.comment!)
        }

        PersistenceController.shared.save()
        dismiss()
    }

    /// Opens the delete object alert
    /// - Returns: Void
    private func actionInitiateDelete() -> Void {
        self.isDeleteAlertPresented.toggle()
    }
}
