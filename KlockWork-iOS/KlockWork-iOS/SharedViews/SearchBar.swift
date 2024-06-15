//
//  SearchBar.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-24.
//

import SwiftUI
import CoreData

struct SearchBar: View {
    typealias EntityType = PageConfiguration.EntityType

    enum Field {
        // Apparently you need to use an existing UITextContentType
        case organizationName
    }

    public let placeholder: String
    public let items: [NSManagedObject]
    public let type: EntityType

    @State private var text: String = ""
    @State private var sheetPresented: Bool = false
    @FocusState public var focused: Field?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Bar(placeholder: placeholder, text: $text, sheetPresented: $sheetPresented, focused: _focused)
            }
        }
        .sheet(isPresented: $sheetPresented, onDismiss: actionOnDismiss, content: {Sheet(placeholder: placeholder, text: $text, items: items, type: type)})
    }
}

extension SearchBar {
    private func actionOnDismiss() -> Void {
        focused = nil
        text = ""
    }
}

extension SearchBar {
    struct Bar: View {
        public let placeholder: String
        @Binding public var text: String
        @Binding public var sheetPresented: Bool
        @FocusState public var focused: Field?

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(placeholder)
                    )
                    .disableAutocorrection(false)
                    .focused($focused, equals: SearchBar.Field.organizationName)
                    .textContentType(.organizationName)
                    .submitLabel(.search)
                    .textSelection(.enabled)
                    .lineLimit(1)
                    .onSubmit(actionOnSubmit)

                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.yellow)
                }
            }
            .listRowBackground(Theme.textBackground)
        }
    }

    struct Sheet: View {
        public let placeholder: String
        @Binding public var text: String
        public var items: [NSManagedObject]
        public var type: EntityType
        @State public var sheetPresented: Bool = true

        var body: some View {
            NavigationStack {
                VStack {
                    List {
                        Section("Searching: \(type.label)") {
                            Bar(placeholder: placeholder, text: $text, sheetPresented: $sheetPresented)
                        }

                        Section {
                            switch type {
                            case .records:
                                let group = items as! [LogRecord]
                                ForEach(group.filter {
                                    $0.alive == true && $0.message!.lowercased().contains(text.lowercased())
                                }) { row in
                                    NavigationLink {
                                        RecordDetail(record: row)
                                    } label: {
                                        Text(row.message!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .jobs:
                                let group = items as! [Job]
                                ForEach(group.filter {
                                    $0.alive == true && ($0.jid.string.starts(with: text.lowercased()) || (($0.title?.lowercased().contains(text.lowercased())) != nil))
                                }) { row in
                                    NavigationLink {
                                        JobDetail(job: row)
                                            .toolbar {
                                                ToolbarItem(placement: .topBarTrailing) {
                                                    Button("Save") {
                                                        PersistenceController.shared.save()
                                                    }
                                                }
                                            }
                                    } label: {
                                        Text(row.title ?? row.jid.string)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .tasks:
                                let group = items as! [LogTask]
                                ForEach(group.filter {
                                    $0.content!.lowercased().contains(text.lowercased())
                                }) { row in
                                    NavigationLink {
                                        TaskDetail(task: row)
                                    } label: {
                                        Text(row.content!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .notes:
                                let group = items as! [Note]
                                ForEach(group.filter {
                                    $0.alive == true && ($0.title!.lowercased().contains(text.lowercased()) || $0.body!.lowercased().contains(text.lowercased()))
                                }) { row in
                                    NavigationLink {
                                        NoteDetail(note: row, isSheetPresented: $sheetPresented)
                                    } label: {
                                        Text(row.title!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .companies:
                                let group = items as! [Company]
                                ForEach(group.filter {$0.alive == true && $0.name!.lowercased().contains(text.lowercased())}) { row in
                                    NavigationLink {
                                        CompanyDetail(company: row)
                                    } label: {
                                        Text(row.name!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .people:
                                let group = items as! [Person]
                                ForEach(group.filter {
                                    $0.name!.lowercased().contains(text.lowercased())
                                }) { row in
                                    NavigationLink {
                                        PersonDetail(person: row)
                                    } label: {
                                        Text(row.name!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            case .projects:
                                let group = items as! [Project]
                                ForEach(group.filter {
                                    $0.alive == true && $0.name!.lowercased().contains(text.lowercased())
                                }) { row in
                                    NavigationLink {
                                        ProjectDetail(project: row)
                                    } label: {
                                        Text(row.name!)
                                    }
                                    .listRowBackground(Theme.textBackground)
                                }
                            }
                        }
                    }
                }
                .background(Theme.cGreen)
                .scrollContentBackground(.hidden)
            }
        }
    }
}

extension SearchBar.Bar {
    private func actionOnSubmit() -> Void {
        sheetPresented = (focused == .organizationName)
    }
}
