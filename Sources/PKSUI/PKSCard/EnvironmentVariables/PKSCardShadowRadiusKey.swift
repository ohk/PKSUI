//
//  PKSCardShadowRadiusKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's shadow radius.
public struct PKSCardShadowRadiusKey: @preconcurrency EnvironmentKey  {
    /// The default shadow radius for `PKSCard`.
    @MainActor public static var defaultValue: CGFloat = 4
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The shadow radius of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardShadow(color:radius:x:y:)`` modifier.
    public var pksCardShadowRadius: CGFloat {
        get { self[PKSCardShadowRadiusKey.self] }
        set { self[PKSCardShadowRadiusKey.self] = newValue }
    }
}
