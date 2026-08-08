//
//  ChecklistDetail.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-26.
//

import SwiftUI

struct ChecklistDetail: View {
    @EnvironmentObject private var state: AppState
    @Environment(\.dismiss) private var dismiss
    @AppStorage("home.backgroundWallpaper") public var homeWallpaper: String = ""
    @AppStorage("home.shouldUseWPImage") public var shouldUseWPImage: Bool = false
    @State private var label: String = ""
    @State private var overview: String = ""
    @State private var tasks: [LogTask] = []
    @State private var outcomes: [LogTask] = []
    @State private var colour: Color = .clear
    @State private var isDeleteConfirmPresented: Bool = false
    @State private var isTaskSelectorPresented: Bool = false
    @State private var isOutcomeTaskSelectorPresented: Bool = false
    @State private var starred: Bool = false
    public var checklist: Checklist?
    private let page: PageConfiguration.AppPage = .create

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical) {
                VStack(alignment: .leading) {
                    HStack {
                        Field(label: "Label", value: self.$label)
                        Spacer()
                        BooleanField(label: "Star", value: self.$starred)
                    }
                    Field(label: "Overview", value: self.$overview)

                    HStack(alignment: .center) {
                        ColorPicker(selection: $colour) {
                            Text("Colour")
                                .foregroundStyle(colour == .clear ? .gray : .white)
                        }
                    }
                    .padding()
                    .background(Theme.textBackground)
                    .clipShape(.rect(cornerRadius: 4))
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Image(systemName: PageConfiguration.EntityType.tasks.iconString)
                                .symbolRenderingMode(.hierarchical)
                            Text("Tasks")
                            Spacer()
                            Button {
                                self.tasks.append(
                                    CoreDataTasks(moc: self.state.moc).createAndReturn(content: "", title: "Edit me", created: self.state.date, due: Date.distantPast, saveByDefault: false)
                                )
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            Button {
                                self.isTaskSelectorPresented = true
                            } label: {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Theme.textBackground)
                        VStack(alignment: .leading, spacing: 1) {
                            if !self.tasks.isEmpty {
                                ForEach(self.tasks, id: \.self) { task in
                                    EditableTask(
                                        task: task,
                                        callback: {
                                            self.actionOnSave(shouldDismiss: false)
                                        },
                                        shouldFocus: false,
                                        tasks: self.$tasks
                                    )
                                }
                            } else {
                                HStack {
                                    Text("Add some")
                                        .foregroundStyle(.gray)
                                    Spacer()
                                }
                                .padding()
                                .background(Theme.textBackground)
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 1) {
                        HStack {
                            Text("Track expected outcomes for completing the tasks in this list. Optional.")
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(Theme.lightWhite)
                                .italic()
                            Spacer()
                        }
                        .padding(4)
                        .background(Theme.textBackground)
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                            Text("Outcomes")
                            Spacer()
                            Button {
                                self.outcomes.append(
                                    CoreDataTasks(moc: self.state.moc).createAndReturn(content: "", title: "Edit me", created: self.state.date, due: Date.distantPast, saveByDefault: false)
                                )
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            Button {
                                self.isOutcomeTaskSelectorPresented = true
                            } label: {
                                Image(systemName: "magnifyingglass.circle.fill")
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(Theme.textBackground)

                        VStack(alignment: .leading, spacing: 1) {
                            if !self.outcomes.isEmpty {
                                ForEach(self.outcomes, id: \.self) { task in
                                    EditableTask(
                                        task: task,
                                        callback: {
                                            self.actionOnSave(shouldDismiss: false)
                                        },
                                        shouldFocus: false,
                                        tasks: self.$outcomes
                                    )
                                }
                            } else {
                                HStack {
                                    Text("Add some")
                                        .foregroundStyle(.gray)
                                    Spacer()
                                }
                                .padding()
                                .background(Theme.textBackground)
                            }
                        }
                    }
                    if self.checklist != nil {
                        VStack(alignment: .leading, spacing: 1) {
                            Button {
                                self.isDeleteConfirmPresented.toggle()
                            } label: {
                                HStack {
                                    Text("Delete")
                                    Spacer()
                                }
                            }
                            .buttonStyle(.plain)
                            .padding()
                            .background(Color.red)
                        }
                    }
                }
                .clipShape(.rect(cornerRadius: 4))
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(
            /// I don't know what to tell you. For some reason, this view will absolutely NOT set a background colour that extends to the toolbar unless I use the WP
            // @TODO: Look into why this is ^
            ZStack {
                if !self.shouldUseWPImage {
                    self.page.primaryColour
                } else {
                    Image("wallpaper-\(self.homeWallpaper)")
                }
            }
            .ignoresSafeArea(.all)
        )
        .onAppear(perform: self.actionOnAppear)
        .onChange(of: self.tasks) {
            self.actionOnAppear()
        }
        .onChange(of: self.outcomes) {
            self.actionOnAppear()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .navigationTitle(self.checklist != nil ? "Editing Checklist" : "New Checklist")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.actionOnSave()
                } label: {
                    Text("Save")
                }
                .disabled(self.label == "")
            }
        }
        .alert("Are you sure? This action is irreversible", isPresented: self.$isDeleteConfirmPresented) {
            Button("Yes", role: .destructive) {
                self.actionOnDelete()
            }
            Button("No", role: .cancel) {}
        }
        .sheet(isPresented: self.$isTaskSelectorPresented) {
            Widget.TaskSelector.Single(
                showing: self.$isTaskSelectorPresented,
                tasks: self.$tasks
            )
            .presentationBackground(Theme.cPurple)
        }
        .sheet(isPresented: self.$isOutcomeTaskSelectorPresented) {
            Widget.TaskSelector.Single(
                showing: self.$isOutcomeTaskSelectorPresented,
                tasks: self.$outcomes
            )
            .presentationBackground(Theme.cPurple)
        }
    }

    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        self.colour = self.checklist?.backgroundColour ?? .clear
        self.label = self.checklist?.label ?? ""
        self.overview = self.checklist?.overview ?? ""
        self.tasks = self.checklist?.tasks?.allObjects as? [LogTask] ?? []
        self.outcomes = self.checklist?.outcomes?.allObjects as? [LogTask] ?? []
        self.starred = self.checklist?.starred ?? false
    }

    /// Save handler. Fires when user taps Save button.
    /// - Returns: Void
    private func actionOnSave(shouldDismiss: Bool = true) -> Void {
        if self.checklist == nil {
            CoreDataChecklists(moc: self.state.moc).create(
                colour: self.colour.toStored(),
                created: self.state.date,
                label: self.label,
                lastUpdate: Date(),
                overview: self.overview,
                tasks: NSSet(array: self.tasks),
                outcomes: NSSet(array: self.outcomes)
            )
        } else {
            self.checklist!.colour = self.colour.toStored()
            self.checklist!.lastUpdate = Date()
            self.checklist!.label = self.label
            self.checklist!.overview = self.overview
            self.checklist!.tasks = NSSet(array: self.tasks)
            self.checklist!.outcomes = NSSet(array: self.outcomes)
            self.checklist!.starred = self.starred

            PersistenceController.shared.save()
        }

        if shouldDismiss {
            self.dismiss()
        }
    }

    /// Hard delete a Checklist
    /// - Returns: Void
    private func actionOnDelete() -> Void {
        if let list = self.checklist {
            self.state.moc.delete(list)
        }

        PersistenceController.shared.save()
        dismiss()
    }

    struct EditableTask: View {
        @EnvironmentObject private var state: AppState
        @Environment(\.dismiss) private var dismiss
        public var task: LogTask
        public var callback: (() -> Void)?
        public var shouldFocus: Bool = true
        @Binding public var tasks: [LogTask]
        @State private var text: String = ""
        @FocusState public var hasFocus: Bool

        var body: some View {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        TextField(self.task.title ?? "Edit me", text: self.$text)
                            .focused(self.$hasFocus)
                        Spacer()
                    }
                    .padding()
                    .background(.indigo)
                    HStack(spacing: 0) {
                        Button {
                            // @TODO: this doesn't quite work yet because the way I draw EditableTask's is stupid rn
                            if self.task.owner == nil {
                                /// Delete the object only if it isn't associated with an existing job or other entity
                                self.state.moc.delete(self.task)
                                self.dismiss()
                            } else {
                                /// Remove task from the checklist when associated with another entity
                                self.tasks.removeAll(where: {$0 == self.task})
                            }
                            PersistenceController.shared.save()
                        } label: {
                            Image(systemName: "minus.circle.fill")
                        }
                        .buttonStyle(.plain)
                        .font(.title2)
                    }
                    .padding([.leading, .trailing])
                    .padding([.top, .bottom], 8)
                    .foregroundStyle(.red)
                }
            }
            .onAppear {
                if self.shouldFocus {
                    self.hasFocus = true
                }
            }
            .onChange(of: self.hasFocus) {
                if !self.hasFocus {
                    self.callback?()

                    if !self.text.isEmpty {
                        self.task.title = self.text
                        PersistenceController.shared.save()
                    }
                }
            }
        }
    }

    struct Field: View {
        @EnvironmentObject private var state: AppState
        public var label: String
        @Binding public var value: String
        @FocusState public var hasFocus: Bool

        var body: some View {
            Button {
                self.hasFocus = true
            } label: {
                HStack {
                    Text(self.label)
                        .foregroundStyle(self.state.theme.tint)
                    TextField(self.label, text: self.$value)
                        .focused(self.$hasFocus)
                }
                .padding()
                .background(Theme.textBackground)
            }
            .buttonStyle(.plain)
            .clipShape(.rect(cornerRadius: 4))
        }
    }

    struct BooleanField: View {
        @EnvironmentObject private var state: AppState
        public var label: String
        public var icon: String = "star.fill"
        public var iconOff: String = "star"
        @Binding public var value: Bool
        @FocusState public var hasFocus: Bool

        var body: some View {
            Button {
                self.value.toggle()
            } label: {
                HStack {
                    Text(self.label)
                        .foregroundStyle(self.state.theme.tint)
                    Image(systemName: self.value ? self.icon : self.iconOff)
                }
                .padding()
                .background(Theme.textBackground)
            }
            .buttonStyle(.plain)
            .clipShape(.rect(cornerRadius: 4))
        }
    }
}
