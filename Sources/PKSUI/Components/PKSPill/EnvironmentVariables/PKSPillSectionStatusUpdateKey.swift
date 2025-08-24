//
//  PKSPillSectionStatusUpdateKey.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/23/25.
//

import SwiftUI

/// An environment key that provides a closure for updating pill selection status within a section.
///
/// This key enables communication between PKSPill components and their parent PKSPillSection,
/// allowing the section to track which pills are selected and enforce selection limits.
///
/// - Note: This is an internal implementation detail of the PKSPill component system.
struct PKSPillSectionStatusUpdateKey: @preconcurrency EnvironmentKey {
    /// The default value is nil, indicating no section is managing the pill.
    @MainActor static var defaultValue: ((String, AnyHashable) -> Void)? = nil
}

extension EnvironmentValues {
    /// A closure that updates the selection status of a pill within its section.
    ///
    /// The closure parameters are:
    /// - `String`: The section title/identifier
    /// - `AnyHashable`: The unique tag of the pill being selected/deselected
    var pksPillSectionStatusUpdate: ((String, AnyHashable) -> Void)? {
        get { self[PKSPillSectionStatusUpdateKey.self] }
        set { self[PKSPillSectionStatusUpdateKey.self] = newValue }
    }
}
