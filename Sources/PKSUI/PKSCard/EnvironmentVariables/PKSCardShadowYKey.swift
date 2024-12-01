//
//  PKSCardShadowYKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's shadow Y-offset.
public struct PKSCardShadowYKey: @preconcurrency EnvironmentKey  {
    /// The default shadow Y-offset for `PKSCard`.
    @MainActor public static var defaultValue: CGFloat = 2
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The shadow Y-offset of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardShadow(color:radius:x:y:)`` modifier.
    public var pksCardShadowY: CGFloat {
        get { self[PKSCardShadowYKey.self] }
        set { self[PKSCardShadowYKey.self] = newValue }
    }
}
