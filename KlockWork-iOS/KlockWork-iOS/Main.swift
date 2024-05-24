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
            // @TODO: rebuild and uncomment
//            Home()
//            .tabItem {
//                Image(systemName: "house")
//                Text("Home")
//            }
            Today()
            .tabItem {
                Image(systemName: "tray")
                Text("Today")
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
        .tint(.red)
    }
}
