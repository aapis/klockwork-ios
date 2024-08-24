//
//  PrimaryAssessmentGuide.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-22.
//

import SwiftUI

struct PrimaryAssessmentGuide: View {
    typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

    private let page: PageConfiguration.AppPage = .explore
    private let pa: PrimaryAssessment = PrimaryAssessment()
    @State private var current: Coordinates// = Coordinates()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            PrimaryAssessment.Views.SectionList(pa: self.pa, current: $current)
            PrimaryAssessment.Views.Progress(pa: self.pa, current: $current)
        }
        .background(self.page.primaryColour)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Primary Assessment Guide")
    }

    init() {
        self.current = Coordinates(section: self.pa.sections.first!.id, requirement: self.pa.sections.first!.requirements.first!.id)
    }
}

struct PrimaryAssessment {
    var type: ScenarioType = .medical
    let sections: [ScenarioSection] = [
        ScenarioSection(
            name: "Scene size up",
            requirements: [
                ScenarioRequirement(description: "Don BSI", importance: .critical),
                ScenarioRequirement(description: "Hazard assessment (see/hear/smell)", importance: .critical),
                ScenarioRequirement(description: "Note time, date, weather", importance: .normal),
                ScenarioRequirement(description: "How many patients?", importance: .normal),
                ScenarioRequirement(description: "Bystanders with information?", importance: .normal, notes: "Consider SAMPLE Hx"),
                ScenarioRequirement(description: "C/C?", importance: .normal),
                ScenarioRequirement(description: "Note Patient's general appearance", importance: .normal),
                ScenarioRequirement(description: "MOI?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "C-Spine",
            requirements: [
                ScenarioRequirement(description: "Assess for C-Spine injury", importance: .normal, notes: "If needed, delegate holding C-Spine to partner"),
            ]
        ),
        ScenarioSection(
            name: "LOC",
            requirements: [
                ScenarioRequirement(description: "Conscious, PPTE", importance: .normal),
                ScenarioRequirement(description: "Unconscious, AVPU", importance: .normal),
            ]
        ),
        ScenarioSection(
            name: "ABC (CAB if unconscious)"
        ),
        ScenarioSection(
            name: "Airway",
            requirements: [
                ScenarioRequirement(description: "Patent & clear", importance: .critical, notes: "Suction prn"),
                ScenarioRequirement(description: "If not, head-tilt chin-lift", importance: .normal),
                ScenarioRequirement(description: "Odours?", importance: .normal),
                ScenarioRequirement(description: "OPA/NPA?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Breathing",
            requirements: [
                ScenarioRequirement(description: "RRQ / RDE?", importance: .critical),
                ScenarioRequirement(description: "Administer O2 (NRB 15 LPM)", importance: .critical),
            ]
        ),
        ScenarioSection(
            name: "Circulation",
            requirements: [
                ScenarioRequirement(description: "Pulse RRQ?", importance: .critical),
                ScenarioRequirement(description: "Skin condition?", importance: .normal),
            ]
        ),
        ScenarioSection(
            name: "Deadly wet check"
        ),
        ScenarioSection(
            name: "Transport",
            requirements: [
                ScenarioRequirement(description: "Load & Go / Stay & Stabilize", importance: .critical)
            ]
        ),
        ScenarioSection(
            name: "Primary Head-to-toe"
        ),
        ScenarioSection(
            name: "Head",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Facial droop?", importance: .normal),
                ScenarioRequirement(description: "Eyes PERL?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Neck",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Medic alert jewelry?", importance: .normal),
                ScenarioRequirement(description: "Accessory muscle use?", importance: .normal),
                ScenarioRequirement(description: "JVD?", importance: .normal),
                ScenarioRequirement(description: "Trachea midline?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Chest",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Auscultate apics and bases for lung sounds", importance: .normal),
                ScenarioRequirement(description: "Percuss. Adventitious sounds?", importance: .normal),
                ScenarioRequirement(description: "SIMBA?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Abdomen",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain, scars or needle marks", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Feel for DRT in all quadrants", importance: .normal),
                ScenarioRequirement(description: "Nauseaous/recently vomited?", importance: .normal),
            ]
        ),
        ScenarioSection(
            name: "Pelvis",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain", importance: .normal),
                ScenarioRequirement(description: "Bleeding or discharge?", importance: .normal),
            ]
        ),
        ScenarioSection(
            name: "Lower extremities",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain, needle marks, medic alert", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Edema/discolouration?", importance: .normal),
                ScenarioRequirement(description: "CMS, test both simultaneously", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Upper extremities",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain, needle marks, medic alert", importance: .normal),
                ScenarioRequirement(description: "Pain located? OPQRST", importance: .normal),
                ScenarioRequirement(description: "Edema/discolouration?", importance: .normal),
                ScenarioRequirement(description: "CMS, test both simultaneously", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Back",
            requirements: [
                ScenarioRequirement(description: "Looking & feeling for injuries or pain", importance: .normal),
                ScenarioRequirement(description: "Sacral edema/scars?", importance: .normal)
            ]
        ),
        ScenarioSection(
            name: "Transport",
            requirements: [
                ScenarioRequirement(description: "Load & Go / Stay & Stabilize", importance: .critical)
            ]
        ),
        ScenarioSection(
            name: "Ambulance"
        ),
        ScenarioSection(
            name: "Vitals",
            requirements: [
                ScenarioRequirement(description: "BGL?", importance: .critical),
                ScenarioRequirement(description: "Sp02?", importance: .critical),
                ScenarioRequirement(description: "Pulse?", importance: .critical),
                ScenarioRequirement(description: "BP?", importance: .critical),
                ScenarioRequirement(description: "RR?", importance: .critical),
                ScenarioRequirement(description: "Temp?", importance: .critical),
                ScenarioRequirement(description: "Skin?", importance: .critical),
                ScenarioRequirement(description: "GCS?", importance: .critical)
            ]
        ),
        ScenarioSection(
            name: "Secondary"
        ),
        ScenarioSection(
            name: "Complete"
        ),
    ]

    enum ScenarioType {
        case medical, trauma
    }

    struct ScenarioSection: Identifiable {
        var id: UUID = UUID()
        var name: String
        var requirements: [ScenarioRequirement] = []
        // @TODO: some kind of boolean selection method (i.e. Unconscious? tap here, Conscious? tap here)
    }

    struct ScenarioRequirement: Identifiable, Equatable {
        var id: UUID = UUID()
        var description: String
        var importance: Importance
        var notes: String?

        // shim

        enum Importance {
            case normal, critical
        }
    }

    struct ScenarioCoordinates {
        var section: UUID?
        var requirement: UUID?
    }

    struct Views {
        struct Progress: View {
            typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

            @State public var pa: PrimaryAssessment
            @Binding public var current: Coordinates

            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    Button {
                        self.actionOnNext()
                    } label: {
                        HStack(alignment: .center) {
                            Text("Next")
                                .padding()
                        }
                    }
                }
            }
        }

        struct SectionList: View {
            typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

            @State public var pa: PrimaryAssessment
            @Binding public var current: Coordinates

            var body: some View {
                ScrollView(showsIndicators: false) {
                    ForEach(self.pa.sections, id: \.id) { section in
                        VStack(alignment: .leading, spacing: 1) {
                            HStack(alignment: .center) {
                                Text(section.name)
                                    .font(.headline)
                                Spacer()
                            }
                            .padding(8)
                            .foregroundStyle(current.section == section.id ? .white : .gray)
                            .background(current.section == section.id ? .blue : Theme.rowColour)

                            ForEach(section.requirements) { req in
                                HStack(alignment: .center) {
                                    Text(req.description)
                                    Spacer()
                                }
                                .padding(5)
                                .foregroundStyle(current.requirement == req.id ? .white : .gray)
                                .background(current.requirement == req.id ? .blue : Theme.rowColour)
                            }
                        }
                    }
                }
            }
        }
    }
}

extension PrimaryAssessment.Views.Progress {
    private func actionOnNext() -> Void {
        if let currentIndex = self.pa.sections.firstIndex(where: {$0.id == current.section}) {
            let nextIndex = self.pa.sections.index(after: currentIndex)
            if let nextSection = self.pa.sections.enumerated().filter({$0.offset == nextIndex}).first {
                if let currentSection = self.pa.sections.enumerated().filter({$0.offset == currentIndex}).first {
                    let lastRequirementInSection = currentSection.element.requirements.last
                    let currentRequirementIndex = currentSection.element.requirements.firstIndex(where: {$0.id == current.requirement}) ?? 0
                    let currentRequirement = currentSection.element.requirements.enumerated().filter({$0.offset == currentRequirementIndex}).first
                    let nextRequirementIndex = currentSection.element.requirements.index(after: currentRequirementIndex)
                    let nextRequirement = currentSection.element.requirements.enumerated().filter({$0.offset == nextRequirementIndex}).first
                    let nextSectionFirstRequirement = nextSection.element.requirements.first

                    if let nReq = nextRequirement?.element {
                        if nReq.id == lastRequirementInSection?.id {
                            current.section = nextSection.element.id
                            current.requirement = nextSectionFirstRequirement?.id
                            print("DERPO changed sections to \(current.section!)")
                            print("DERPO changed requirement to \(current.requirement!)")
                        } else {
                            current.requirement = nextRequirement?.element.id
                            print("DERPO changed requirement to \(current.requirement!)")
                        }
                    }
                }
            }
        }
    }
}
