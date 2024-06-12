//
//  AssessmentThresholdForm.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-06-10.
//

import SwiftUI

struct AssessmentThresholdForm: View {
    @Environment(\.managedObjectContext) var moc
    @Binding public var assessmentStatuses: [AssessmentThreshold]
    @State private var isResetAlertPresented: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Divider().background(.gray).frame(height: 1)
                ZStack(alignment: .topLeading) {
                    List {
                        Section {
                            ForEach(assessmentStatuses.sorted(by: {$0.defaultValue < $1.defaultValue})) { status in
                                Row(status: status)
                            }
                        }

                        Section("About") {
                            ForEach(ActivityWeight.allCases, id: \.self) { weight in
                                HStack(spacing: 5) {
                                    Text(weight.emoji)
                                    Text("\(weight.label): \(weight.helpText)")
                                    Spacer()
                                }
                                .foregroundStyle(.gray)
                            }
                        }
                        .listRowBackground(Theme.textBackground)
                    }

                    LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                        .frame(height: 50)
                        .opacity(0.1)
                }

                Spacer()
            }
        }
        .background(Theme.cGreen)
        .scrollContentBackground(.hidden)
        .navigationTitle("Modify Status")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.textBackground.opacity(0.7), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear(perform: actionOnAppear)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.isResetAlertPresented.toggle()
                } label: {
                    Text("Reset")
                }
                .alert("Reset to default values? No data will be lost.", isPresented: $isResetAlertPresented) {
                    Button("Yes", role: .destructive) {
                        self.assessmentStatuses = CDAssessmentThreshold(moc: self.moc).recreateAndReturn()
                    }
                    Button("No", role: .cancel) {}
                }
            }
        }
    }
}

extension AssessmentThresholdForm {
    struct Row: View {
        @Environment(\.managedObjectContext) var moc
        public let status: AssessmentThreshold
        @State private var value: Int = 0
        @State private var colour: Color = .clear
        @State private var emoji: String = "🏖️"
        private var range: [Int] {
            return Array(stride(from: 0, to: 20, by: 1)) + Array(stride(from: 20, to: 49, by: 5)) + Array(stride(from: 50, to: 101, by: 10))
        }

        var body: some View {
            VStack {
                HStack(alignment: .center, spacing: 5) {
                    // A clear day is always going to be 0
                    if status.label != "Clear" {
                        ColorPicker("Choose a colour for this status", selection: $colour, supportsOpacity: false)
                            .labelsHidden()
                        Spacer()
                        Picker("\(status.emoji!) \(status.label!)", selection: $value) {
                            ForEach(range, id: \.self) {Text($0.string).tag(Int($0))}
                        }
                    } else {
                        Text("\(status.emoji ?? "🏖️") \(status.label ?? "Clear")")
                        Spacer()
                        Text(String(0))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .listRowBackground(colour)
            .onAppear(perform: actionOnAppear)
            .onChange(of: value) {
                self.actionOnSubmit()
            }
            .onChange(of: colour) {
                self.actionOnChangeColour()
            }
        }
    }
}

extension AssessmentThresholdForm {
    /// Determine the threshold values by either creating new ones based on ActivityWeight data, or by querying the database
    /// - Returns: Void
    private func actionOnAppear() -> Void {
//        self.assessmentStatuses = CDAssessmentThreshold(moc: self.moc).all()
    }
}

extension AssessmentThresholdForm.Row {
    /// Onload handler
    /// - Returns: Void
    private func actionOnAppear() -> Void {
        if status.value > 0 {
            value = Int(status.value)
        } else {
            value = Int(status.defaultValue)
        }

        if let c = status.colour {
            colour = Color.fromStored(c)
        }
    }
    
    /// On submit handler
    /// - Returns: Void
    private func actionOnSubmit() -> Void {
        status.value = Int64(value)
        PersistenceController.shared.save()
        self.actionOnAppear()
    }
    
    /// Colour picker callback, saves colour choice
    /// - Returns: Void
    private func actionOnChangeColour() -> Void {
        status.colour = colour.toStored()
        PersistenceController.shared.save()
        self.actionOnAppear()
    }
}
