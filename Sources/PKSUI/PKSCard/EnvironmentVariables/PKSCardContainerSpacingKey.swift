//
//  PKSCardContainerSpacingKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's container spacing.
public struct PKSCardContainerSpacingKey: @preconcurrency EnvironmentKey  {
    /// The default container spacing for `PKSCard`.
    @MainActor public static var defaultValue: CGFloat = 16
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The container spacing of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardContainerSpacing(_:)`` modifier.
    public var pksCardContainerSpacing: CGFloat {
        get { self[PKSCardContainerSpacingKey.self] }
        set { self[PKSCardContainerSpacingKey.self] = newValue }
    }
}
