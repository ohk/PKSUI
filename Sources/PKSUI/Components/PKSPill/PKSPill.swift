//
//  PKSPill.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

struct PKSPill<L: View, Sh: Shape>: View {
    @Environment(\.isEnabled) var isEnabled
    let id: UUID
    @ObservedObject var groupVM: PKSPillGroupViewModel
    var action: () -> Void
    var label: L
    var backgroundColor: Color = Color.red
    var shape: Sh
    var inset: EdgeInsets = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )
    
    var isSelected: Bool {
        let result = groupVM.isSelected(id)
       // print("🔍 isSelected for ID \(id): \(result)")
        return result
    }
    
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> L,
        groupVM: PKSPillGroupViewModel
    ) where Sh == Capsule {
        self.id = UUID()
        self.action = action
        self.label = label()
        self.shape = Capsule()
        self.groupVM = groupVM
        
    }
    
    var body: some View {
        
        Button {
            // Toggle selection if the ID is already selected
            if groupVM.selectedIDs.contains(id) {
                print("🔄 Deselecting ID:", id)
                groupVM.toggleSelection(for: id)
                print("Tapped ID: \(id)")
            }// Select new ID if max selection not reached
            else if groupVM.selectedIDs.count < groupVM.maxSelection {
                print("✅ Selecting ID:", id)
                groupVM.toggleSelection(for: id)
                print("Tapped ID: \(id)")
            } else {
                print("❌ Max selection reached. Doing nothing.")
            }
        } label: {
            let currentLabel = label
            // If the label is of type Text, apply style
            if let label = currentLabel as? Text {
                label
                    .padding(inset)
                    .background(groupVM.isSelected(id) ? Color.accentColor : Color.red.opacity(0.2), in: shape)
                    .foregroundColor(groupVM.isSelected(id) ? .white : .primary)
            } // If the label is of type Label (Text + Image), apply style
            else if let label = currentLabel as? Label<Text, Image> {
                label
                    .padding(inset)
                    .background(groupVM.isSelected(id) ? Color.accentColor : Color.red.opacity(0.2), in: shape)
                    .foregroundColor(groupVM.isSelected(id) ? .white : .primary)
            } else {
                currentLabel
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
        // Animate changes in selection
        .animation(.easeInOut, value: groupVM.isSelected(id))
        // Apply shadow when selected
        .shadow(color: groupVM.isSelected(id) ? Color.black.opacity(0.2) : .clear, radius: 3)
        // Add a stroke border when selected
        .overlay(
            shape
                .stroke(groupVM.isSelected(id) ? Color.accentColor : .clear, lineWidth: 2)
        )
    }
    
    public func setInset(_ inset: EdgeInsets) -> Self {
        map { view in
            view.inset = inset
        }
    }
    
    public func setInset(_ edges: Edge.Set, _ lenght: CGFloat) -> Self {
        map { view in
            var local = view.inset
            
            if edges.contains(.all) {
                local = EdgeInsets(
                    top: lenght,
                    leading: lenght,
                    bottom: lenght,
                    trailing: lenght
                )
            } else {
                if edges.contains(.bottom) {
                    local.bottom = lenght
                }
                
                if edges.contains(.leading) {
                    local.leading = lenght
                }
                
                if edges.contains(.top) {
                    local.top = lenght
                }
                
                if edges.contains(.trailing) {
                    local.trailing = lenght
                }
                
                if edges.contains(.horizontal) {
                    local.leading = lenght
                    local.trailing = lenght
                }
                
                if edges.contains(.vertical) {
                    local.top = lenght
                    local.bottom = lenght
                }
            }
            
            
            view.inset = local
        }
    }
    
    public func backgroundColor(_ color: Color) -> Self {
        map { view in
            view.backgroundColor = color
        }
    }
}

extension PKSPill where L == Text {
    init<S: StringProtocol> (
        _ title: S,
        action: @escaping @MainActor () -> Void
    ) where Sh == Capsule {
        label = {
            Text(title)
        }()
        
        self.action = action
        self.shape = Capsule()
        self.id = UUID()
        self.groupVM = PKSPillGroupViewModel(maxSelection: 1)
    }
    
    init<S: StringProtocol> (
        _ title: S,
        backgroundShape: Sh,
        action: @escaping @MainActor () -> Void
    ) {
        label = {
            Text(title)
        }()
        
        self.action = action
        self.shape = backgroundShape
        self.id = UUID()
        self.groupVM = PKSPillGroupViewModel(maxSelection: 1)
    }
}

extension PKSPill where L == Label<Text, Image>{
    init<S: StringProtocol> (
        _ title: S,
        systemImage: String,
        action: @escaping @MainActor () -> Void
    ) where Sh == Capsule {
        label = {
            Label(title, systemImage: systemImage)
        }()
        
        self.action = action
        self.shape = Capsule()
        self.id = UUID()
        self.groupVM = PKSPillGroupViewModel(maxSelection: 1)
    }
    
    init<S: StringProtocol> (
        _ title: S,
        systemImage: String,
        backgroundShape: Sh,
        action: @escaping @MainActor () -> Void
    ) {
        label = {
            Label(title, systemImage: systemImage)
        }()
        
        self.action = action
        self.shape = backgroundShape
        self.id = UUID()
        self.groupVM = PKSPillGroupViewModel(maxSelection: 1)
    }
}

extension PKSPill where L == Label<Text, Image>, Sh == Capsule {
    init<S: StringProtocol>(
        id:UUID,
        _ title: S,
        systemImage: String,
        groupVM: PKSPillGroupViewModel,
        action: @escaping @MainActor () -> Void
    ) {
        self.id = id
        self.label = {
            Label(title, systemImage: systemImage)
        }()
        self.shape = Capsule()
        self.action = action
        self.groupVM = groupVM
    }
}

#Preview {
    /*
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
    
    PKSPill("No", systemImage: "xmark") {
        print("No is selected")
        
    }
    */
    let oneID = UUID()
    let twoID = UUID()
    let threeID = UUID()
    let groupVM = PKSPillGroupViewModel(maxSelection: 2)
    
    PKSPill(id: oneID, "Keyboard", systemImage: "keyboard", groupVM: groupVM) {
        
    }
    .setInset(
        EdgeInsets(
            top: 24,
            leading: 24,
            bottom: 24,
            trailing: 24
        )
    )
    
    PKSPill(id: twoID, "Airtag", systemImage: "airtag", groupVM: groupVM) {
        
    }
    .setInset(
        EdgeInsets(
            top: 24,
            leading: 24,
            bottom: 24,
            trailing: 24
        )
    )
    
    PKSPill(id: threeID, "Three", systemImage: "laptopcomputer", groupVM: groupVM) {
        
    }.setInset(
        EdgeInsets(
            top: 24,
            leading: 24,
            bottom: 24,
            trailing: 24
        )
    )
}
