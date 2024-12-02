//
//  PKSCardDisabledOpacity.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key to determine if dividers should be shown in `PKSCard`.
public struct PKSCardDisabledOpacityKey: @preconcurrency EnvironmentKey  {
    /// The default value indicating whether dividers are shown.
    @MainActor public static var defaultValue: CGFloat = 0.5
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// Determines whether dividers are shown in the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/pksCardShowDivider(_:)`` modifier.
    public var pksDisabledOpacity: CGFloat {
        get { self[PKSCardDisabledOpacityKey.self] }
        set { self[PKSCardDisabledOpacityKey.self] = newValue }
    }
}
