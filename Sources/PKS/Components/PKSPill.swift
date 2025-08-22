import SwiftUI

// Basit bir “Pill” (yuvarlak etiket) bileşeni
public struct PKSPill: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void
    
    public init(label: String,
                isSelected: Bool = false,
                onTap: @escaping () -> Void) {
        self.label = label
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Text(label)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
            .foregroundColor(isSelected ? .white : .black)
            .clipShape(Capsule())
            .onTapGesture {
                onTap()
            }
    }
}
