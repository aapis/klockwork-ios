//
//  Logo.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-01.
//

import SwiftUI

struct Logo: View {
    @EnvironmentObject private var state: AppState
    public var title: String? = nil
    @State public var isVersionShowing: Bool = false
    private let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ?? "KlockWork"
    private let appVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0.1"

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "clock.circle.fill")
                .symbolRenderingMode(.hierarchical)
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 2) {
                Text(self.title == nil ? self.appName : self.title!)
                    .font(.headline)
                if isVersionShowing {
                    Text("Version \(self.appVersion)")
                        .font(.caption2)
                        .textCase(.uppercase)
                        .foregroundStyle(.white)
                }
            }
        }
        .bold()
        .foregroundStyle(self.state.theme.tint)
        .padding([.leading, .bottom], 10)
    }
}
