//
//  PKSPill.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

struct PKSPill<L: View, Sh: Shape>: View {
    @Environment(\.isEnabled) var isEnabled
    
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
    
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> L
    ) where Sh == Capsule {
        self.action = action
        self.label = label()
        self.shape = Capsule()
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            // TODO: Please delete duplicate codes
            if let label = label as? Text {
                label
                    .padding(inset)
                    .background(backgroundColor, in: shape)
            } else if let label = label as? Label<Text,Image> {
                label
                    .padding(inset)
                    .background(backgroundColor, in: shape)
            } else {
                label
            }
        }
        .opacity(isEnabled ? 1 : 0.5)
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
    }
}

#Preview {
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
