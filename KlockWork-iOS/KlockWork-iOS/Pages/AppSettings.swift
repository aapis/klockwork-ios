//
//  AppSettings.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-22.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct AppSettings: View {
    private let page: PageConfiguration.AppPage = .settings
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                List {

                }
            }
        }
        .background(self.page.primaryColour)
    }
}
