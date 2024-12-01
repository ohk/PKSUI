//
//  StarShape.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

/// A shape that draws a star with a specified number of points.
///
/// The `StarShape` struct conforms to the `Shape` protocol and allows
/// for the creation of star shapes with a customizable number of points.
///
/// - Note: The number of points must be two or greater. If fewer points are
///   provided, the shape will render as an empty path.
@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public struct StarShape: Shape {
    /// The number of points the star will have.
    ///
    /// This value determines how many sharp corners the star shape will possess.
    @usableFromInline
    let points: Int
    
    /// Initializes a new `StarShape` with the specified number of points.
    ///
    /// - Parameter points: The number of points for the star. Must be two or greater.
    ///
    /// - Complexity: O(1)
    @inlinable
    public init(points: Int) {
        self.points = points
    }
    
    /// Creates the path that defines the star shape within the given rectangle.
    ///
    /// - Parameter rect: The frame of the shape.
    /// - Returns: A `Path` representing the star shape.
    ///
    /// - Complexity: O(n), where n is the number of points.
    public func path(in rect: CGRect) -> Path {
        guard points >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let angle = (2.0 * Double.pi) / Double(points * 2)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()
        
        for i in 0..<(points * 2) {
            let r = (i % 2 == 0) ? radius : radius * 0.5
            let x = center.x + CGFloat(cos(Double(i) * angle)) * r
            let y = center.y + CGFloat(sin(Double(i) * angle)) * r
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        return path
    }
}
