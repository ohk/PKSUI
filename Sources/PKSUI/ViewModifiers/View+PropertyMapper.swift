//
//  extension.swift
//  PKSUI
//
//  Created by Omer Hamid Kamisli on 8/17/25.
//

import SwiftUI

extension View {
    public func map(_ closure: (inout Self) -> Void) -> Self {
        var copy = self
        closure(&copy)
        return copy
    }
}
