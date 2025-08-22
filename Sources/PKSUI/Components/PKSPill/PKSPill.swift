//
//  PKSPill.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

/// A customizable pill-shaped button component that can display any content
/// - Parameters:
///   - L: The type of view used as the label content
///   - Sh: The shape type used for the background (default: Capsule)
struct PKSPill<L: View, Sh: Shape>: View {
    /// Environment value to track if the view is enabled/disabled
    @Environment(\.isEnabled) var isEnabled
    
    /// The action to perform when the pill is tapped
    let action: () -> Void
    /// The content to display inside the pill
    let label: L
    /// The shape used for the pill's background
    let shape: Sh
    
    /// Background color of the pill (default: red)
    var backgroundColor: Color = .red
    /// Padding around the label content
    var inset: EdgeInsets = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )
    
    /// Primary initializer for creating a pill with custom content
    /// - Parameters:
    ///   - action: The action to perform when tapped
    ///   - label: A ViewBuilder closure that provides the content
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> L
    ) where Sh == Capsule {
        self.action = action
        self.label = label()
        self.shape = Capsule() // Default to capsule shape
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            // Type checking to apply styling appropriately
            // Text and Label types get the pill styling applied
            if let label = label as? Text {
                preparedLabel
            } else if let label = label as? Label<Text,Image> {
                preparedLabel
            } else {
                // Custom views are rendered as-is without automatic styling
                label
            }
        }
        .opacity(isEnabled ? 1 : 0.5) // Reduce opacity when disabled
    }
    
    var preparedLabel: some View {
        label
            .padding(inset)
            .background(backgroundColor, in: shape)
    }
}

// MARK: - View Modifiers
extension PKSPill {
    /// Sets custom padding around the label content
    /// - Parameter inset: The EdgeInsets to apply
    /// - Returns: Modified instance with new insets
    public func setInset(_ inset: EdgeInsets) -> Self {
        map { view in
            view.inset = inset
        }
    }
    
    /// Sets uniform padding for specific edges
    /// - Parameters:
    ///   - edges: The edges to apply padding to (.all, .horizontal, .vertical, or specific edges)
    ///   - length: The padding amount in points
    /// - Returns: Modified instance with new insets
    public func setInset(_ edges: Edge.Set, _ length: CGFloat) -> Self {
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
    
    /// Sets the background color of the pill
    /// - Parameter color: The color to use for the background
    /// - Returns: Modified instance with new background color
    public func backgroundColor(_ color: Color) -> Self {
        map { view in
            view.backgroundColor = color
        }
    }
}

// MARK: - Text Convenience Initializers
extension PKSPill where L == Text {
    /// Creates a pill with a text label and default capsule shape
    /// - Parameters:
    ///   - title: The text to display
    ///   - action: The action to perform when tapped
    init<S: StringProtocol>(
        _ title: S,
        action: @escaping @MainActor () -> Void
    ) where Sh == Capsule {
        self.label = Text(title)
        self.action = action
        self.shape = Capsule()
    }
    
    /// Creates a pill with a text label and custom shape
    /// - Parameters:
    ///   - title: The text to display
    ///   - backgroundShape: Custom shape for the background
    ///   - action: The action to perform when tapped
    init<S: StringProtocol>(
        _ title: S,
        backgroundShape: Sh,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = Text(title)
        self.action = action
        self.shape = backgroundShape
    }
}

// MARK: - Label Convenience Initializers
extension PKSPill where L == Label<Text, Image> {
    /// Creates a pill with text and system image icon
    /// - Parameters:
    ///   - title: The text to display
    ///   - systemImage: The SF Symbol name for the icon
    ///   - action: The action to perform when tapped
    init<S: StringProtocol>(
        _ title: S,
        systemImage: String,
        action: @escaping @MainActor () -> Void
    ) where Sh == Capsule {
        self.label = Label(title, systemImage: systemImage)
        self.action = action
        self.shape = Capsule()
    }
    
    /// Creates a pill with text, system image icon, and custom shape
    /// - Parameters:
    ///   - title: The text to display
    ///   - systemImage: The SF Symbol name for the icon
    ///   - backgroundShape: Custom shape for the background
    ///   - action: The action to perform when tapped
    init<S: StringProtocol>(
        _ title: S,
        systemImage: String,
        backgroundShape: Sh,
        action: @escaping @MainActor () -> Void
    ) {
        self.label = Label(title, systemImage: systemImage)
        self.action = action
        self.shape = backgroundShape
    }
}

// MARK: - Preview
#if DEBUG && canImport(PreviewsMacros)
#Preview {
    VStack(spacing: 20) {
        PKSPill {
            debugPrint("On Tap")
        } label: {
            Rectangle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
        }
        
        HStack {
            PKSPill("Hello") {
                debugPrint("Hello World")
            }
            .setInset(
                EdgeInsets(
                    top: 24,
                    leading: 24,
                    bottom: 24,
                    trailing: 24
                )
            )
            .foregroundStyle(.black)
            .font(.largeTitle)
            
            PKSPill("Hello") {
                debugPrint("Hello World")
            }
            .foregroundStyle(.black)
            .font(.largeTitle)
            
            PKSPill("Hello", backgroundShape: RoundedRectangle(cornerRadius: 16)) {
                debugPrint("Hello World")
            }
            .foregroundStyle(.black)
            .font(.body)
        }
        .disabled(true)
        
        PKSPill {
            debugPrint("On Tap")
        } label: {
            HStack {
                Text("Hello World")
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
            }
        }
        
        PKSPill {
            debugPrint("On Tap")
        } label: {
            HStack {
                Image(systemName: "clock")
                    .resizable()
                    .frame(width: 20, height: 20)
                
                Text("Hello World")
            }
        }
        .disabled(true)
        
        PKSPill("Change Clock", systemImage: "clock") {
            debugPrint("Clock clicked")
        }
    }
}
#endif
