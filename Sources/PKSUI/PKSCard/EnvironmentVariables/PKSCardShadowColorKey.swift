//
//  PKSCardShadowColorKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's shadow color.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardShadowColorKey: @preconcurrency EnvironmentKey  {
    /// The default shadow color for `PKSCard`.
    @MainActor public static var defaultValue: Color = Color("CardShadow", bundle: .main)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    
    /// The shadow color of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardShadow(color:radius:x:y:)`` modifier.
    public var pksCardShadowColor: Color {
        get { self[PKSCardShadowColorKey.self] }
        set { self[PKSCardShadowColorKey.self] = newValue }
    }
}
