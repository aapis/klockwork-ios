//
//  Legend.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-03.
//

import SwiftUI

struct Legend: View {
    @State private var isSheetPresented: Bool = false
    private var columns: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 1), count: 3)
    }

    var body: some View {
        GridRow {
            VStack(alignment: .leading) {
                GridRow {
                    HStack(alignment: .center) {
                        LegendLabel(label: "Legend")

                        // Legend settings/gear button
                        Button {
                            self.isSheetPresented.toggle()
                        } label: {
                            HStack {
                                Spacer()
                                Image(systemName: "gear")
                            }
                        }
                        .foregroundStyle(.yellow)
                        .help("Modify assessment factors")
                    }
                }
                .padding([.bottom], 10)
                LazyVGrid(columns: columns, alignment: .leading) {
                    ForEach(ActivityWeight.allCases, id: \.self) { assessment in
                        Row(assessment: assessment)
                    }
                    RowBasic(colour: .yellow, label: "Today")
                    RowBasic(colour: .blue, label: "Selected")
                }
            }
        }
        .padding()
        .background(Theme.textBackground)
        .sheet(isPresented: $isSheetPresented) {
            AssessmentTypeIntersitial()
        }
    }
}

extension Legend {
    struct Row: View {
        public let assessment: ActivityWeight

        var body: some View {
            RowBasic(colour: assessment.colour, label: assessment.label)
        }
    }

    struct RowBasic: View {
        public let colour: Color
        public let label: String

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    Rectangle()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(colour)
                        .border(width: 1, edges: [.top, .bottom, .leading, .trailing], color: .gray)

                    Text(label)
                        .font(.caption)
                }
            }
        }
    }
}
