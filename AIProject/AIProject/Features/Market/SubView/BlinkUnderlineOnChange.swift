//
//  BlinkUnderlineOnChange.swift
//  AIProject
//
//  Created by kangho lee on 8/29/25.
//

import SwiftUI

/// ticker 변경 시, underline 애니메이션 처리
struct BlinkUnderlineOnChange<Value: Equatable>: ViewModifier {
    let trigger: Value
    var duration: Duration = .seconds(2)
    var color: Color = .aiCoLabel
    var lineWidth: CGFloat = 2
    
    @State private var animating = false
    @State private var hideTask: Task<Void, Never>?
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(color)
                    .frame(height: 1.5)
                    .padding(.leading, 8)
                    .opacity(animating ? 1 : 0)
                    .offset(y: 2)
                    .animation(
                        animating
                        ? .easeIn(duration: 0.3)
                            .repeatForever(autoreverses: true)
                        : .default,
                        value: animating
                    )
            }
            .onChange(of: trigger) { _, _ in
                start()
            }
            .onDisappear {
                hideTask?.cancel()
            }
    }
    
    @MainActor
    private func start() {
        hideTask?.cancel() // trigger가 새로 오면, animation 정지를 무효화하고 새로 기다림
        animating = true
        
        hideTask = Task {
            try? await Task.sleep(for: duration)
            animating = false
        }
    }
}

extension View {
    func blinkUnderlineOnChange<Value: Equatable>(
        _ trigger: Value,
        duration: Duration = .seconds(1),
        color: Color = .aiCoLabel
    ) -> some View {
        modifier(
            BlinkUnderlineOnChange(
                trigger: trigger,
                duration: duration,
                color: color
            )
        )
    }
}
