//
//  PKSCardContainerAlignmentKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//


import SwiftUI

/// An environment key for the card's container alignment.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardContainerAlignmentKey: @preconcurrency EnvironmentKey {
    /// The default container alignment for `PKSCard`.
    @MainActor public static var defaultValue: HorizontalAlignment = .leading
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The container alignment of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/pksCardContainerAlignment(_:)`` modifier.
    public var pksCardContainerAlignment: HorizontalAlignment {
        get { self[PKSCardContainerAlignmentKey.self] }
        set { self[PKSCardContainerAlignmentKey.self] = newValue }
    }
}
