//
//  PlanTabs.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-04.
//

import SwiftUI

struct PlanTabs: View {
    typealias PlanType = PageConfiguration.PlanType

    public var inSheet: Bool
    @Environment(\.managedObjectContext) var moc
    @Binding public var job: Job?
    @Binding public var selected: PlanType
    @Binding public var date: Date
    public var content: AnyView? = nil
    public var buttons: AnyView? = nil
    public var title: AnyView? = nil
    static public let animationDuration: Double = 0.2

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if buttons == nil {
                Buttons(inSheet: inSheet, job: $job, selected: $selected)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                buttons
            }

            if title == nil {
//                MiniTitleBar(selected: $selected)
//                    .border(width: 1, edges: [.bottom], color: .yellow)
            } else {
                title
            }

            if content == nil {
                Content(inSheet: inSheet, job: $job, selected: $selected, date: $date)
                    .swipe([.left, .right]) { swipe in
                        self.actionOnSwipe(swipe)
                    }
            } else {
                content
            }
        }
        .background(.clear)
        .onChange(of: job) {
            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                selected = .daily
            }
        }
    }
}

extension PlanTabs {
    public func actionOnSwipe(_ swipe: Swipe) -> Void {
        let tabs = PlanType.allCases
        if var selectedIndex = (tabs.firstIndex(of: self.selected)) {
            if swipe == .left {
                if selectedIndex <= tabs.count - 2 {
                    selectedIndex += 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[0]
                }
            } else if swipe == .right {
                if selectedIndex > 0 && selectedIndex <= tabs.count {
                    selectedIndex -= 1
                    self.selected = tabs[selectedIndex]
                } else {
                    self.selected = tabs[tabs.count - 1]
                }
            }
        }
    }
}

extension PlanTabs {
    struct Buttons: View {
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType

        var body: some View {
            HStack(alignment: .center, spacing: 1) {
                ForEach(PlanType.allCases, id: \.self) { page in
                    VStack {
                        Button {
                            withAnimation(.easeIn(duration: Tabs.animationDuration)) {
                                selected = page
                            }
                        } label: {
                            page.icon
                            .frame(maxHeight: 20)
                            .padding(14)
                            .background(page == selected ? .white : .clear)
                            .foregroundStyle(page == selected ? Theme.cPurple : .gray)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
            }
            .background(Theme.textBackground)
            .frame(height: 50)
        }
    }

    struct Content: View {
        public var inSheet: Bool
        @Binding public var job: Job?
        @Binding public var selected: PlanType
        @Binding public var date: Date

        var body: some View {
            switch selected {
            case .daily:
                Daily()
            case .feature:
                Feature()
            }
        }
    }
}

extension PlanTabs {
    struct Daily: View {
        var body: some View {
            Text("Daily")
        }
    }

    struct Feature: View  {
        var body: some View {
            Text("Feature")
        }
    }
}
