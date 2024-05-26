//
//  Find.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-26.
//

import SwiftUI

struct Find: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Header()
                ZStack(alignment: .bottomLeading) {
//                        Tabs(job: $job, selected: $selected, date: $date)
                    Content()
                    LinearGradient(colors: [.black, .clear], startPoint: .bottom, endPoint: .top)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                Editor()
                Spacer()
                .frame(height: 1)
            }
            .background(Theme.cPurple)
        }
    }
}

extension Find {
    struct Header: View {
        var body: some View {
            Text("Header")
        }
    }

    struct Content: View {
        var body: some View {
            Text("Content")
        }
    }

    struct Editor: View {
        var body: some View {
            Text("Editor")
        }
    }
}
