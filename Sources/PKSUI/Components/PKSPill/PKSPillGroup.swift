//
//  PKSPillGroup.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 9/6/25.
//

import SwiftUI

/// A container component that organizes multiple PKSPillSection components with consistent styling and behavior.
///
/// `PKSPillGroup` provides a structured way to group related pill sections together with optional header
/// and footer content, consistent spacing, and group-wide selection tracking capabilities.
///
/// ## Usage Example
///
/// ```swift
/// PKSPillGroup("Filter Settings") {
///     PKSPillSection("Sort By") {
///         PKSPill("Recent") { _ in }
///         PKSPill("Popular") { _ in }
///     }
///     .selectionLimit(.single)
///     
///     PKSPillSection("Categories") {
///         PKSPill("Technology") { _ in }
///         PKSPill("Sports") { _ in }
///         PKSPill("Entertainment") { _ in }
///     }
///     .selectionLimit(.multiple(limit: 2))
/// }
/// .groupSpacing(16)
/// .onGroupSelectionChange { section, selections in
///     print("Section \(section) updated: \(selections)")
/// }
/// ```
///
/// - Parameters:
///   - Header: The type of view used for the group header.
///   - Footer: The type of view used for the group footer.
///   - Content: The type of view containing the PKSPillSection components.
public struct PKSPillGroup<Header: View, Footer: View, Content: View>: View {
    /// The header content for the group.
    private let header: () -> Header
    
    /// The footer content for the group.
    private let footer: () -> Footer
    
    /// The content containing PKSPillSection components.
    private let content: () -> Content
    
    /// Spacing between sections within the group.
    private var sectionSpacing: CGFloat = 12
    
    /// Padding around the entire group content.
    private var groupPadding: EdgeInsets = EdgeInsets()
    
    /// Callback for individual section selection changes.
    private var onSelectionChange: ((String, [AnyHashable]) -> Void)?
    
    /// Callback for all group selections.
    private var onAllSelectionsChange: (([String: [AnyHashable]]) -> Void)?
    
    /// Tracks selections across all sections in the group.
    @State private var groupSelections: [String: [AnyHashable]] = [:]
    
    /// Environment value for propagating selection updates from sections.
    @Environment(\.pksPillGroupSelectionUpdate) private var parentGroupUpdate
    
    /// Creates a pill group with custom header and footer.
    ///
    /// - Parameters:
    ///   - header: A ViewBuilder closure that provides the header content.
    ///   - footer: A ViewBuilder closure that provides the footer content.
    ///   - content: A ViewBuilder closure that provides the PKSPillSection components.
    public init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder footer: @escaping () -> Footer,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = footer
        self.content = content
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: sectionSpacing) {
            header()
            
            content()
                .environment(\.pksPillGroupSelectionUpdate, handleSectionUpdate)
            
            footer()
        }
        .padding(groupPadding)
    }
}

// MARK: - Convenience Initializers

extension PKSPillGroup where Header == EmptyView, Footer == EmptyView {
    /// Creates a pill group with only content, no header or footer.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup {
    ///     PKSPillSection("Options") { ... }
    ///     PKSPillSection("Settings") { ... }
    /// }
    /// ```
    ///
    /// - Parameter content: A ViewBuilder closure that provides the PKSPillSection components.
    public init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = { EmptyView() }
        self.footer = { EmptyView() }
        self.content = content
    }
}

extension PKSPillGroup where Header == Text, Footer == EmptyView {
    /// Creates a pill group with a text header and no footer.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup("Preferences") {
    ///     PKSPillSection("Display") { ... }
    ///     PKSPillSection("Notifications") { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - title: The text to display as the group header.
    ///   - content: A ViewBuilder closure that provides the PKSPillSection components.
    public init<S: StringProtocol>(
        _ title: S,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
        }
        self.footer = { EmptyView() }
        self.content = content
    }
}

