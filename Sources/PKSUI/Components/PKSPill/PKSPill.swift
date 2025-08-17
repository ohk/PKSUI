//
//  PKSPill.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

struct PKSPill<Label: View>: View {
    var action: () -> Void
    var label: Label
    
    var backgroundColor: Color = Color.red
    var inset: EdgeInsets = EdgeInsets(
        top: 8,
        leading: 16,
        bottom: 8,
        trailing: 16
    )
    
    init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            if let label = label as? Text {
                label
                    .padding(inset)
                    .background(backgroundColor, in: Capsule())
            } else {
                label
            }
        }
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
}

extension PKSPill where Label == Text {
    init<S: StringProtocol> (
        _ title: S,
        action: @escaping @MainActor () -> Void
    ) {
        label = {
            Text(title)
        }()
        
        self.action = action
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
    }
    
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
            Rectangle()
                .fill(Color.red)
                .frame(width: 20, height: 20)
            
            Text("Hello World")
            
        }
    }
}
