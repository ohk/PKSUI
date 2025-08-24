//
//  PKSPill.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

/// A customizable pill-shaped button component that can display any content.
///
/// `PKSPill` provides a flexible button component with a pill-shaped appearance that can be customized
/// with different content types, shapes, colors, and padding. It supports selection state tracking
/// and integrates with the PKSPillSection for grouped selections.
///
/// ## Usage Examples
///
/// ### Basic text pill:
/// ```swift
/// PKSPill("Click me") { isSelected in
///     print("Pill selected: \(isSelected)")
/// }
/// ```
///
/// ### Pill with custom content:
/// ```swift
/// PKSPill { isSelected in
///     handleSelection(isSelected)
/// } label: {
///     HStack {
///         Image(systemName: "star.fill")
///         Text("Favorite")
///     }
/// }
/// .pillBackgroundColor(.yellow)
/// ```
///
/// ### Pill with binding:
/// ```swift
/// @State private var isOn = false
/// PKSPill("Toggle", selection: $isOn)
/// ```
///
/// - Parameters:
///   - L: The type of view used as the label content
///   - Sh: The shape type used for the background (default: Capsule)
///
/// - Note: This component automatically adjusts its opacity when disabled through the SwiftUI environment.
public struct PKSPill<L: View, Sh: Shape>: View {
    /// Environment value to track if the view is enabled/disabled.
    @Environment(\.isEnabled) var isEnabled
    
    /// Environment closure for updating selection status in a parent PKSPillSection.
    @Environment(\.pksPillSectionStatusUpdate) private var statusUpdate
    
    /// Environment value containing the parent section's title.
    @Environment(\.pksPillSectionTitle) private var sectionTitle
    
    /// Tracks the current selection state of the pill.
    @State private var isSelected: Bool = false
    
    /// The action to perform when the pill is tapped.
    ///
    /// - Parameter isSelected: The new selection state after the tap.
    private let action: (Bool) -> Void
    
    /// The content to display inside the pill.
    private let label: L
    
    /// The shape used for the pill's background.
    private let shape: Sh
    
    /// Background color of the pill.
    ///
    /// - Note: Defaults to system gray color.
    private var backgroundColor: Color = Color(uiColor: UIColor.systemGray)
    
