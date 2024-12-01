//
//  PKSCardShadowXKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's shadow X-offset.
public struct PKSCardShadowXKey: @preconcurrency EnvironmentKey  {
    /// The default shadow X-offset for `PKSCard`.
    @MainActor public static var defaultValue: CGFloat = 0
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The shadow X-offset of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardShadow(color:radius:x:y:)`` modifier.
    public var pksCardShadowX: CGFloat {
        get { self[PKSCardShadowXKey.self] }
        set { self[PKSCardShadowXKey.self] = newValue }
    }
}
