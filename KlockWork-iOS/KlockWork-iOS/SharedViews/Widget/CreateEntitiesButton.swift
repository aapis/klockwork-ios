//
//  CreateEntitiesButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-12.
//

import SwiftUI

struct CreateEntitiesButton: View {
    @EnvironmentObject private var state: AppState
    @State public var date: Date = Date()
    public var isViewModeSelectorVisible: Bool = false

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Today.AddButton()
            if isViewModeSelectorVisible {
                Today.ViewModeSelector()
            }

            Forecast(date: self.state.date, isForecastMember: false)
                .background(Theme.base.opacity(0.2).blendMode(.softLight))
                .clipShape(.rect(topLeadingRadius: 16, topTrailingRadius: 16))
                .padding([.leading, .trailing], 8)
//                    .overlay(
//                        DatePicker(
//                            "Today",
//                            selection: $date,
//                            displayedComponents: [.date]
//                        )
//                        .datePickerStyle(.graphical)
//                    )

            // @TODO: implement settings page
//            NavigationLink {
//                AppSettings()
//            } label: {
//                Image(systemName: "gearshape")
//                    .font(.title)
//            }
        }
//        .padding([.leading, .trailing], 8)
//        .background(Theme.base.opacity(0.2).blendMode(.softLight))
//        .clipShape(.rect(topLeadingRadius: 16))
        .onChange(of: date) {
            self.state.date = date
        }
        .onChange(of: self.state.date) {
            date = self.state.date
        }
    }
}
