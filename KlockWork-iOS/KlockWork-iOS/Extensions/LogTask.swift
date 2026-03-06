//
//  LogTask.swift
//  KlockWork-iOS
//
//  Created by Ryan Priebe on 2026-03-05.
//

import SwiftUI

extension LogTask {
    public var isComplete: Bool {
        return self.completedDate != nil
    }

    public var isCancelled: Bool {
        return self.cancelledDate != nil
    }

    public var isOpen: Bool {
        return !self.isComplete && !self.isCancelled
    }
}
