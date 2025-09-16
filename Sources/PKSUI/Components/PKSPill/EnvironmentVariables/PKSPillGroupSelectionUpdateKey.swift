//
//  PKSPillGroupSelectionUpdateKey.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/6/25.
//

import SwiftUI

/// An environment key that provides a closure for updating pill selections at the group level.
///
/// This key enables communication between PKSPillSection components and their parent PKSPillGroup,
/// allowing the group to track selections across all contained sections.
///
/// - Note: This is an internal implementation detail of the PKSPill component system.
struct PKSPillGroupSelectionUpdateKey: @preconcurrency EnvironmentKey {
    /// The default value is nil, indicating no group is managing the sections.
    @MainActor static var defaultValue: ((String, [AnyHashable]) -> Void)? = nil
}

extension EnvironmentValues {
    /// A closure that updates the selection status of pills within a group.
    ///
    /// The closure parameters are:
    /// - `String`: The section title/identifier
    /// - `[AnyHashable]`: The array of currently selected pill tags in that section
    var pksPillGroupSelectionUpdate: ((String, [AnyHashable]) -> Void)? {
        get { self[PKSPillGroupSelectionUpdateKey.self] }
        set { self[PKSPillGroupSelectionUpdateKey.self] = newValue }
    }
}