    /// Padding around the label content.
    ///
    /// - Note: Default padding is 8pt vertical and 16pt horizontal.
    private var inset: EdgeInsets = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )
    
    /// Unique identifier for this pill within a PKSPillSection.
    private var pillTag: AnyHashable?
    
    /// Creates a pill with custom content and default capsule shape.
    ///
    /// This is the primary initializer for creating pills with any custom SwiftUI view as content.
    ///
    /// - Parameters:
    ///   - action: A closure called when the pill is tapped, receiving the new selection state.
    ///   - label: A ViewBuilder closure that provides the content to display inside the pill.
    public init(
        action: @escaping @MainActor (Bool) -> Void,
        @ViewBuilder label: () -> L
    ) where Sh == Capsule {
        self.action = action
        self.label = label()
        self.shape = Capsule() // Default to capsule shape
    }
    
    public var body: some View {
        Button {
            let value = isSelected
            isSelected = !value
            action(!value)
            
            if let pillTag, let sectionTitle {
                statusUpdate?(sectionTitle, pillTag)
            }
        } label: {
            if label is Text {
                preparedLabel
            } else if label is Label<Text,Image> {
                preparedLabel
            } else {
                label
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
    }
    
    /// Prepares the label with appropriate padding and background.
    ///
    /// This computed property applies the configured insets and background color to the label content.
    private var preparedLabel: some View {
        label
            .padding(inset)
            .background(backgroundColor, in: shape)
    }
}

// MARK: - View Modifiers

extension PKSPill {
    /// Sets custom padding around the label content.
    ///
    /// Use this modifier to customize the internal padding of the pill content.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Custom Padding") { _ in }
    ///     .pillInset(EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
    /// ```
    ///
    /// - Parameter inset: The EdgeInsets to apply to all sides of the content.
    /// - Returns: A modified instance with the specified insets.
    public func pillInset(_ inset: EdgeInsets) -> Self {
        map { view in
            view.inset = inset
        }
    }
    
    /// Sets a unique identifier for this pill within a PKSPillSection.
    ///
    /// This tag is used by PKSPillSection to track which pills are selected when selection limits are enforced.
    ///
    /// - Parameter tag: A hashable value that uniquely identifies this pill.
    /// - Returns: A modified instance with the specified tag.
    ///
    /// - Important: This modifier is required when using pills within a PKSPillSection with selection limits.
    public func setPillTag(_ tag: AnyHashable) -> Self {
        map { view in
            view.pillTag = tag
        }
    }
    
    /// Sets uniform padding for specific edges.
    ///
    /// This convenience method allows you to set the same padding value for one or more edges.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Horizontal Padding") { _ in }
    ///     .pillInset(.horizontal, 24)
    /// ```
    ///
    /// - Parameters:
    ///   - edges: The edges to apply padding to (.all, .horizontal, .vertical, or specific edges).
    ///   - length: The padding amount in points.
    /// - Returns: A modified instance with the specified insets.
    ///
    /// - Note: When using .horizontal or .vertical, the padding is applied to both edges in that direction.
    public func pillInset(_ edges: Edge.Set, _ length: CGFloat) -> Self {
        map { view in
            var local = view.inset
            
            if edges.contains(.all) {
                local = EdgeInsets(
                    top: length,
                    leading: length,
                    bottom: length,
                    trailing: length
                )
            } else {
                if edges.contains(.bottom) {
                    local.bottom = length
                }
                
                if edges.contains(.leading) {
                    local.leading = length
                }
                
                if edges.contains(.top) {
                    local.top = length
                }
                
                if edges.contains(.trailing) {
                    local.trailing = length
                }
                
                if edges.contains(.horizontal) {
                    local.leading = length
                    local.trailing = length
                }
                
                if edges.contains(.vertical) {
                    local.top = length
                    local.bottom = length
                }
            }
            
            view.inset = local
        }
    }
    
    /// Sets the background color of the pill.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Green Pill") { _ in }
    ///     .pillBackgroundColor(.green)
    /// ```
    ///
    /// - Parameter color: The color to use for the pill's background.
    /// - Returns: A modified instance with the specified background color.
    public func pillBackgroundColor(_ color: Color) -> Self {
        map { view in
            view.backgroundColor = color
        }
    }
}

// MARK: - Text Convenience Initializers

extension PKSPill where L == Text {
    /// Creates a pill with a text label and default capsule shape.
    ///
    /// This convenience initializer simplifies creating text-only pills.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Tap me") { isSelected in
    ///     print("Selected: \(isSelected)")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display in the pill.
    ///   - action: A closure called when the pill is tapped, receiving the new selection state.
    public init<S: StringProtocol>(
        _ title: S,
        action: @escaping @MainActor (Bool) -> Void
    ) where Sh == Capsule {
        self.label = Text(title)
        self.action = action
        self.shape = Capsule()
    }
    
    /// Creates a pill with a text label and custom shape.
    ///
    /// Use this initializer when you want a text pill with a non-capsule shape.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Rounded", backgroundShape: RoundedRectangle(cornerRadius: 8)) { isSelected in
    ///     handleSelection(isSelected)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display in the pill.
    ///   - backgroundShape: Custom shape for the pill's background.
    ///   - action: A closure called when the pill is tapped, receiving the new selection state.
    public init<S: StringProtocol>(
        _ title: S,
        backgroundShape: Sh,
        action: @escaping @MainActor (Bool) -> Void
    ) {
        self.label = Text(title)
        self.action = action
        self.shape = backgroundShape
    }
}

// MARK: - Label Convenience Initializers

extension PKSPill where L == Label<Text, Image> {
    /// Creates a pill with text and system image icon.
    ///
    /// This convenience initializer creates pills with both text and SF Symbol icons.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Settings", systemImage: "gear") { isSelected in
    ///     navigateToSettings()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display in the pill.
    ///   - systemImage: The SF Symbol name for the icon.
    ///   - action: A closure called when the pill is tapped, receiving the new selection state.
    public init<S: StringProtocol>(
        _ title: S,
        systemImage: String,
        action: @escaping @MainActor (Bool) -> Void
    ) where Sh == Capsule {
        self.label = Label(title, systemImage: systemImage)
        self.action = action
        self.shape = Capsule()
    }
    
    /// Creates a pill with text, system image icon, and custom shape.
    ///
    /// Combines text, icon, and custom shape for maximum customization.
    ///
    /// ## Example
    /// ```swift
    /// PKSPill("Download", systemImage: "arrow.down.circle",
    ///         backgroundShape: RoundedRectangle(cornerRadius: 12)) { isSelected in
    ///     startDownload()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display in the pill.
    ///   - systemImage: The SF Symbol name for the icon.
    ///   - backgroundShape: Custom shape for the pill's background.
    ///   - action: A closure called when the pill is tapped, receiving the new selection state.
    public init<S: StringProtocol>(
        _ title: S,
        systemImage: String,
        backgroundShape: Sh,
        action: @escaping @MainActor (Bool) -> Void
    ) {
        self.label = Label(title, systemImage: systemImage)
        self.action = action
        self.shape = backgroundShape
    }
}
// MARK: - Binding Initializers

extension PKSPill {
    /// Creates a pill that synchronizes with a binding value.
    ///
    /// Use this initializer when you want the pill's selection state to be controlled by external state.
    ///
    /// ## Example
    /// ```swift
    /// @State private var isFilterActive = false
    ///
    /// PKSPill($isFilterActive) {
    ///     Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - selection: A binding to a Boolean value that tracks the pill's selection state.
    ///   - label: A ViewBuilder closure that provides the content to display inside the pill.
    public init(
        _ selection: Binding<Bool>,
        @ViewBuilder label: () -> L
    ) where Sh == Capsule {
        self.action = { isSelected in
            selection.wrappedValue = isSelected
        }
        self.label = label()
        self.shape = Capsule() // Default to capsule shape
        self._isSelected = State(initialValue: selection.wrappedValue)
    }
}

extension PKSPill where L == Text {
    /// Creates a text pill that synchronizes with a binding value.
    ///
    /// This convenience initializer combines text content with binding-based selection.
    ///
    /// ## Example
    /// ```swift
    /// @State private var showAdvanced = false
    ///
    /// PKSPill("Advanced Options", selection: $showAdvanced)
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display in the pill.
    ///   - selection: A binding to a Boolean value that tracks the pill's selection state.
    public init<S: StringProtocol>(
        _ title: S,
        selection: Binding<Bool>
    ) where Sh == Capsule {
        self.label = Text(title)
        self.action = { isSelected in
            selection.wrappedValue = isSelected
        }
        self.shape = Capsule()
        
        self._isSelected = State(initialValue: selection.wrappedValue)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        
        PKSPill { isSelected in
            debugPrint("On Tap, \(isSelected)")
        } label: {
            Rectangle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
        }
        
        HStack {
            PKSPill("Hello") { isSelected in
                debugPrint("Hello World, \(isSelected)")
            }
            .pillInset(
                EdgeInsets(
                    top: 24,
                    leading: 24,
                    bottom: 24,
                    trailing: 24
                )
            )
            .foregroundStyle(.black)
            .font(.largeTitle)
            
            PKSPill("Hello") { isSelected in
                debugPrint("Hello World, \(isSelected)")
            }
            .foregroundStyle(.black)
            .font(.largeTitle)
            
            PKSPill("Hello", backgroundShape: RoundedRectangle(cornerRadius: 16)) { isSelected in
                debugPrint("Hello World, \(isSelected)")
            }
            .foregroundStyle(.black)
            .font(.body)
        }
        .disabled(true)
        
        PKSPill { isSelected in
            debugPrint("Hello World, \(isSelected)")
        } label: {
            HStack {
                Text("Hello World")
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
            }
        }
        
        PKSPill { isSelected in
            debugPrint("Hello World, \(isSelected)")
        } label: {
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Hello World")
            }
        }
        .disabled(true)
        
        PKSPill("Change Clock", systemImage: "clock") { isSelected in
            debugPrint("Clock Clicked, \(isSelected)")
        }
    }
}
