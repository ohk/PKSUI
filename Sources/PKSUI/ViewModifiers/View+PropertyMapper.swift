//
//  View+PropertyMapper.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

/// Extension that provides a utility method for in-place view modifications
extension View {
    /// Maps over the view allowing in-place property modifications
    /// This method enables a functional programming style for modifying view properties
    /// while maintaining immutability principles
    ///
    /// - Parameter closure: A closure that receives an inout reference to self for modifications
    /// - Returns: A modified copy of the view with the applied changes
    ///
    /// Example usage:
    /// ```swift
    /// struct MyView: View {
    ///     var color: Color = .blue
    ///
    ///     var body: some View {
    ///         Text("Hello, World!")
    ///             .foregroundStyle(color)
    ///     }
    /// 
    /// 
    ///     func withColor(_ newColor: Color) -> Self {
    ///         map { view in
    ///             view.color = newColor
    ///         }
    ///     }
    /// }
    /// ```
    public func map(_ closure: (inout Self) -> Void) -> Self {
        // Create a mutable copy of self
        var copy = self
        // Pass the copy to the closure for modification
        closure(&copy)
        // Return the modified copy
        return copy
    }
}