//
//  PKSCardShape.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// Represents the various shapes that a `PKSCard` can adopt.
///
/// The `PKSCardShape` enum defines different shape options for customizing the appearance of a `PKSCard`. It supports predefined shapes like rounded rectangles, capsules, circles, and allows for custom shapes through the `custom` case.
///
/// - Note: When using the `custom` case, ensure that the provided shape conforms to the `Shape` protocol.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCardShape: Equatable {
    
    /// A rounded rectangle with a specified corner radius.
    ///
    /// - Parameter cornerRadius: The radius of the card's corners.
    static func roundedRectangle(cornerRadius: CGFloat) -> some Shape {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
    
    /// A capsule shape.
    static var capsule: some Shape {
        Capsule()
    }
    
    /// A circular shape.
    static var circle: some Shape {
        Circle()
    }
    
    /// A custom shape not covered by the predefined cases.
    ///
    /// - Parameter shape: An instance conforming to the `Shape` protocol.
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 6.0, *)
    static func custom(shape: AnyShape) -> some Shape {
        shape
    }
}
