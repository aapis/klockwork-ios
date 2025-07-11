//
//  ContentView.swift
//  KlockWorkiOS
//
//  Created by Ryan Priebe on 2024-05-18.
//  Copyright © 2024 YegCollective. All rights reserved.
//

import SwiftUI

struct Main: View {
    @Environment(\.managedObjectContext) var moc
    @StateObject public var state: AppState = AppState()

    // Assessment factors, components of the scoring and evaluation algorithm
    private var defaultFactors: [FactorProxy] {
        return [
            FactorProxy(date: self.state.date, weight: 1, type: .records, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .jobs, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .jobs, action: .interaction),
            FactorProxy(date: self.state.date, weight: 1, type: .tasks, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .tasks, action: .interaction),
            FactorProxy(date: self.state.date, weight: 1, type: .notes, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .notes, action: .interaction),
            FactorProxy(date: self.state.date, weight: 1, type: .companies, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .companies, action: .interaction),
            FactorProxy(date: self.state.date, weight: 1, type: .people, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .people, action: .interaction),
            FactorProxy(date: self.state.date, weight: 1, type: .projects, action: .create),
            FactorProxy(date: self.state.date, weight: 1, type: .projects, action: .interaction)
        ]
    }

    var body: some View {
        TabView {
            Home(inSheet: false)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            Today(inSheet: false)
            .tabItem {
                Image(systemName: "tray")
                Text("Today")
            }
            Explore()
            .tabItem {
                Image(systemName: "globe.desk")
                Text("Explore")
            }
            Find()
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Find")
            }
        }
        .preferredColorScheme(.dark) // intentionally forcing dark mode on this view for aesthetics
        .tint(self.state.theme.tint)
        .onAppear(perform: self.onApplicationBoot)
        .environmentObject(self.state)
    }
}

extension Main {
    /// Fires when application has loaded and view appears
    /// - Returns: Void
    private func onApplicationBoot() -> Void {
        // Create the default set of assessment factors if necessary (aka, if there are no AFs)
        let factors = CDAssessmentFactor(moc: self.moc).all(limit: 1).first
        if factors == nil {
            for factor in self.defaultFactors {
                factor.createDefaultFactor(using: self.moc)
            }
        }

        // Create assessment Status/Threshold objects
        var allStatuses = CDAssessmentThreshold(moc: self.moc).all() // @TODO: replace with a .count call instead!
        if allStatuses.isEmpty || allStatuses.count < ActivityWeight.allCases.count {
            allStatuses = CDAssessmentThreshold(moc: self.moc).recreateAndReturn()
        }

        self.state.activities.statuses = allStatuses
        self.state.activities.assess()
    }
    
    /// Rebuilds terms and definitions
    /// - Returns: Void
    private func recreateTermsAndDefinitionsFromRecords() -> Void {
        let records = CoreDataRecords(moc: self.moc).matching(/(.*) == (.*)/)
        let terms = CoreDataTaxonomyTerms(moc: self.moc).all()
        let definitions = CoreDataTaxonomyTermDefinitions(moc: self.moc).all()

        // reset taxonomy terms
        for term in terms {
            self.moc.delete(term)
        }

        for definition in definitions {
            self.moc.delete(definition)
        }

        for record in records {
            if let matches = record.message?.matches(of: /(.*) == (.*)/) {
                for match in matches {
                    let def = TaxonomyTermDefinitions(context: self.moc)
                    def.alive = true
                    def.created = record.timestamp
                    def.job = record.job
                    def.definition = String(match.2)

                    if let foundTerm = CoreDataTaxonomyTerms(moc: self.moc).byName(String(match.1)) {
                        if let foundDefs = foundTerm.definitions?.allObjects as? [TaxonomyTermDefinitions] {
                            for fDef in foundDefs {
                                if def.definition != fDef.definition {
                                    foundTerm.addToDefinitions(def)
                                }
                            }
                        }
                    } else {
                        let term = TaxonomyTerm(context: moc)
                        term.alive = true
                        term.created = record.timestamp
                        term.lastUpdate = record.timestamp
                        term.name = String(match.1)
                        term.addToDefinitions(def)
                    }
                }
            }
        }

        PersistenceController.shared.save()
    }
}
