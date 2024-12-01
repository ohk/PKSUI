//
//  PKSCardEnvironmentVariablesViewModifiers.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension View {
    
    /// Sets the background color of a `PKSCard`.
    ///
    /// Use this modifier to customize the background color of a `PKSCard` by setting the `cardBackgroundColor` environment value.
    ///
    /// ```swift
    /// PKSCard {
    ///     Text("Hello, World!")
    /// }
    /// .cardBackgroundColor(.blue.opacity(0.1))
    /// ```
    ///
    /// - Parameter color: The color to set as the card's background.
    /// - Returns: A view that applies the specified background color to the `PKSCard`.
    public func cardBackgroundColor(_ color: Color) -> some View {
        environment(\.pksCardBackgroundColor, color)
    }
    
    /// Sets the shadow properties of a `PKSCard`.
    ///
    /// Use this modifier to customize the shadow color, radius, and offsets of a `PKSCard`. It updates the corresponding environment values used by the `PKSCard` view.
    ///
    /// - Parameters:
    ///   - color: The color of the shadow. Default is `Color("CardShadow", bundle: .main)`.
    ///   - radius: The blur radius of the shadow. Default is `4`.
    ///   - x: The horizontal offset of the shadow. Default is `0`.
    ///   - y: The vertical offset of the shadow. Default is `2`.
    /// - Returns: A view that applies the specified shadow settings to the `PKSCard`.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     Text("Shadowed Card")
    /// }
    /// .cardShadow(color: .gray.opacity(0.5), radius: 8, x: 4, y: 4)
    /// ```
    public func cardShadow(
        color: Color = Color("CardShadow", bundle: .main),
        radius: CGFloat = 4,
        x: CGFloat = 0,
        y: CGFloat = 2
    ) -> some View {
        self
            .environment(\.pksCardShadowColor, color)
            .environment(\.pksCardShadowRadius, radius)
            .environment(\.pksCardShadowX, x)
            .environment(\.pksCardShadowY, y)
    }
    
    /// Sets the border properties of a `PKSCard`.
    ///
    /// Use this modifier to customize the border color and width of a `PKSCard`. It updates the corresponding environment values used by the `PKSCard` view.
    ///
    /// - Parameters:
    ///   - color: The color of the border. If `nil`, no border is applied. Default is `Color("CardBorder", bundle: .main)`.
    ///   - width: The width of the border. Default is `1`.
    /// - Returns: A view that applies the specified border settings to the `PKSCard`.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     Text("Bordered Card")
    /// }
    /// .cardBorder(color: .blue, width: 2)
    /// ```
    public func cardBorder(
        color: Color? = Color("CardBorder", bundle: .main),
        width: CGFloat = 1
    ) -> some View {
        self
            .environment(\.pksCardBorderColor, color)
            .environment(\.pksCardBorderWidth, width)
    }
    
    /// Sets the shape of the `PKSCard`.
    ///
    /// This modifier allows you to customize the shape of a `PKSCard` by providing any shape conforming to the `Shape` protocol.
    ///
    /// - Parameter shape: The shape to apply to the card.
    /// - Returns: A view that applies the specified shape to the `PKSCard`.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     Text("Custom Shape Card")
    /// }
    /// .cardShape(Capsule())
    /// ```
    public func cardShape<S: Shape>(_ shape: S) -> some View {
        self.environment(\.pksCardShape, shape)
    }
    
    
    /// Sets the container spacing of the `PKSCard`.
    ///
    /// This modifier allows you to adjust the spacing between elements within a `PKSCard`.
    ///
    /// - Parameter spacing: The spacing value to apply.
    /// - Returns: A view that applies the specified container spacing to the `PKSCard`.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     VStack {
    ///         Text("Spaced Card")
    ///     }
    /// }
    /// .cardContainerSpacing(20)
    /// ```
    public func cardContainerSpacing(_ spacing: CGFloat) -> some View {
        self.environment(\.pksCardContainerSpacing, spacing)
    }
    
    /// Sets the insets of the `PKSCard`.
    ///
    /// This modifier allows you to customize the padding around the content of a `PKSCard`.
    ///
    /// - Parameter insets: The `EdgeInsets` to apply.
    /// - Returns: A view that applies the specified insets to the `PKSCard`.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     Text("Inset Card")
    /// }
    /// .cardInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
    /// ```
    public func cardInsets(_ insets: EdgeInsets) -> some View {
        self.environment(\.pksCardInsets, insets)
    }
}
