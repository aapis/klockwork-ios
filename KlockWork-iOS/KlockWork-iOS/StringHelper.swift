//
//  StringHelper.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-10-24.
//
import SwiftUI

class StringHelper {
    /// Truncates text to a certain length
    /// - Returns: String
    static public func truncate(_ string: String?, len: Int = 100) -> String {
        if let str = string {
            if len == -1 {
                return str
            }
            if str.count > len {
                let i = str.index(str.startIndex, offsetBy: len)
                let description = String(str[...i])//.trimmingCharacters(in: .whitespacesAndNewlines)

                return description + "..."
            } else {
                return str
            }
        }

        return ""
    }

    /// Truncates links to a certain length
    /// - Returns: String
    static public func truncateLink(_ string: String?, len: Int = 100) -> String {
        if let str = string {
            if len == -1 {
                return str
                    .replacingOccurrences(of: "https?://(www.)?", with: "", options: .regularExpression)
            }
            if str.count > len {
                let i = str.index(str.startIndex, offsetBy: len)
                let description = String(str[...i])
                //.trimmingCharacters(in: .whitespacesAndNewlines)
                    .replacingOccurrences(of: "https?://(www.)?", with: "", options: .regularExpression)

                return description + "..."
            } else {
                return str
                    .replacingOccurrences(of: "https?://(www.)?", with: "", options: .regularExpression)
            }
        }

        return ""
    }
}
