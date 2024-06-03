//
//  Legend.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct Legend: View {
    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    }

    var body: some View {
        GridRow {
            VStack(alignment: .leading) {
                GridRow {
                    Text("Legend")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.gray)
                }
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(ActivityWeight.allCases, id: \.self) { assessment in
                        Row(assessment: assessment)
                    }
                }
            }
        }
        .padding()
        .background(Theme.textBackground)
    }
}

extension Legend {
    struct Row: View {
        public let assessment: ActivityWeight

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(assessment.colour)
                        .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: .gray)

                    Text(assessment.label)
                        .font(.caption)
                }
            }
        }
    }
}
