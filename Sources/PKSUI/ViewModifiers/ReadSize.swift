//
//  ReadSize.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 3/14/25.
//

import SwiftUI

// MARK: - SizePreferenceKey

/// A preference key to capture a view's size using SwiftUI's preference system.
///
/// This key is used internally by the view modifiers to track and update a view's size.
/// The default value is set to `.zero`, and subsequent values are provided through the
/// preference reduction mechanism.
///
/// - Note: This key is not intended to be used directly outside of the view modifiers.
public struct SizePreferenceKey: PreferenceKey {
    
    /// The default size value, initialized to zero.
    public static let defaultValue: CGSize = .zero
    
    /// Combines the current value with a new value provided by a child view.
    ///
    /// - Parameters:
    ///   - value: The current aggregated size.
    ///   - nextValue: A closure that returns the next size value.
    public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - CGSize Filtering Extension

/// An internal extension on `CGSize` for filtering dimensions based on the specified axes.
///
/// This helper method returns a new `CGSize` where the dimensions corresponding to
/// untracked axes are set to zero.
///
/// - Parameter axes: The set of axes to track. If an axis is not included, its value is zeroed.
/// - Returns: A filtered `CGSize` with untracked axes set to zero.
fileprivate extension CGSize {
    func filtered(for axes: Axis.Set) -> CGSize {
        var newSize = self
        if !axes.contains(.horizontal) {
            newSize.width = 0
        }
        if !axes.contains(.vertical) {
            newSize.height = 0
        }
        return newSize
    }
}

// MARK: - View Extensions for Reading Size

/// A collection of view modifiers for reading a SwiftUI view's size.
///
/// This extension provides two variations for tracking a view's size:
/// - Using a closure (`readSize(axes:onChange:)`)
/// - Using a binding (`readSize(axes:size:)`)
///
/// Additionally, it offers convenience methods for tracking only the width or height.
public extension View {
    
    // MARK: Size Reading Using Closure
    
    /// Observes and reports the size of the view via a closure.
    ///
    /// This modifier uses a background `GeometryReader` to measure the view's size and
    /// calls the provided closure whenever the size changes. You can specify which axes
    /// to track by providing an `Axis.Set` value. By default, both horizontal and vertical axes
    /// are tracked.
    ///
    /// - Parameters:
    ///   - axes: The axes to track. Default is `[.horizontal, .vertical]`.
    ///   - onChange: A closure that is executed when the view's size changes.
    ///               The closure receives the new `CGSize` as a parameter.
    /// - Returns: A view that observes its size.
    func readSize(axes: Axis.Set = [.horizontal, .vertical],
                  onChange: @Sendable @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: SizePreferenceKey.self,
                                value: geometry.size.filtered(for: axes))
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    // MARK: Size Reading Using Binding
    
    /// Observes and writes the size of the view to a binding.
    ///
    /// This modifier observes the view's size and updates the provided binding with
    /// the current size. Internally, it leverages the `readSize(axes:onChange:)` method.
    ///
    /// - Parameters:
    ///   - axes: The axes to track. Default is `[.horizontal, .vertical]`.
    ///   - size: A binding to store the view's size.
    /// - Returns: A view that observes its size.
    func readSize(axes: Axis.Set = [.horizontal, .vertical],
                  size: Binding<CGSize>) -> some View {
        self.readSize(axes: axes) { newSize in
            size.wrappedValue = newSize
        }
    }
    
    // MARK: Convenience for Width
    
    /// Observes and reports the width of the view via a closure.
    ///
    /// This modifier tracks only the horizontal axis and reports the width through the
    /// provided closure.
    ///
    /// - Parameter onChange: A closure that is executed when the view's width changes.
    ///                         The closure receives the new width as a `CGFloat`.
    /// - Returns: A view that observes its width.
    func readWidth(onChange: @Sendable @escaping (CGFloat) -> Void) -> some View {
        self.readSize(axes: .horizontal) { newSize in
            onChange(newSize.width)
        }
    }
    
    /// Observes and writes the width of the view to a binding.
    ///
    /// This modifier tracks only the horizontal axis and updates the provided binding
    /// with the view's width.
    ///
    /// - Parameter width: A binding to store the view's width.
    /// - Returns: A view that observes its width.
    func readWidth(width: Binding<CGFloat>) -> some View {
        self.readSize(axes: .horizontal) { newSize in
            width.wrappedValue = newSize.width
        }
    }
    
    // MARK: Convenience for Height
    
    /// Observes and reports the height of the view via a closure.
    ///
    /// This modifier tracks only the vertical axis and reports the height through the
    /// provided closure.
    ///
    /// - Parameter onChange: A closure that is executed when the view's height changes.
    ///                         The closure receives the new height as a `CGFloat`.
    /// - Returns: A view that observes its height.
    func readHeight(onChange: @Sendable @escaping (CGFloat) -> Void) -> some View {
        self.readSize(axes: .vertical) { newSize in
            onChange(newSize.height)
        }
    }
    
    /// Observes and writes the height of the view to a binding.
    ///
    /// This modifier tracks only the vertical axis and updates the provided binding
    /// with the view's height.
    ///
    /// - Parameter height: A binding to store the view's height.
    /// - Returns: A view that observes its height.
    func readHeight(height: Binding<CGFloat>) -> some View {
        self.readSize(axes: .vertical) { newSize in
            height.wrappedValue = newSize.height
        }
    }
}
