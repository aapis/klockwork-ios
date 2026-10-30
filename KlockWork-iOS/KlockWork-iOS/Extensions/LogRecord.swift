//
//  LogRecord.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-24.
//

import SwiftUI

extension LogRecord {
    public var tcType: Tabs.Content.TCRecordType {
        if let _ = self.linkFromMessage {
            return .link
        }

        return .none
    }

    public var linkFromMessage: URL? {
        let linkRegex = /(https:\/\/[^ \n]+)/
        if let match = self.message?.firstMatch(of: linkRegex) {
            return URL(string: String(match.0))
        }

        return nil
    }
}
