//
//  GlasgowComaScale.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-18.
//

import SwiftUI

// @TODO: this should be part of a whole different app
struct GlasgowComaScaleCalculator: View {
    private let page: PageConfiguration.AppPage = .explore
    @State private var score: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Scoreboard(score: $score)
            ZStack(alignment: .topLeading) {
                ScrollView(showsIndicators: false) {
                    Rulesboard(score: $score)
                }
            }
            .padding()
        }
        .toolbar(.hidden)
        .background(self.page.primaryColour)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("GCS Calculator")
    }

    struct Rulesboard: View {
        private let behaviours: [GCSBehaviour] = [
            GCSBehaviour(
                name: "Eye opening response",
                type: .eye,
                responses: [
                    GCSBehaviourResponse(response: "Spontaneously", score: 4, type: .eye),
                    GCSBehaviourResponse(response: "To speech", score: 3, type: .eye),
                    GCSBehaviourResponse(response: "To pain", score: 2, type: .eye),
                    GCSBehaviourResponse(response: "No response", score: 1, type: .eye),
                ]
            ),
            GCSBehaviour(
                name: "Best verbal response",
                type: .verbal,
                responses: [
                    GCSBehaviourResponse(response: "Oriented to time, place, person", score: 5, type: .verbal),
                    GCSBehaviourResponse(response: "Confused", score: 4, type: .verbal),
                    GCSBehaviourResponse(response: "Inappropriate words", score: 3, type: .verbal),
                    GCSBehaviourResponse(response: "Incomprehensible sounds", score: 2, type: .verbal),
                    GCSBehaviourResponse(response: "No response", score: 1, type: .verbal)
                ]
            ),
            GCSBehaviour(
                name: "Best motor response",
                type: .motor,
                responses: [
                    GCSBehaviourResponse(response: "Obeys commands", score: 6, type: .motor),
                    GCSBehaviourResponse(response: "Moves to localized pain", score: 5, type: .motor),
                    GCSBehaviourResponse(response: "Flexion withdrawl from pain", score: 4, type: .motor),
                    GCSBehaviourResponse(response: "Abnormal flexion (decorticate)", score: 3, type: .motor),
                    GCSBehaviourResponse(response: "Abnormal extension (decerebrate)", score: 2, type: .motor),
                    GCSBehaviourResponse(response: "No response", score: 1, type: .motor)
                ]
            )
        ]
        @Binding public var score: Int
        @State private var selected: [GCSSelectedBehaviour] = []

        var body: some View {
            ForEach(self.behaviours) { behaviour in
                VStack(alignment: .leading, spacing: 1) {
                    HStack {
                        Text(behaviour.name)
                            .font(.headline)
                        Spacer()
                    }
                    Divider().background(.clear).frame(height: 8)

                    ForEach(behaviour.responses) { resp in
                        Button {
                            if self.selected.contains(where: {$0.value == resp.type}) {
                                self.selected.removeAll(where: {$0.value == resp.type})
                            }
                            self.selected.append(GCSSelectedBehaviour(key: resp.id, value: resp.type, score: resp.score))
                            self.calculateScore()
                        } label: {
                            HStack {
                                Text(resp.response)
                                Spacer()
                                Text(String(resp.score))
                            }
                            .padding(8)
                            .foregroundStyle(self.selected.contains(where: {$0.key == resp.id}) ? .white : .gray)
                            .background(self.selected.contains(where: {$0.key == resp.id}) ? .blue : Theme.rowColour)
                        }
                    }
                    Divider().background(.clear).frame(height: 8)
                }
            }
        }
    }

    struct Scoreboard: View {
        private let page: PageConfiguration.AppPage = .explore
        @Binding public var score: Int

        var body: some View {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Glasgow Coma Score")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Image(systemName: "\(self.score).circle")
                        .font(.title)
                }
                .padding()

                ZStack(alignment: .topLeading) {
                    self.page.primaryColour
                    LinearGradient(colors: [Theme.base.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom)
                }
                .frame(height: 10)
            }
            .background(self.score == 0 ? Theme.rowColour : self.score < 9 ? .red : self.score < 15 ? .orange : .green)
        }
    }

    enum GCSBehaviourType {
        case eye, verbal, motor
    }

    struct GCSSelectedBehaviour {
        var key: UUID
        var value: GCSBehaviourType
        var score: Int
    }

    struct GCSBehaviour: Identifiable {
        var id: UUID = UUID()
        var name: String
        var type: GCSBehaviourType
        var responses: [GCSBehaviourResponse] = []
    }

    struct GCSBehaviourResponse: Identifiable {
        var id: UUID = UUID()
        var response: String
        var score: Int
        var type: GCSBehaviourType
    }
}

extension GlasgowComaScaleCalculator.Rulesboard {
    /// Calculate the score by counting up the selected items' score values
    /// - Returns: Void
    private func calculateScore() -> Void {
        self.score = 0
        for chosen in selected {
            self.score += chosen.score
        }
    }
}
