//
//  PrimaryAssessmentGuide.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-08-22.
//

import SwiftUI

struct PrimaryAssessmentGuide: View {
    typealias Coordinates = PrimaryAssessment.ScenarioCoordinates
    typealias PAType = PrimaryAssessment.ScenarioType

    @Environment(\.colorScheme) var colorScheme
    private let page: PageConfiguration.AppPage = .explore
    private let pa: PrimaryAssessment = PrimaryAssessment()
    @State private var current: Coordinates// = Coordinates()
    @State private var type: PAType = .medical

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundStyle(.gray)
                Text("PA Guide")
                Spacer()
            }
            .font(.largeTitle)
            .fontWeight(.bold)
            .padding([.leading, .top, .bottom])

            HStack(alignment: .center, spacing: 0) {
                ForEach(PAType.allCases, id: \.hashValue) { incidentType in
                    HStack {
                        Spacer()
                        Button {
                            self.type = incidentType
                        } label: {
                            Text(incidentType.label)
                                .padding()
                        }
                        Spacer()
                    }
                    .background(self.type == incidentType ? incidentType.colour : .black.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                PrimaryAssessment.Views.SectionList(pa: self.pa, current: $current, type: $type)
//                    PrimaryAssessment.Views.Progress(pa: self.pa, current: $current)
//                        .background(type.colour)
            }
        }
        .foregroundStyle(.black)
        .background(.white)
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Primary Assessment Guide")
        .toolbar(.hidden)
    }

    init() {
        self.current = Coordinates()
    }
}

