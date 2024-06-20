//
//  ErrorView.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-13.
//
import SwiftUI

struct ErrorView: View {
    @EnvironmentObject private var state: AppState
    public let icon: String
    public let message: String
    public let redirectTarget: AnyView
    private let page: PageConfiguration.AppPage = .error

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 30) {
                Spacer()
                Image(systemName: self.icon)
                    .font(.system(size: 75))
                    .foregroundStyle(.gray)

                Text(self.message)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20))

                NavigationLink {
                    redirectTarget
                } label: {
                    HStack {
                        Text("Take me there")
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                .background(page.buttonBackgroundColour)
                .clipShape(.capsule(style: .continuous))
                .foregroundStyle(.white)
                Spacer()
            }
            .frame(maxWidth: 300)
        }
        .presentationBackground(page.primaryColour)
    }
}

struct PresentableErrorView: View {
    @EnvironmentObject private var state: AppState
    public let icon: String
    public let message: String
    public let redirectTarget: AnyView
    @Binding public var isPresented: Bool
    private let page: PageConfiguration.AppPage = .error

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 30) {
                Spacer()
                Image(systemName: self.icon)
                    .font(.system(size: 75))
                    .foregroundStyle(.gray)

                Text(self.message)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 20))

                NavigationLink {
                    redirectTarget
                } label: {
                    HStack {
                        Text("Take me there")
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                .background(page.buttonBackgroundColour)
                .clipShape(.capsule(style: .continuous))
                .foregroundStyle(.white)

                Button {
                    self.isPresented.toggle()
                } label: {
                    Text("Close")
                }
                Spacer()
            }
            .frame(maxWidth: 300)
        }
        .presentationBackground(page.primaryColour)
    }
}

extension ErrorView {
    struct MissingProject: View {
        @EnvironmentObject private var state: AppState
        @Binding public var isPresented: Bool

        var body: some View {
            PresentableErrorView(
                icon: "square.3.layers.3d.slash",
                message: "You need to create a Project first",
                redirectTarget: AnyView(ProjectDetail(project: DefaultObjects.project)),
                isPresented: $isPresented
            )
        }
    }

    struct MissingCompany: View {
        @EnvironmentObject private var state: AppState
        @Binding public var isPresented: Bool

        var body: some View {
            PresentableErrorView(
                icon: "square.3.layers.3d.slash",
                message: "You need to create a Company and a Project first",
                redirectTarget: AnyView(CompanyDetail(company: DefaultObjects.company)),
                isPresented: $isPresented
            )
        }
    }
}

#Preview("Error.MissingCompany") {
    ErrorView(
        icon: "square.3.layers.3d.slash",
        message: "You need to create a Company and a Project first",
        redirectTarget: AnyView(EmptyView())
    )
}

#Preview("Error.MissingProject") {
    ErrorView(
        icon: "square.3.layers.3d.slash",
        message: "You need to create a Project first",
        redirectTarget: AnyView(EmptyView())
    )
}
