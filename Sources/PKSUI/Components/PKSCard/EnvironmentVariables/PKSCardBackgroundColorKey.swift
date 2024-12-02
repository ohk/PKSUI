//
//  PKSCardBackgroundColorKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// An environment key for the card's background color.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardBackgroundColorKey: @preconcurrency EnvironmentKey  {
    /// The default background color for `PKSCard`.
    @MainActor public static var defaultValue: Color = Color("CardBackground", bundle: .main)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    
    /// The background color of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardBackgroundColor(_:)`` modifier.
    public var pksCardBackgroundColor: Color {
        get { self[PKSCardBackgroundColorKey.self] }
        set { self[PKSCardBackgroundColorKey.self] = newValue }
    }
}
