//
//  PKSPillSectionTitleKey.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/23/25.
//

import SwiftUI

/// An environment key that provides the title of the parent PKSPillSection.
///
/// This key allows PKSPill components to know which section they belong to,
/// enabling proper selection tracking and management.
///
/// - Note: This is an internal implementation detail of the PKSPill component system.
struct PKSPillSectionTitleKey: @preconcurrency EnvironmentKey {
    /// The default value is nil, indicating the pill is not within a section.
    @MainActor static var defaultValue: String?
}

extension EnvironmentValues {
    /// The title/identifier of the parent PKSPillSection, if any.
    ///
    /// This value is automatically set by PKSPillSection for its child views.
    var pksPillSectionTitle: String? {
        get { self[PKSPillSectionTitleKey.self] }
        set { self[PKSPillSectionTitleKey.self] = newValue }
    }
}
