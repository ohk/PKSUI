//
//  PKSCardShapeKey.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//


import SwiftUI


/// An environment key for the card's shape.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardShapeKey: @preconcurrency EnvironmentKey  {
    /// The default shape for `PKSCard`.
    @MainActor public static var defaultValue: any Shape = PKSCardShape.roundedRectangle(cornerRadius: 12)
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension EnvironmentValues {
    /// The shape of the `PKSCard`.
    ///
    /// - Note: This value is set using the ``View/cardShape(_:)`` modifier.
    public var pksCardShape: any Shape {
        get { self[PKSCardShapeKey.self] }
        set { self[PKSCardShapeKey.self] = newValue }
    }
}
