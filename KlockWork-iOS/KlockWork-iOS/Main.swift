//
//  ContentView.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Main: View {
    @Environment(\.managedObjectContext) var moc

    var body: some View {
        TabView {
            Today()
            .tabItem {
                Image(systemName: "tray")
                Text("Today")
            }
            Explore()
            .tabItem {
                Image(systemName: "globe.desk")
                Text("Explore")
            }
            Planning()
            .tabItem {
                Image(systemName: "hexagon")
                Text("Planning")
            }
            
            AppSettings()
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
        }
        .tint(.cyan)
    }
}
