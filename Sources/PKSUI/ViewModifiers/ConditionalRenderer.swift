//
//  ConditionalRenderer.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//


import SwiftUI

/// A set of extensions for `View` to provide conditional rendering capabilities.
///
/// This extension adds the `conditionalRenderer` method, which allows developers to apply
/// conditional modifications to a view based on dynamic criteria.
///
/// Example usage:
/// ```swift
/// struct ConditionalPreview: View {
///     @Environment(\.horizontalSizeClass) var horizontalSizeClass
///
///     var body: some View {
///         Text("Hello, World!")
///             .conditionalRenderer { view in
///                 if horizontalSizeClass == .compact {
///                     view.overlay(Color.red)
///                 } else {
///                     HStack {
///                         view
///                         Text("Regular")
///                     }
///                 }
///             }
///             .conditionalRenderer { view in
///                 if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
///                     view.background(Color.blue)
///                 } else {
///                     view
///                 }
///             }
///     }
/// }
/// ```
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    /// Applies a conditional transformation to the view using the provided content closure.
    ///
    /// The `conditionalRenderer` method allows you to modify the view based on dynamic conditions.
    /// It takes a closure that receives the current view and returns a modified version of it.
    ///
    /// - Parameters:
    ///   - content: A closure that takes the current view (`Self`) and returns a new view (`Content`)
    ///              after applying conditional modifications.
    ///
    /// - Returns: A view modified by the provided `content` closure.
    ///
    /// - Note: The `@ViewBuilder` attribute allows for complex view compositions within the closure.
    ///
    /// - Example:
    /// ```swift
    /// Text("Hello, World!")
    ///     .conditionalRenderer { view in
    ///         if someCondition {
    ///             view.foregroundColor(.red)
    ///         } else {
    ///             view.foregroundColor(.blue)
    ///         }
    ///     }
    ///
    /// ```
    @ViewBuilder
    func conditionalRenderer<Content: View>(@ViewBuilder content: @escaping (Self) -> Content) -> some View {
        content(self)
    }
}
