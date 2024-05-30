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
    @State public var date: Date = Date()

    var body: some View {
        TabView {
            Today(date: $date)
            .tabItem {
                Image(systemName: "tray")
                Text("Today")
            }
            Explore(date: $date)
            .tabItem {
                Image(systemName: "globe.desk")
                Text("Explore")
            }
            Planning(date: $date)
            .tabItem {
                Image(systemName: "hexagon")
                Text("Planning")
            }
            
            Find(date: $date)
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Find")
            }
        }
        .tint(.yellow)
    }
}
