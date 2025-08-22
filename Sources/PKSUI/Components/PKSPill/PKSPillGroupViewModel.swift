//
//  PKSPillGroupViewModel.swift
//  PKSUI
//
//  Created by Gülzade Karataş on 22.08.2025.
//
import SwiftUI

final class PKSPillGroupViewModel: ObservableObject {
    @Published var selectedIDs: [UUID] = [] // Tracks selected pill IDs
    let maxSelection: Int // Maximum number of selectable pills

    init(maxSelection: Int) {
        self.maxSelection = maxSelection
    }

    func isSelected(_ id: UUID) -> Bool {
        selectedIDs.contains(id) // Check if a pill is selected
    }

    func toggleSelection(for id: UUID) {
        if selectedIDs.contains(id) {
            print("❎ ID already selected. Removing: \(id)")
            selectedIDs.removeAll { $0 == id } // Deselect all if only one selection allowed
        } else if selectedIDs.count < maxSelection {
            print("🆕 Adding ID: \(id)")
                selectedIDs.append(id)
            
        }
    }

    var canSelectMore: Bool {
        selectedIDs.count < maxSelection
    }
}
