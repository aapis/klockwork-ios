//
//  LinkContextMenu.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-24.
//
import SwiftUI

// MARK: Feed.UI.LinkContextMenu
struct LinkContextMenu: View {
    @Environment(\.openURL) var openURL
    public var link: Hyperlink
    public var buttonView: AnyView?
    public var buttonAction: (() -> Void)? = nil

    var body: some View {
        Menu {
            Text(StringHelper.truncate(self.link.uri?.absoluteString, len: 20))
                .lineLimit(1)
                .font(.caption)
                .foregroundStyle(.gray)
            Divider()
            Button {
                if let uri = self.link.uri {
                    self.openURL(uri)
                }
                self.buttonAction?()
            } label: {
                Label("Open in browser", systemImage: "globe")
            }
            Button {
                UIPasteboard.general.string = self.link.uri?.absoluteString ?? ""
            } label: {
                Label("Copy URL", systemImage: "document.on.document")
            }
        } label: {
            if let view = self.buttonView {
                view
            } else {
                HStack {
                    HStack(alignment: .top) {
                        Image(systemName: "link")
                            .foregroundStyle(Theme.lightWhite)
                        Text(self.link.uri?.absoluteString ?? "Invalid link")
                            .multilineTextAlignment(.leading)
                    }
                    Spacer()
                }
                .padding(8)
                .font(.system(size: 14))
            }
        }
    }
}
