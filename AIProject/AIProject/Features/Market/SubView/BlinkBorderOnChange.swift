//
//  BlinkBorderOnChange.swift
//  AIProject
//
//  Created by kangho lee on 8/18/25.
//

import SwiftUI

/// 변견된 ticker를 rect border로 감싼 애니메이션 처리
struct BlinkBorderOnChange<Value: Equatable>: ViewModifier {
    let trigger: Value
    var duration: Duration = .seconds(2)
    var color: Color = .yellow
    var lineWidth: CGFloat = 2
    var cornerRadius: CGFloat = 12
    
    @State private var isBlinking = false
    @State private var hideTask: Task<Void, Never>?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: lineWidth)
                    .opacity(isBlinking ? 1 : 0)
                // isBlinking이 true일 때만 repeatForever, false면 즉시 정지
                    .animation(
                        isBlinking
                        ? .easeInOut(duration: 0.35).repeatForever(autoreverses: true)
                        : .default,
                        value: isBlinking
                    )
            )
            .onChange(of: trigger) { _, _ in
                startBlink()
            }
            .onDisappear {
                hideTask?.cancel()
            }
    }
    
    @MainActor
    private func startBlink() {
        hideTask?.cancel()          // 연속 업데이트 시 이전 타이머 취소
        isBlinking = true
        
        hideTask = Task {
            try? await Task.sleep(for: duration)
            isBlinking = false      // N초 뒤 자동 종료
        }
    }
}

extension View {
    func blinkBorderOnChange<Value: Equatable>(
        _ trigger: Value,
        duration: Duration = .seconds(2),
        color: Color = .yellow,
        lineWidth: CGFloat = 2,
        cornerRadius: CGFloat = 12
    ) -> some View {
        modifier(BlinkBorderOnChange(trigger: trigger,
                                     duration: duration,
                                     color: color,
                                     lineWidth: lineWidth,
                                     cornerRadius: cornerRadius))
    }
}
