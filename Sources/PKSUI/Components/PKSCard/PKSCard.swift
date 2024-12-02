//
//  PKSCard.swift
//  PKSCore
//
//  Created by Ömer Hamid Kamışlı on 12/1/24.
//

import SwiftUI

// MARK: - PKSCard View

/// A customizable card view component.
///
/// The `PKSCard` struct provides a flexible and customizable card layout that can include content, headers, and footers. It leverages SwiftUI's environment system to allow for extensive customization of its appearance, including background color, shadow, border, shape, alignment, spacing, and insets.
///
/// `PKSCard` supports various initializers to accommodate different configurations, such as cards with only content, content with a header, content with a footer, or content with both a header and a footer.
///
/// - Note: `PKSCard` is marked with `@MainActor` to ensure that all UI updates occur on the main thread.
///
/// - Example:
/// ```swift
/// PKSCard {
///     VStack(alignment: .leading, spacing: 8) {
///         Text("Card Title")
///             .font(.headline)
///         Text("Card description goes here.")
///             .font(.subheadline)
///     }
/// }
/// .cardBackgroundColor(.white)
/// .cardShadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
/// .cardBorder(color: .blue, width: 2)
/// .cardShape(RoundedRectangle(cornerRadius: 16))
/// ```

@MainActor
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct PKSCard<Content: View, Header: View, Footer: View>: View {
    
    // MARK: - Properties
    
    /// The main content of the card.
    private let content: Content
    
    /// The header view of the card.
    private let header: Header
    
    /// The footer view of the card.
    private let footer: Footer
    
    /// The background color of the card, sourced from the environment.
    @Environment(\.pksCardBackgroundColor) private var backgroundColor
    
    /// The shadow radius of the card, sourced from the environment.
    @Environment(\.pksCardShadowRadius) private var shadowRadius
    
    /// The shadow color of the card, sourced from the environment.
    @Environment(\.pksCardShadowColor) private var shadowColor
    
    /// The Y offset of the card's shadow, sourced from the environment.
    @Environment(\.pksCardShadowY) private var shadowY
    
    /// The X offset of the card's shadow, sourced from the environment.
    @Environment(\.pksCardShadowX) private var shadowX
    
    /// The border color of the card, sourced from the environment.
    @Environment(\.pksCardBorderColor) private var borderColor
    
    /// The border width of the card, sourced from the environment.
    @Environment(\.pksCardBorderWidth) private var borderWidth
    
    /// The alignment of the container within the card, sourced from the environment.
    @Environment(\.pksCardContainerAlignment) private var containerAlignment
    
    /// Determines whether dividers are shown within the card, sourced from the environment.
    @Environment(\.pksCardShowDivider) private var showDivider
    
    /// The shape of the card, sourced from the environment.
    @Environment(\.pksCardShape) private var cardShape
    
    /// The spacing between elements in the card's container, sourced from the environment.
    @Environment(\.pksCardContainerSpacing) private var containerSpacing
    
    /// The insets of the card, sourced from the environment.
    @Environment(\.pksCardInsets) private var cardInsets
    
    /// The opacity of the card when it is disabled, sourced from the environment.
    @Environment(\.pksDisabledOpacity) private var disabledOpacity

    /// Determines whether the card is disabled, sourced from the environment.
    @Environment(\.isEnabled) private var isEnabled
    
    /// Initializes a `PKSCard` with content, a header, and a footer.
    ///
    /// - Parameters:
    ///   - content: A view builder that provides the main content of the card.
    ///   - header: A view builder that provides the header of the card.
    ///   - footer: A view builder that provides the footer of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard(content: {
    ///     Text("Card Content")
    /// }, header: {
    ///     Text("Card Header")
    /// }, footer: {
    ///     Button("Action") { }
    /// })
    /// ```
    @MainActor
    public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.content = content()
        self.header = header()
        self.footer = footer()
    }
    
    // MARK: - Body
    
    /// The body of the `PKSCard` view.
    ///
    /// Composes the header, content, and footer within a vertically stacked layout, applying the specified insets, background, border, shape, and shadow.
    ///
    /// - Accessibility:
    ///   - The header is marked as a header trait.
    ///   - The content is contained within an accessibility element.
    ///   - The footer is marked as a static text trait.
    public var body: some View {
        Group {
            VStack(alignment: containerAlignment, spacing: containerSpacing) {
                header
                    .conditionalRenderer { view in
                        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                            view
                                .accessibilityAddTraits(.isHeader)
                        } else {
                            view
                        }
                    }
                   
                if showDivider, !(header is EmptyView) {
                    Divider()
                }
                content
                    .accessibilityElement(children: .contain)
                if showDivider, !(footer is EmptyView) {
                    Divider()
                }
                footer
            }
            .padding(cardInsets)
            .background(backgroundColor)
            .clipShape(AnyShapeWrapper(shape: cardShape))
            .overlay(
                AnyShapeWrapper(shape: cardShape)
                    .stroke(borderColor ?? .clear, lineWidth: borderWidth)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: shadowX,
                y: shadowY
            )
            .accessibilityElement(children: .contain)
            .conditionalRenderer { view in
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    view
                        .accessibilityAddTraits(.isStaticText)
                } else {
                    view
                }
            }
        }
        .opacity(isEnabled ? 1 : disabledOpacity)
    }
}