struct PrimaryAssessment {
    var type: ScenarioType = .medical
    var scenarios: [Scenario] = [
        Scenario(
            type: .medical,
            sections: [
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
                        ScenarioRequirement(description: "BGL?", importance: .normal),
                        ScenarioRequirement(description: "Sp02?", importance: .normal),
                        ScenarioRequirement(description: "Pulse?", importance: .normal),
                        ScenarioRequirement(description: "BP?", importance: .normal),
                        ScenarioRequirement(description: "RR?", importance: .normal),
                        ScenarioRequirement(description: "Temp?", importance: .normal),
                        ScenarioRequirement(description: "Skin?", importance: .normal),
                        ScenarioRequirement(description: "GCS?", importance: .normal)
                    ]
                ),
                ScenarioSection(
                    name: "Secondary"
                ),
                ScenarioSection(
                    name: "Complete"
                ),
            ]
        ),
        Scenario(
            type: .trauma,
            sections: [
                ScenarioSection(
                    name: "Scene size up",
                    requirements: [
                        ScenarioRequirement(description: "Don BSI", importance: .critical),
                        ScenarioRequirement(description: "Hazard assessment (see/hear/smell)", importance: .critical),
                        ScenarioRequirement(description: "How many patients?", importance: .normal),
                        ScenarioRequirement(description: "Request backup", importance: .normal),
                        ScenarioRequirement(description: "MOI?", importance: .critical)
                    ]
                ),
                ScenarioSection(
                    name: "Initial assessment"
                ),
                ScenarioSection(
                    name: "Approach",
                    requirements: [
                        ScenarioRequirement(description: "Bystanders with information?", importance: .normal),
                        ScenarioRequirement(description: "Patient's general appearance?", importance: .normal),
                        ScenarioRequirement(description: "Obvious injuries/life threatening bleeding?", importance: .normal),
                    ]
                ),
                ScenarioSection(
                    name: "C-Spine",
                    requirements: [
                        ScenarioRequirement(description: "ACTION take initial c-spine control", importance: .critical),
                        ScenarioRequirement(description: "Is c-spine stabilization required?", importance: .normal),
                        ScenarioRequirement(description: "IF no significant signs/symptoms, release c-spine", importance: .normal),
                    ]
                ),
                ScenarioSection(
                    name: "LOC",
                    requirements: [
                        ScenarioRequirement(description: "AVPU?", importance: .normal),
                        ScenarioRequirement(description: "C/C?", importance: .normal),
                    ]
                ),
                ScenarioSection(
                    name: "Airway",
                    requirements: [
                        ScenarioRequirement(description: "Patent?", importance: .critical),
                        ScenarioRequirement(description: "Snoring/gurgling/stridor, or silence?", importance: .normal)
                    ]
                ),
                ScenarioSection(
                    name: "Breathing",
                    requirements: [
                        ScenarioRequirement(description: "Present?", importance: .critical),
                        ScenarioRequirement(description: "RDE?", importance: .normal),
                        ScenarioRequirement(description: "ACTION administer O2 @ 15 LPM via NRB", importance: .normal)
                    ]
                ),
                ScenarioSection(
                    name: "Circulation",
                    requirements: [
                        ScenarioRequirement(description: "Present?", importance: .critical),
                        ScenarioRequirement(description: "RRQ @ radial & carotid?", importance: .normal),
                        ScenarioRequirement(description: "Skin colour, condition, temperature, cap refill?", importance: .normal),
                        ScenarioRequirement(description: "Has bleeding been controlled?", importance: .critical)
                    ]
                ),
                ScenarioSection(
                    name: "Interventions?"
                ),
                ScenarioSection(
                    name: "MOI indicates which survey?",
                    decisionPointRapidOrFocusedChoices: ITLSAssessmentType.allCases,
                    subSections: [
                        ScenarioSection(
                            name: "Rapid Trauma Survey",
                            decisionPointRapidOrFocused: .rapid,
                            subSections: [
                                ScenarioSection(
                                    name: "Head & Neck",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC (deformity, contustion, abrasion, penetration, burns, lacerations, swelling, tenderness, instability, crepitus)", importance: .critical),
                                        ScenarioRequirement(description: "JVD?", importance: .normal),
                                        ScenarioRequirement(description: "Trachea midline?", importance: .normal),
                                        ScenarioRequirement(description: "ACTION apply c-spine", importance: .critical)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Chest",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .critical),
                                        ScenarioRequirement(description: "Chest asymmetrical?", importance: .normal),
                                        ScenarioRequirement(description: "SQ emphysema?", importance: .normal),
                                        ScenarioRequirement(description: "Paradoxical motion?", importance: .normal),
                                        ScenarioRequirement(description: "ACTION Auscultate for lung/heart sounds", importance: .normal),
                                        ScenarioRequirement(description: "ACTION if decreased, percuss", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Abdomen",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DRT (distension, rigidity, tenderness)", importance: .critical),
                                        ScenarioRequirement(description: "Evisceration, bruising, penetration?", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Pelvis",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for TIC", importance: .critical),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Lower/upper extremities",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .critical),
                                        ScenarioRequirement(description: "ACTION check CMS x4", importance: .normal),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Back",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .critical),
                                    ]
                                ),
                            ]
                        ),
                        ScenarioSection(
                            name: "Focused Exam",
                            decisionPointRapidOrFocused: .focused,
                            subSections: [
                                ScenarioSection(
                                    name: "Area of injury",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .critical),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Vitals",
                                    requirements: [
                                        ScenarioRequirement(description: "Pulse?", importance: .normal),
                                        ScenarioRequirement(description: "BP?", importance: .normal),
                                        ScenarioRequirement(description: "RR?", importance: .normal),
                                        ScenarioRequirement(description: "GCS?", importance: .normal),
                                        ScenarioRequirement(description: "Pupils PERL?", importance: .normal)
                                    ]
                                ),
                            ]
                        ),
                    ]
                ),
                ScenarioSection(
                    name: "Patient stability",
                    decisionPointOngoingOrSecondaryChoices: ITLSSecondarySurveyType.allCases,
                    subSections: [
                        ScenarioSection(
                            name: "Ongoing exam",
                            decisionPointOngoingOrSecondary: .ongoing,
                            subSections: [
                                ScenarioSection(
                                    name: "Hx",
                                    requirements: [
                                        ScenarioRequirement(description: "SAMPLE?", importance: .critical),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "LOC",
                                    requirements: [
                                        ScenarioRequirement(description: "AVPU?", importance: .normal),
                                        ScenarioRequirement(description: "Pupils PERL?", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Vitals",
                                    requirements: [
                                        ScenarioRequirement(description: "BGL?", importance: .normal),
                                        ScenarioRequirement(description: "Sp02?", importance: .normal),
                                        ScenarioRequirement(description: "Pulse?", importance: .normal),
                                        ScenarioRequirement(description: "BP?", importance: .normal),
                                        ScenarioRequirement(description: "RR?", importance: .normal),
                                        ScenarioRequirement(description: "Temp?", importance: .normal),
                                        ScenarioRequirement(description: "Skin?", importance: .normal),
                                        ScenarioRequirement(description: "GCS?", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Airway",
                                    requirements: [
                                        ScenarioRequirement(description: "Patent?", importance: .normal),
                                        ScenarioRequirement(description: "Snoring, gurgling, stridor, or silence?", importance: .normal),
                                        ScenarioRequirement(description: "Signs of inhalation injury?", importance: .normal),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Breathing",
                                    requirements: [
                                        ScenarioRequirement(description: "RDE?", importance: .normal),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Circulation",
                                    requirements: [
                                        ScenarioRequirement(description: "RRQ @ radial & carotid?", importance: .normal),
                                        ScenarioRequirement(description: "Skin colour, condition, temperature, cap refill?", importance: .normal),
                                        ScenarioRequirement(description: "Is bleeding still controlled?", importance: .critical)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Physical exam"
                                ),
                                ScenarioSection(
                                    name: "Neck",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .normal),
                                        ScenarioRequirement(description: "JVD?", importance: .normal),
                                        ScenarioRequirement(description: "Trachea midline?", importance: .normal),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Chest",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DCAP-BLS TIC", importance: .critical),
                                        ScenarioRequirement(description: "Chest asymmetrical?", importance: .normal),
                                        ScenarioRequirement(description: "SQ emphysema?", importance: .normal),
                                        ScenarioRequirement(description: "Paradoxical motion?", importance: .normal),
                                        ScenarioRequirement(description: "ACTION Auscultate for lung/heart sounds", importance: .normal),
                                        ScenarioRequirement(description: "ACTION if decreased, percuss", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Abdomen",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION Looking/feeling for DRT (distension, rigidity, tenderness)", importance: .critical),
                                        ScenarioRequirement(description: "Evisceration, bruising, penetration?", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Every 5 mins",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION reassess LOC", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess ABCs", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess all interventions", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess vitals", importance: .normal)
                                    ]
                                ),
                            ]
                        ),
                        ScenarioSection(
                            name: "ITLS Secondary Survey",
                            requirements: [
                                ScenarioRequirement(description: "Reassess LOC", importance: .normal),
                                ScenarioRequirement(description: "Reassess ABCs", importance: .normal),
                            ],
                            decisionPointOngoingOrSecondary: .secondary,
                            subSections: [
                                ScenarioSection(
                                    name: "Hx",
                                    requirements: [
                                        ScenarioRequirement(description: "SAMPLE?", importance: .critical),
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Vitals",
                                    requirements: [
                                        ScenarioRequirement(description: "BGL?", importance: .normal),
                                        ScenarioRequirement(description: "Sp02?", importance: .normal),
                                        ScenarioRequirement(description: "Pulse?", importance: .normal),
                                        ScenarioRequirement(description: "BP?", importance: .normal),
                                        ScenarioRequirement(description: "RR?", importance: .normal),
                                        ScenarioRequirement(description: "Temp?", importance: .normal),
                                        ScenarioRequirement(description: "Skin?", importance: .normal),
                                        ScenarioRequirement(description: "GCS?", importance: .normal)
                                    ]
                                ),
                                ScenarioSection(
                                    name: "Every 15 mins",
                                    requirements: [
                                        ScenarioRequirement(description: "ACTION reassess LOC", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess ABCs", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess all interventions", importance: .normal),
                                        ScenarioRequirement(description: "ACTION reassess vitals", importance: .normal)
                                    ]
                                ),
                            ]
                        )
                    ]
                ),
                ScenarioSection(
                    name: "Complete"
                ),
            ]
        )
    ]

    struct Scenario: Identifiable, Equatable {
        var id: UUID = UUID()
        var type: ScenarioType
        var sections: [ScenarioSection]

        static func == (lhs: PrimaryAssessment.Scenario, rhs: PrimaryAssessment.Scenario) -> Bool {
            return lhs.id == rhs.id
        }
    }

    enum ScenarioType: CaseIterable {
        case medical, trauma

        var label: String {
            switch self {
            case .medical: "Medical"
            case .trauma: "ITLS Trauma"
            }
        }

        var colour: Color {
            switch self {
            case .medical: .blue
            case .trauma: .red
            }
        }
    }

    enum ITLSAssessmentType: CaseIterable {
        case rapid, focused

        var label: String {
            switch self {
            case .rapid: "Rapid"
            case .focused: "Focused"
            }
        }
    }

    enum ITLSSecondarySurveyType: CaseIterable {
        case ongoing, secondary

        var label: String {
            switch self {
            case .ongoing: "Ongoing"
            case .secondary: "Secondary"
            }
        }
    }

    struct ScenarioSection: Identifiable {
        var id: UUID = UUID()
        var name: String
        var requirements: [ScenarioRequirement] = []
        var decisionPointRapidOrFocusedChoices: [ITLSAssessmentType]?
        var decisionPointRapidOrFocused: ITLSAssessmentType?
        var decisionPointOngoingOrSecondaryChoices: [ITLSSecondarySurveyType]?
        var decisionPointOngoingOrSecondary: ITLSSecondarySurveyType?
        var action: AnyView?
        var subSections: [ScenarioSection] = []
        // @TODO: some kind of boolean selection method (i.e. Unconscious? tap here, Conscious? tap here)
    }

    struct ScenarioRequirement: Identifiable, Equatable {
        var id: UUID = UUID()
        var description: String
        var importance: Importance
        var notes: String?

        enum Importance {
            case normal, critical
        }
    }

    struct ScenarioCoordinates {
        var section: UUID?
        var requirement: UUID?
        var type: ScenarioType?
        var decisionPointRapidOrFocused: ITLSAssessmentType?
        var decisionPointOngoingOrSecondary: ITLSSecondarySurveyType?
    }

    struct Views {
        struct Progress: View {
            typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

            @State public var pa: PrimaryAssessment
            @Binding public var current: Coordinates

            var body: some View {
                VStack(alignment: .center, spacing: 0) {
                    HStack(alignment: .center, spacing: 0) {
                        Button {
                            self.actionOnNext()
                        } label: {
                            Text("Next")
                                .padding()
                        }
                        Spacer()
                    }
                }
            }
        }

        struct SectionList: View {
            typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

            @State public var pa: PrimaryAssessment
            @Binding public var current: Coordinates
            @Binding public var type: PrimaryAssessment.ScenarioType

            var body: some View {
                ScrollView(showsIndicators: false) {
                    ForEach(self.pa.scenarios, id: \.id) { scenario in
                        if scenario.type == self.type {
                            ForEach(scenario.sections, id: \.id) { section in
                                if !section.subSections.isEmpty {
                                    DecisionPoint(section: section, current: $current, type: $type)
                                } else {
                                    SingleSection(section: section, current: $current)
                                }
                            }
                        }
                    }
                }
                .padding(8)
            }

            struct DecisionPoint: View {
                @State public var section: ScenarioSection
                @Binding public var current: Coordinates
                @Binding public var type: PrimaryAssessment.ScenarioType

                var body: some View {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(alignment: .center) {
                            Image(systemName: "stethoscope")
                                .foregroundStyle(.gray)
                            Text(section.name)
                            Spacer()
                        }
                        .font(.title2)
                        .bold()
                        .padding()
                        .background(.gray.opacity(0.6))

                        if section.decisionPointRapidOrFocusedChoices != nil {
                            HStack(alignment: .center, spacing: 0) {
                                ForEach(section.decisionPointRapidOrFocusedChoices!, id: \.self) { iType in
                                    Button {
                                        current.decisionPointRapidOrFocused = iType
                                    } label: {
                                        HStack(alignment: .center, spacing: 0) {
                                            HStack {
                                                Spacer()
                                                Text(iType.label)
                                                    .padding()
                                                Spacer()
                                            }
                                        }
                                        .background(iType == current.decisionPointRapidOrFocused ? type.colour : .black.opacity(0.4))
                                    }
                                }
                            }
                            .foregroundStyle(.white)
                            .background(.gray)

                            if current.decisionPointRapidOrFocused != nil {
                                ForEach(section.subSections, id: \.id) { subSection in
                                    if current.decisionPointRapidOrFocused == subSection.decisionPointRapidOrFocused {
                                        SingleSection(section: subSection, current: $current)
                                    }
                                }
                            }

                        } else if section.decisionPointOngoingOrSecondaryChoices != nil {
                            HStack(alignment: .center, spacing: 0) {
                                ForEach(section.decisionPointOngoingOrSecondaryChoices!, id: \.self) { iType in
                                    Button {
                                        current.decisionPointOngoingOrSecondary = iType
                                    } label: {
                                        HStack(alignment: .center, spacing: 0) {
                                            HStack {
                                                Spacer()
                                                Text(iType.label)
                                                    .padding()
                                                Spacer()
                                            }
                                        }
                                        .background(iType == current.decisionPointOngoingOrSecondary ? type.colour : .black.opacity(0.4))
                                    }
                                }
                            }
                            .foregroundStyle(.white)
                            .background(.gray)

                            if current.decisionPointOngoingOrSecondary != nil {
                                ForEach(section.subSections, id: \.id) { subSection in
                                    if current.decisionPointOngoingOrSecondary == subSection.decisionPointOngoingOrSecondary {
                                        SingleSection(section: subSection, current: $current)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            struct SingleSection: View {
                typealias Coordinates = PrimaryAssessment.ScenarioCoordinates

                public var section: ScenarioSection
                @Binding public var current: Coordinates
                @State private var completed: Bool = false

                var body: some View {
                    VStack(alignment: .leading, spacing: 1) {
                        Button {
                            self.completed.toggle()
                        } label: {
                            HStack(alignment: .center) {
                                Text(section.name)
                                    .font(.title2)
                                    .bold()
                                Spacer()

                                if self.completed {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(8)
                            //                        .foregroundStyle(current.section == section.id ? .white : .gray)
                            .background(current.section == section.id ? .blue : .gray.opacity(0.6))
                        }

                        ForEach(section.requirements) { req in
                            HStack(alignment: .center) {
                                Text(req.description)
                                Spacer()
                            }
                            .padding(8)
//                            .foregroundStyle(current.requirement == req.id ? .white : .gray)
                            .background(current.requirement == req.id ? .blue : req.importance == .critical ? .yellow : .gray.opacity(0.4))
                        }
                        .opacity(self.completed ? 0.5 : 1)

                        if !section.subSections.isEmpty {
                            ForEach(section.subSections, id: \.id) { subSection in
                                SingleSection(section: subSection, current: $current)
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
//        if let typeIndex = self.pa.sections.firstIndex(where: {$0.id == current.section}) {
//        if let currentIndex = self.pa.sections.firstIndex(where: {$0.id == current.section}) {
//            let nextIndex = self.pa.sections.index(after: currentIndex)
//            if let nextSection = self.pa.sections.enumerated().filter({$0.offset == nextIndex}).first {
//                if let currentSection = self.pa.sections.enumerated().filter({$0.offset == currentIndex}).first {
//                    let lastRequirementInSection = currentSection.element.requirements.last
//                    let currentRequirementIndex = currentSection.element.requirements.firstIndex(where: {$0.id == current.requirement}) ?? 0
//                    let currentRequirement = currentSection.element.requirements.enumerated().filter({$0.offset == currentRequirementIndex}).first
//                    let nextRequirementIndex = currentSection.element.requirements.index(after: currentRequirementIndex)
//                    let nextRequirement = currentSection.element.requirements.enumerated().filter({$0.offset == nextRequirementIndex}).first
//                    let nextSectionFirstRequirement = nextSection.element.requirements.first
//
//                    if let nReq = nextRequirement?.element {
//                        if nReq.id == lastRequirementInSection?.id {
//                            current.section = nextSection.element.id
//                            current.requirement = nextSectionFirstRequirement?.id
//                            print("DERPO changed sections to \(current.section!)")
//                            print("DERPO changed requirement to \(current.requirement!)")
//                        } else {
//                            current.requirement = nextRequirement?.element.id
//                            print("DERPO changed requirement to \(current.requirement!)")
//                        }
//                    }
//                }
//            }
//        }
    }
}
