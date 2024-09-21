//
//  CreateEntitiesButton.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-09-12.
//

import SwiftUI

struct CreateEntitiesButton: View {
    @EnvironmentObject private var state: AppState
    @State public var date: Date = DateHelper.startOfDay()
    public var isViewModeSelectorVisible: Bool = false
    public var page: PageConfiguration.AppPage = .planning

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            AddButton()
            if isViewModeSelectorVisible {
                ViewModeSelector()
            }

//            Button {
//                if self.state.today.tableButtonMode == .items {
//                    self.state.today.tableButtonMode = .actions
//                } else {
//                    self.state.today.tableButtonMode = .items
//                }
//            } label: {
//                Image(systemName: "filemenu.and.selection")
//                    .font(.title)
//            }
//            .padding(8)
//            .background(.white.opacity(0.1))
//            .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))

            Forecast(date: DateHelper.startOfDay(self.state.date), isForecastMember: false, page: self.page)
                .background(.white.opacity(0.1))
                .clipShape(.rect(topLeadingRadius: 5, topTrailingRadius: 5))
                .padding([.trailing], 8)

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
