//
//  PKSCardBorderWidthKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//


import SwiftUI

/// An environment key for the card's border width.
public struct PKSCardBorderWidthKey: @preconcurrency EnvironmentKey  {
    /// The default border width for `PKSCard`.
    @MainActor public static var defaultValue: CGFloat = 0
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The border width of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardBorder(color:width:)`` modifier.
    public var pksCardBorderWidth: CGFloat {
        get { self[PKSCardBorderWidthKey.self] }
        set { self[PKSCardBorderWidthKey.self] = newValue }
    }
    
}
