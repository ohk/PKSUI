//
//  PKSCardBorderColorKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's border color.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardBorderColorKey: @preconcurrency EnvironmentKey  {
    /// The default border color for `PKSCard`.
    @MainActor public static var defaultValue: Color? = Color("CardBorder", bundle: .main)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The border color of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardBorder(color:width:)`` modifier.
    public var pksCardBorderColor: Color? {
        get { self[PKSCardBorderColorKey.self] }
        set { self[PKSCardBorderColorKey.self] = newValue }
    }
}
