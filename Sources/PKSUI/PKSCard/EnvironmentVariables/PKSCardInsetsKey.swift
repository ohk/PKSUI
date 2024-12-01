//
//  PKSCardInsetsKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//


import SwiftUI

/// An environment key for the card's insets.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardInsetsKey: @preconcurrency EnvironmentKey  {
    /// The default insets for `PKSCard`.
    @MainActor public static var defaultValue: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The insets of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardInsets(_:)`` modifier.
    public var pksCardInsets: EdgeInsets {
        get { self[PKSCardInsetsKey.self] }
        set { self[PKSCardInsetsKey.self] = newValue }
    }
}