extension PKSPillGroup where Header == EmptyView, Footer == Text {
    /// Creates a pill group with no header and a text footer.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup(footer: "Select up to 3 options") {
    ///     PKSPillSection("Interests") { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - footer: The text to display as the group footer.
    ///   - content: A ViewBuilder closure that provides the PKSPillSection components.
    public init<S: StringProtocol>(
        footer: S,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = { EmptyView() }
        self.footer = {
            Text(footer)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        self.content = content
    }
}

extension PKSPillGroup where Footer == EmptyView {
    /// Creates a pill group with a custom header and no footer.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup(header: {
    ///     HStack {
    ///         Image(systemName: "slider.horizontal.3")
    ///         Text("Filters")
    ///     }
    /// }) {
    ///     PKSPillSection("Type") { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - header: A ViewBuilder closure that provides the header content.
    ///   - content: A ViewBuilder closure that provides the PKSPillSection components.
    public init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.footer = { EmptyView() }
        self.content = content
    }
}

extension PKSPillGroup where Header == EmptyView {
    /// Creates a pill group with no header and a custom footer.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup {
    ///     PKSPillSection("Selected") { ... }
    /// } footer: {
    ///     Button("Clear All") { ... }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - content: A ViewBuilder closure that provides the PKSPillSection components.
    ///   - footer: A ViewBuilder closure that provides the footer content.
    public init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.header = { EmptyView() }
        self.footer = footer
        self.content = content
    }
}

// MARK: - Selection Management

extension PKSPillGroup {
    /// Handles selection updates from child PKSPillSection components.
    ///
    /// - Parameters:
    ///   - section: The section identifier where the selection occurred.
    ///   - selections: The current selections within that section.
    private func handleSectionUpdate(_ section: String, selections: [AnyHashable]) {
        // Update or remove the section based on selections
        if selections.isEmpty {
            groupSelections.removeValue(forKey: section)
        } else {
            groupSelections[section] = selections
        }
        
        // Call individual section callback
        onSelectionChange?(section, selections)
        
        // Call all selections callback with complete state
        onAllSelectionsChange?(groupSelections)
        
        // Propagate to parent group if nested
        if let parentGroupUpdate {
            parentGroupUpdate(section, selections)
        }
    }
    
    /// Sets a callback for individual section selection changes.
    ///
    /// This callback is invoked whenever any pill selection changes within a specific section.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup("Filters") { ... }
    ///     .onGroupSelectionChange { section, selections in
    ///         print("Section '\(section)' selections: \(selections)")
    ///     }
    /// ```
    ///
    /// - Parameter callback: A closure called with the section identifier and current selections for that section.
    /// - Returns: A modified instance with the selection change handler.
    public func onGroupSelectionChange(_ callback: @escaping (String, [AnyHashable]) -> Void) -> Self {
        map { view in
            view.onSelectionChange = callback
        }
    }
    
    /// Sets a callback that provides all selections across all sections in the group.
    ///
    /// This callback is invoked whenever any pill selection changes and provides the complete
    /// state of all selections in the group as a dictionary.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup("Filters") { ... }
    ///     .onAllSelectionsChange { allSelections in
    ///         print("All group selections:")
    ///         for (section, selections) in allSelections {
    ///             print("  \(section): \(selections)")
    ///         }
    ///     }
    /// ```
    ///
    /// - Parameter callback: A closure called with a dictionary containing all sections and their selections.
    /// - Returns: A modified instance with the all selections change handler.
    public func onAllSelectionsChange(_ callback: @escaping ([String: [AnyHashable]]) -> Void) -> Self {
        map { view in
            view.onAllSelectionsChange = callback
        }
    }
    
    /// Provides the current state of all selections in the group.
    ///
    /// This computed property returns a dictionary where keys are section identifiers
    /// and values are arrays of selected pill tags within each section.
    ///
    /// ## Example
    /// ```swift
    /// let currentSelections = pillGroup.allSelections
    /// print("Total sections with selections: \(currentSelections.count)")
    /// ```
    public var allSelections: [String: [AnyHashable]] {
        groupSelections
    }
    
    /// Provides a flattened array of all selected items across all sections.
    ///
    /// ## Example
    /// ```swift
    /// let allSelected = pillGroup.flattenedSelections
    /// print("Total selected items: \(allSelected.count)")
    /// ```
    public var flattenedSelections: [AnyHashable] {
        groupSelections.values.flatMap { $0 }
    }
}

// MARK: - Styling Modifiers

extension PKSPillGroup {
    /// Sets the spacing between sections within the group.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup { ... }
    ///     .groupSpacing(20)
    /// ```
    ///
    /// - Parameter spacing: The spacing in points between sections.
    /// - Returns: A modified instance with the specified spacing.
    public func groupSpacing(_ spacing: CGFloat) -> Self {
        map { view in
            view.sectionSpacing = spacing
        }
    }
    
