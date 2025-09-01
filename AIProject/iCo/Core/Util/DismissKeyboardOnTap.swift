//
//  DismissKeyboardOnTap.swift
//  AIProject
//
//  Created by kangho lee on 8/27/25.
//

import SwiftUI

struct DismissKeyboardOnTap: ViewModifier {
    init() {}
    
    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture().onEnded {
                    UIApplication.shared.endEditing()
                }
            )
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func dissmissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
