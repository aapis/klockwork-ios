//
//  PageActionBar.Create.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-14.
//
import SwiftUI

extension PageActionBar {
    struct Create: View {
        @EnvironmentObject private var state: AppState
        public let page: PageConfiguration.AppPage
        @Binding public var isSheetPresented: Bool
        @Binding public var job: Job?
        public let onSave: () -> Void

        var body: some View {
            PageActionBarSingleAction(page: self.page, isSheetPresented: $isSheetPresented, job: $job, onSave: self.onSave)
        }
    }
}