    /// Sets padding around the entire group content.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup { ... }
    ///     .groupPadding(EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20))
    /// ```
    ///
    /// - Parameter padding: The EdgeInsets to apply around the group.
    /// - Returns: A modified instance with the specified padding.
    public func groupPadding(_ padding: EdgeInsets) -> Self {
        map { view in
            view.groupPadding = padding
        }
    }
    
    /// Sets uniform padding for specific edges of the group.
    ///
    /// ## Example
    /// ```swift
    /// PKSPillGroup { ... }
    ///     .groupPadding(.horizontal, 16)
    /// ```
    ///
    /// - Parameters:
    ///   - edges: The edges to apply padding to.
    ///   - length: The padding amount in points.
    /// - Returns: A modified instance with the specified padding.
    public func groupPadding(_ edges: Edge.Set, _ length: CGFloat) -> Self {
        map { view in
            var local = view.groupPadding
            
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
            
            view.groupPadding = local
        }
    }
}

// MARK: - Preview
#Preview("Basic Group") {
    PKSPillGroup("Filter Options") {
        PKSPillSection("Sort By") {
            PKSPill("Recent") { _ in }
                .setPillTag("recent")
            PKSPill("Popular") { _ in }
                .setPillTag("popular")
            PKSPill("Trending") { _ in }
                .setPillTag("trending")
        }
        .selectionLimit(.single)
        
        PKSPillSection("Categories") {
            PKSPill("Technology") { _ in }
                .setPillTag("tech")
            PKSPill("Sports") { _ in }
                .setPillTag("sports")
            PKSPill("Entertainment") { _ in }
                .setPillTag("entertainment")
            PKSPill("Science") { _ in }
                .setPillTag("science")
        }
        .selectionLimit(.multiple(limit: 2))
        
        PKSPillSection("Time Range") {
            PKSPill("Today") { _ in }
                .setPillTag("today")
            PKSPill("This Week") { _ in }
                .setPillTag("week")
            PKSPill("This Month") { _ in }
                .setPillTag("month")
            PKSPill("All Time") { _ in }
                .setPillTag("all")
        }
        .selectionLimit(.single)
    }
    .groupSpacing(24)
    .groupPadding(.all, 16)
    .onGroupSelectionChange { section, selections in
        print("Section '\(section)' updated: \(selections)")
    }
    .onAllSelectionsChange { allSelections in
        print("\n=== All Group Selections ===")
        if allSelections.isEmpty {
            print("No selections")
        } else {
            for (section, selections) in allSelections.sorted(by: { $0.key < $1.key }) {
                print("  \(section): \(selections)")
            }
        }
        print("============================\n")
    }
}

#Preview("Custom Header and Footer") {
    PKSPillGroup(
        header: {
            HStack {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                Text("Advanced Filters")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Reset") {
                    print("Reset filters")
                }
                .font(.caption)
            }
            .padding(.bottom, 8)
        },
        footer: {
            Text("Select multiple options to refine your search")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
    ) {
        PKSPillSection("Price Range") {
            PKSPill("$") { _ in }
                .setPillTag("low")
            PKSPill("$$") { _ in }
                .setPillTag("medium")
            PKSPill("$$$") { _ in }
                .setPillTag("high")
            PKSPill("$$$$") { _ in }
                .setPillTag("luxury")
        }
        .selectionLimit(.multiple(limit: 3))
        
        PKSPillSection("Rating") {
            PKSPill("5 Stars") { _ in }
                .setPillTag("5")
            PKSPill("4+ Stars") { _ in }
                .setPillTag("4+")
            PKSPill("3+ Stars") { _ in }
                .setPillTag("3+")
        }
        .selectionLimit(.single)
    }
    .groupSpacing(20)
    .groupPadding(.horizontal, 20)
}

#Preview("Minimal Group") {
    PKSPillGroup {
        PKSPillSection("Quick Actions") {
            PKSPill("Copy", systemImage: "doc.on.doc") { _ in }
            PKSPill("Share", systemImage: "square.and.arrow.up") { _ in }
            PKSPill("Delete", systemImage: "trash") { _ in }
        }
    }
    .groupPadding(.all, 12)
}

