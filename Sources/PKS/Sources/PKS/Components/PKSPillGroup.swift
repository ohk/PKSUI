import SwiftUI

public struct PKSPillGroup: View {
    public var options: [String]
    public var maxSelected: Int = 99
    public var isSingle: Bool = false

    @State private var selected: [String] = []

    public init(options: [String],
                maxSelected: Int = 99,
                isSingle: Bool = false,
                preselected: [String] = []) {
        self.options = options
        self.maxSelected = maxSelected
        self.isSingle = isSingle
        self._selected = State(initialValue: preselected)
    }

    public var body: some View {
        let cols = [GridItem(.adaptive(minimum: 100))]
        LazyVGrid(columns: cols, spacing: 8) {
            ForEach(options, id: \.self) { text in
                PKSPill(
                    label: text,
                    isSelected: selected.contains(text)
                ) {
                    tapped(text)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func tapped(_ text: String) {
        if isSingle {
            selected = [text]
            return
        }

        if let i = selected.firstIndex(of: text) {
            selected.remove(at: i)
        } else {
            if selected.count < maxSelected {
                selected.append(text)
            } else {
                print("En fazla \(maxSelected) seçim yapılabilir")
            }
        }
    }
}
