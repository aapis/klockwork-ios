//
//  Swipe.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2024-05-25.
//

import SwiftUI

// Thanks https://stackoverflow.com/a/75375148
struct Swipe: OptionSet, Equatable {

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    let rawValue: Int

    var swiped: ((DragGesture.Value, Double) -> Bool) = { _, _ in false } // prevents a crash if someone creates a swipe directly using the init

    private static let sensitivityFactor: Double = 400 // a fairly arbitrary figure which gives a reasonable response

    static var left: Swipe {
        var swipe = Swipe(rawValue: 1 << 0)
        swipe.swiped = { value, sensitivity in
            value.translation.width < 0 && value.predictedEndTranslation.width < sensitivity * sensitivityFactor
        }
        return swipe
    }

    static var right: Swipe {
        var swipe = Swipe(rawValue: 1 << 1)
        swipe.swiped = { value, sensitivity in
            value.translation.width > 0 && value.predictedEndTranslation.width > sensitivity * sensitivityFactor
        }
        return swipe
    }

    static var up: Swipe {
        var swipe = Swipe(rawValue: 1 << 2)
        swipe.swiped = { value, sensitivity in
            value.translation.height < 0 && value.predictedEndTranslation.height < sensitivity * sensitivityFactor
        }
        return swipe
    }

    static var down: Swipe {
        var swipe = Swipe(rawValue: 1 << 3)
        swipe.swiped = { value, sensitivity in
            value.translation.height > 0 && value.predictedEndTranslation.height > sensitivity * sensitivityFactor
        }
        return swipe
    }

    static var all: Swipe {
        [.left, .right, .up, .down]
    }

    private static var allCases: [Swipe] = [.left, .right, .up, .down]

    var array: [Swipe] {
        Swipe.allCases.filter { self.contains($0) }
    }
}
