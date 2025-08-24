//
//  PKSPillSection.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/24/25.
//

import SwiftUI

/// A container view that manages a section of PKSPill components with selection limits.
///
/// `PKSPillSection` provides a way to group multiple PKSPill components together with an optional header,
/// and manage their selection behavior. It supports limiting the number of pills that can be selected
/// simultaneously within the section.
///
/// ## Usage Example
///
/// ```swift
/// PKSPillSection("Filter Options") {
///     PKSPill("Recent") { _ in }
///         .setPillTag("recent")
///     PKSPill("Popular") { _ in }
///         .setPillTag("popular")
///     PKSPill("Trending") { _ in }
///         .setPillTag("trending")
/// }
/// .selectionLimit(.single)
/// ```
///
/// - Parameters:
///   - Header: The type of view used for the section header.
///   - Content: The type of view containing the PKSPill components.
///
/// - Note: Pills within the section should use the `setPillTag(_:)` modifier for proper selection tracking.
public struct PKSPillSection<Header: View, Content: View>: View {
    /// The title identifier for this section.
    private let title: String
    
    /// A closure that provides the header content.
    private let header: () -> Header
    
    /// A closure that provides the pill content.
    private let content: () -> Content
    
    /// The selection limit configuration for this section.
    private var selectionLimit: PKSPillSelectionLimit = .unlimited
    
    /// Tracks the currently selected pill tags within this section.
    @State private var selectedItems: [AnyHashable] = []
    
    /// Environment value for propagating selection updates to parent views.
    @Environment(\.pksPillSectionStatusUpdate) private var sectionStatusUpdate
    
    /// Creates a pill section with a custom header.
    ///
    /// - Parameters:
    ///   - title: A unique identifier for this section.
    ///   - header: A ViewBuilder closure that provides the header content.
    ///   - content: A ViewBuilder closure that provides the PKSPill components.
    public init(
        title: String,
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.header = header
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            header()
            content()
        }
        .environment(\.pksPillSectionStatusUpdate, handleSelectionUpdate)
        .environment(\.pksPillSectionTitle, title)
    }
}

// MARK: - Convenience Initializers

extension PKSPillSection where Header == Text {
    /// Creates a pill section with a text header.
    ///
    /// This convenience initializer automatically creates a headline-styled text header.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillSection("Categories") {
    ///     PKSPill("Technology") { _ in }
    ///     PKSPill("Sports") { _ in }
    ///     PKSPill("Entertainment") { _ in }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the section header.
    ///   - content: A ViewBuilder closure that provides the PKSPill components.
    public init<S: StringProtocol>(
        _ title: S,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = String(title)
        self.header = {
            Text(title)
                .font(.headline)
        }
        self.content = content
    }
}

// MARK: - Selection Management

extension PKSPillSection {
    /// Handles selection updates from child PKSPill components.
    ///
    /// This method manages the selection state based on the configured selection limit.
    /// When the limit is reached, it automatically deselects the oldest selection to make room for the new one.
    ///
    /// - Parameters:
    ///   - sectionKey: The section identifier (currently unused but reserved for future use).
    ///   - item: The tag of the pill that was selected or deselected.
    private func handleSelectionUpdate(_ sectionKey: String, item: AnyHashable) {
        if selectedItems.contains(item) {
            selectedItems.removeAll(where: { $0 == item })
        } else {
            if let maxLimit = selectionLimit.limit, maxLimit == selectedItems.count {
                selectedItems = Array(selectedItems.dropFirst())
            }
            
            selectedItems.append(item)
        }
    }
    
    /// Sets the selection limit for pills within this section.
    ///
    /// Use this modifier to control how many pills can be selected simultaneously.
    ///
    /// ## Examples
    /// ```swift
    /// // Allow only one selection
    /// PKSPillSection("Size") { ... }
    ///     .selectionLimit(.single)
    ///
    /// // Allow up to 3 selections
    /// PKSPillSection("Interests") { ... }
    ///     .selectionLimit(.multiple(limit: 3))
    ///
    /// // Allow unlimited selections (default)
    /// PKSPillSection("Tags") { ... }
    ///     .selectionLimit(.unlimited)
    /// ```
    ///
    /// - Parameter limit: The selection limit configuration.
    /// - Returns: A modified instance with the specified selection limit.
    ///
    /// - Note: When the limit is reached, selecting a new pill will deselect the oldest selection.
    func selectionLimit(_ limit: PKSPillSelectionLimit) -> Self {
        map { view in
            view.selectionLimit = limit
        }
    }
}

#Preview {
    PKSPillSection("Test") {
        PKSPill("Test 1") { _ in
            
        }
        .setPillTag("Test 1")
        
        PKSPill("Test 2") { _ in
            
        }
        .setPillTag("Test 2")
        
        PKSPill("Test 3") { _ in
            
        }
        .setPillTag("Test 3")
        
        PKSPill("Test 4") { _ in
            
        }
    }
    .selectionLimit(.multiple(limit: 2))
}


