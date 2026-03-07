//
//  ChecklistActivity.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-02-24.
//

import SwiftUI

struct ChecklistActivity: View {
    @EnvironmentObject private var state: AppState
    public var page: PageConfiguration.AppPage = .explore
    @AppStorage("home.backgroundColour") private var homeBackgroundColourChoice: Int = 0
    @AppStorage("home.backgroundWallpaper") private var homeWallpaper: String = ""
    @AppStorage("home.shouldUseWPImage") private var shouldUseWPImage: Bool = false
    @FetchRequest private var checklists: FetchedResults<Checklist>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 1) {
                    if self.checklists.count > 0 {
                        ForEach(self.checklists, id: \.self) { list in
                            NavigationLink {
//                                ChecklistDetail(checklist: list)
                                Widget.Tasks.ChecklistView(checklist: list, inSheet: false)
                            } label: {
                                HStack {
                                    if list.starred {
                                        Image(systemName: "star.fill")
                                            .symbolRenderingMode(.hierarchical)
                                    }
                                    Text(list.label ?? "_INVALID_LIST_LABEL")
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .bold()
                                        .opacity(0.3)
                                }
                                .padding()
                                .background(list.backgroundColour)
                                .foregroundStyle(list.backgroundColour.isBright() ? Theme.base : .white)
                            }
                        }
                    } else {
                        Text("You haven't made any checklists yet")
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("Checklists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            NavigationLink {
                ChecklistDetail()
            } label: {
                Image(systemName: "plus")
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .background(
            ZStack {
                if !self.shouldUseWPImage {
                    self.page.primaryColour
                } else {
                    Image("wallpaper-\(self.homeWallpaper)")
                }
            }
            .ignoresSafeArea(.all)
        )
    }

    init() {
        _checklists = CoreDataChecklists.fetch(
            with: NSPredicate(
                format: "created < %@",
                Date.distantFuture as CVarArg
            ),
            sort: [NSSortDescriptor(keyPath: \Checklist.starred, ascending: false)]
        )
    }
}
