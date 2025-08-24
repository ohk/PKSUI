//
//  PKSPillSelectionLimit.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/24/25.
//

import SwiftUI

/// Defines the selection behavior constraints for pills within a PKSPillSection.
///
/// `PKSPillSelectionLimit` allows you to control how many pills can be selected simultaneously
/// within a section. It provides predefined configurations for common use cases.
///
/// ## Available Configurations
///
/// - `.single`: Only one pill can be selected at a time
/// - `.unlimited`: Any number of pills can be selected
/// - `.multiple(limit:)`: Up to a specified number of pills can be selected
///
/// ## Usage Example
///
/// ```swift
/// PKSPillSection("Options") { ... }
///     .selectionLimit(.single)  // Radio button behavior
///
/// PKSPillSection("Tags") { ... }
///     .selectionLimit(.multiple(limit: 5))  // Select up to 5 tags
/// ```
public struct PKSPillSelectionLimit: Sendable {
    /// The maximum number of selections allowed, or nil for unlimited.
    let limit: Int?
    
    /// Creates a selection limit configuration.
    ///
    /// - Parameter limit: The maximum number of selections, or nil for unlimited.
    public init(limit: Int? = nil) {
        self.limit = limit
    }
}

extension PKSPillSelectionLimit {
    /// A selection limit that allows only one pill to be selected at a time.
    ///
    /// This creates a radio button-like behavior where selecting a new pill
    /// automatically deselects the previously selected one.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillSection("Size") {
    ///     PKSPill("Small") { _ in }
    ///     PKSPill("Medium") { _ in }
    ///     PKSPill("Large") { _ in }
    /// }
    /// .selectionLimit(.single)
    /// ```
    public static let single = PKSPillSelectionLimit(limit: 1)
}

extension PKSPillSelectionLimit {
    /// A selection limit that allows unlimited selections.
    ///
    /// This is the default behavior where any number of pills can be selected simultaneously.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillSection("Interests") {
    ///     PKSPill("Music") { _ in }
    ///     PKSPill("Sports") { _ in }
    ///     PKSPill("Reading") { _ in }
    /// }
    /// .selectionLimit(.unlimited)  // Can select all
    /// ```
    public static let unlimited = PKSPillSelectionLimit(limit: nil)
}

extension PKSPillSelectionLimit {
    /// Creates a selection limit that allows up to a specified number of selections.
    ///
    /// When the limit is reached, selecting a new pill will automatically deselect
    /// the oldest selection to make room for the new one.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillSection("Choose up to 3 topics") {
    ///     PKSPill("Technology") { _ in }
    ///     PKSPill("Science") { _ in }
    ///     PKSPill("Art") { _ in }
    ///     PKSPill("History") { _ in }
    ///     PKSPill("Literature") { _ in }
    /// }
    /// .selectionLimit(.multiple(limit: 3))
    /// ```
    ///
    /// - Parameter limit: The maximum number of pills that can be selected.
    /// - Returns: A selection limit configuration with the specified maximum.
    ///
    /// - Precondition: The limit must be greater than 0.
    public static func multiple(limit: Int) -> PKSPillSelectionLimit {
        PKSPillSelectionLimit(limit: limit)
    }
}
