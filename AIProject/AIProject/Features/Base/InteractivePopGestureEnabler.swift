//
//  InteractivePopGestureEnabler.swift
//  AIProject
//
//  Created by 장지현 on 8/28/25.
//

import SwiftUI

/// SwiftUI에서 네비게이션 바를 숨긴 상태에서도 iOS 기본 스와이프 뒤로가기 제스처를 활성화하기 위한 유틸리티입니다.
///
/// UIKit의 `interactivePopGestureRecognizer`를 직접 활성화하여,
/// 커스텀 헤더나 툴바를 사용하는 경우에도 뒤로가기 제스처를 사용할 수 있도록 합니다.
/// SwiftUI 뷰에서 `.interactiveSwipeBackEnabled()`를 적용하면 활성화됩니다.
public struct InteractivePopGestureEnabler: UIViewControllerRepresentable {
    public init() {}

    public func makeUIViewController(context: Context) -> UIViewController {
        PopGestureViewController()
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}

@MainActor
private final class PopGestureViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableInteractivePopIfNeeded()
    }

    private func enableInteractivePopIfNeeded() {
        guard let nav = self.navigationController,
              let pop = nav.interactivePopGestureRecognizer else { return }
        pop.isEnabled = true
        pop.delegate = nil
    }
}

public extension View {
    func interactiveSwipeBackEnabled() -> some View {
        background(InteractivePopGestureEnabler())
    }
}