// MARK: - PKSCard Extensions for Specific Initializers

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension PKSCard where Footer == EmptyView {
    /// Initializes a `PKSCard` with content and a header.
    ///
    /// - Parameters:
    ///   - content: A view builder that provides the main content of the card.
    ///   - header: A view builder that provides the header of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard(content: {
    ///     Text("Card Content")
    /// }, header: {
    ///     Text("Card Header")
    /// })
    /// ```
    @MainActor
    public init(@ViewBuilder content: () -> Content, @ViewBuilder header: () -> Header) {
        self.content = content()
        self.header = header()
        self.footer = EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension PKSCard where Header == EmptyView {
    /// Initializes a `PKSCard` with content and a footer.
    ///
    /// - Parameters:
    ///   - content: A view builder that provides the main content of the card.
    ///   - footer: A view builder that provides the footer of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard(content: {
    ///     Text("Card Content")
    /// }, footer: {
    ///     Button("Action") { }
    /// })
    /// ```
    @MainActor
    public init(@ViewBuilder content: () -> Content, @ViewBuilder footer: () -> Footer)  {
        self.content = content()
        self.header = EmptyView()
        self.footer = footer()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension PKSCard where Header == EmptyView, Footer == EmptyView {
    /// Initializes a `PKSCard` with only content.
    ///
    /// - Parameter content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard {
    ///     Text("Simple Card")
    /// }
    /// ```
    @MainActor
    public init(@ViewBuilder content: () -> Content)  {
        self.content = content()
        self.header = EmptyView()
        self.footer = EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension PKSCard where Header == ModifiedContent<Text, AccessibilityAttachmentModifier>, Footer == EmptyView {
    
    /// Initializes a `PKSCard` with a localized title and content.
    ///
    /// - Parameters:
    ///   - titleKey: A localized string key for the card's title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("welcome_title") {
    ///     Text("Welcome to the app!")
    /// }
    /// ```
    public init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.content = content()
        if #available (iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.header = Text(titleKey)
                .pksTextStyle()
                .accessibilityLabel(titleKey)
        } else {
            self.header = Text(titleKey)
                .pksTextStyle()
                .accessibility(label: Text(titleKey))
        }
        self.footer = EmptyView()
    }
    
    /// Initializes a `PKSCard` with a title and content.
    ///
    /// - Parameters:
    ///   - title: A string representing the card's title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("Welcome") {
    ///     Text("Hello, User!")
    /// }
    /// ```
    public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.content = content()
        
        if #available (iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.header = Text(title)
                .pksTextStyle()
                .accessibilityLabel(title)
        } else {
            self.header = Text(title)
                .pksTextStyle()
                .accessibility(label: Text(title))
        }
        
        self.footer = EmptyView()
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension PKSCard where Header == EmptyView, Footer == ModifiedContent<Text, AccessibilityAttachmentModifier> {
    
    /// Initializes a `PKSCard` with content and a localized footer.
    ///
    /// - Parameters:
    ///   - content: A view builder that provides the main content of the card.
    ///   - footerKey: A localized string key for the card's footer.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard(content: {
    ///     Text("Content")
    /// }, "footer_message")
    /// ```
    public init(@ViewBuilder content: () -> Content, _ footerKey: LocalizedStringKey) {
        self.content = content()
        self.header = EmptyView()
        
        if #available (iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.footer = Text(footerKey)
                .pksTextStyle()
                .accessibilityLabel(footerKey)
        } else {
            self.footer = Text(footerKey)
                .pksTextStyle()
                .accessibility(label: Text(footerKey))
        }
    }
    
    /// Initializes a `PKSCard` with content and a footer.
    ///
    /// - Parameters:
    ///   - content: A view builder that provides the main content of the card.
    ///   - footer: A string representing the card's footer.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard(content: {
    ///     Text("Content")
    /// }, "Footer")
    /// ```
    public init<S>(@ViewBuilder content: () -> Content, _ footer: S) where S : StringProtocol {
        self.content = content()
        self.header = EmptyView()
        
        if #available (iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            self.footer = Text(footer)
                .pksTextStyle()
                .accessibilityLabel(footer)
        } else {
            self.footer = Text(footer)
                .pksTextStyle()
                .accessibility(label: Text(footer))
        }
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 6.0, *)
extension PKSCard where Header == ModifiedContent<Label<Text, Image>, AccessibilityAttachmentModifier>, Footer == EmptyView {
    
    /// Initializes a `PKSCard` with a localized title, an image, and content.
    ///
    /// - Parameters:
    ///   - titleKey: A localized string key for the card's title.
    ///   - image: An image resource to display alongside the title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("Settings", image: Image("settingsIcon")) {
    ///     Text("App Settings")
    /// }
    /// ```
    public init(_ titleKey: LocalizedStringKey, image: ImageResource, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = Label(titleKey, image: image)
            .accessibilityLabel(titleKey)
        self.footer = EmptyView()
    }

    /// Initializes a `PKSCard` with a title, an image, and content.
    ///
    /// - Parameters:
    ///   - title: A string representing the card's title.
    ///   - image: An image resource to display alongside the title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("Settings", image: Image("settingsIcon")) {
    ///     Text("App Settings")
    /// }
    /// ```
    public init<S>(_ title: S, image: ImageResource, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.content = content()
        self.header = Label(title, image: image)
            .accessibilityLabel(Text(title))
        self.footer = EmptyView()
    }
}

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 6.0, *)
extension PKSCard where Header == ModifiedContent<Label<Text, Image>, AccessibilityAttachmentModifier>, Footer == EmptyView {
    
    /// Initializes a `PKSCard` with a localized title, a system image, and content.
    ///
    /// - Parameters:
    ///   - titleKey: A localized string key for the card's title.
    ///   - systemImage: The name of a system image to display alongside the title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("Notifications", systemImage: "bell") {
    ///     Text("Manage your notifications")
    /// }
    /// ```
    public init(_ titleKey: LocalizedStringKey, systemImage: String, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.header = Label(titleKey, systemImage: systemImage)
            .accessibilityLabel(titleKey)
        self.footer = EmptyView()
    }

    /// Initializes a `PKSCard` with a title, a system image, and content.
    ///
    /// - Parameters:
    ///   - title: A string representing the card's title.
    ///   - systemImage: The name of a system image to display alongside the title.
    ///   - content: A view builder that provides the main content of the card.
    ///
    /// - Example:
    /// ```swift
    /// PKSCard("Notifications", systemImage: "bell") {
    ///     Text("Manage your notifications")
    /// }
    /// ```
    public init<S>(_ title: S, systemImage: String, @ViewBuilder content: () -> Content) where S : StringProtocol {
        self.content = content()
        self.header = Label(title, systemImage: systemImage)
            .accessibilityLabel(Text(title))
        self.footer = EmptyView()
    }
}



// MARK: - Preview
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
struct PKSCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Default card
                PKSCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Card")
                            .font(.headline)
                        Text("This is a default card with standard styling")
                            .font(.subheadline)
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibility(label: Text("Default Card: This is a default card with standard styling"))
                
                // Customized card with a different shape
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
                    PKSCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Customized Card")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("This card has custom styling")
                                .font(.subheadline)
                        }
                    }
                    .cardBackgroundColor(.blue.opacity(0.05))
                    .cardShadow(
                        color: .blue.opacity(0.2),
                        radius: 8,
                        x: 2,
                        y: 4
                    )
                    .cardBorder(color: .blue)
                    .cardShape(Capsule())
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Customized Card: This card has custom styling")
                } else {
                    PKSCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Customized Card")
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text("This card has custom styling")
                                .font(.subheadline)
                        }
                    }
                    .cardBackgroundColor(.blue.opacity(0.05))
                    .cardShadow(
                        color: .blue.opacity(0.2),
                        radius: 8,
                        x: 2,
                        y: 4
                    )
                    .cardBorder(color: .blue)
                    .cardShape(PKSCardShape.roundedRectangle(cornerRadius: 12)) // Applying a Capsule shape
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Customized Card: This card has custom styling"))
                }
                
                // Another customized card with a different shape and footer
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
                    PKSCard("Title") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Another Card")
                                .font(.headline)
                            Text("This card uses a different shape")
                                .font(.subheadline)
                        }
                    }
                    .cardShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .cardBackgroundColor(.green.opacity(0.1))
                    .cardShadow(
                        color: .green.opacity(1),
                        radius: 10,
                        x: 5,
                        y: 5
                    )
                    .cardBorder(color: .green, width: 2)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Title: Another Card: This card uses a different shape")
                } else {
                    PKSCard("Title") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Another Card")
                                .font(.headline)
                            Text("This card uses a different shape")
                                .font(.subheadline)
                        }
                    }
                    .cardShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    .cardBackgroundColor(.green.opacity(0.1))
                    .cardShadow(
                        color: .green.opacity(1),
                        radius: 10,
                        x: 5,
                        y: 5
                    )
                    .cardBorder(color: .green, width: 2)
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Title: Another Card: This card uses a different shape"))
                }
                
                // Card with Header and Footer
                PKSCard(
                    content: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Card with Header and Footer")
                                .font(.headline)
                            Text("This card includes both a header and a footer for additional context.")
                                .font(.subheadline)
                        }
                    },
                    header: {
                        Text("Header")
                    },
                    footer: {
                        Button(action: {
                            // Action here
                        }) {
                            Text("Action Button")
                                .font(.body)
                                .foregroundColor(.blue)
                        }
                        .accessibility(label: Text("Action Button"))
                    }
                )
                .accessibilityElement(children: .contain)
                .accessibility(label: Text("Card with Header and Footer: Header, Content, and an action button"))
                
                // Card with Image in Header
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
                    PKSCard("Profile") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("John Doe")
                                .font(.headline)
                            Text("iOS Developer at OpenAI")
                                .font(.subheadline)
                        }
                    }
                    .cardShape(RoundedRectangle(cornerRadius: 16))
                    .cardBackgroundColor(.yellow.opacity(0.1))
                    .cardShadow(
                        color: .yellow.opacity(0.3),
                        radius: 6,
                        x: 3,
                        y: 3
                    )
                    .cardBorder(color: .yellow, width: 1.5)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Profile: John Doe, iOS Developer at OpenAI")
                } else {
                    PKSCard("Profile") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("John Doe")
                                .font(.headline)
                            Text("iOS Developer at OpenAI")
                                .font(.subheadline)
                        }
                    }
                    .cardShape(RoundedRectangle(cornerRadius: 16))
                    .cardBackgroundColor(.yellow.opacity(0.1))
                    .cardShadow(
                        color: .yellow.opacity(0.3),
                        radius: 6,
                        x: 3,
                        y: 3
                    )
                    .cardBorder(color: .yellow, width: 1.5)
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Profile: John Doe, iOS Developer at OpenAI"))
                }
                
                // Card with Custom Shape
                if #available(macOS 13.0, iOS 16.0, tvOS 16.0, *) {
                    PKSCard {
                        Text("New")
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                    .cardShape(
                        StarShape(points: 5)
                            .rotation(.degrees(54))
                    )
                    .cardBackgroundColor(.purple.opacity(0.1))
                    .cardShadow(
                        color: .purple.opacity(0.3),
                        radius: 5,
                        x: 0,
                        y: 5
                    )
                    .cardBorder(color: .purple, width: 2)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Custom Shape Card: This card uses a star shape for its background")
                } else {
                    PKSCard {
                        Text("New")
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                    .cardShape(
                        StarShape(points: 5)
                            .rotation(.degrees(54))
                    )
                    .cardBackgroundColor(.purple.opacity(0.1))
                    .cardShadow(
                        color: .purple.opacity(0.3),
                        radius: 5,
                        x: 0,
                        y: 5
                    )
                    .cardBorder(color: .purple, width: 2)
                    .accessibilityElement(children: .contain)
                    .accessibility(label: Text("Custom Shape Card: This card uses a star shape for its background"))
                    
                }
            }
            .padding()
        }
    }
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
fileprivate struct AnyShapeWrapper: Shape {
    let shape: any Shape

    func path(in rect: CGRect) -> Path {
        shape.path(in: rect)
    }
}


// MARK: - Text Extension for Styling
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
fileprivate extension Text {
    
    /// Applies the predefined PKS text style to the `Text` view.
    ///
    /// This style sets the font to `.headline`, the font weight to `.semibold`, the foreground color to `.primary`, and adds the `.isHeader` accessibility trait.
    ///
    /// - Returns: A modified `Text` view with the PKS text style applied.
    func pksTextStyle() -> Text {
        self
            .font(.headline)
            .fontWeight(.semibold)
    }
}
