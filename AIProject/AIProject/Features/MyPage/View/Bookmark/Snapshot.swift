//
//  Snapshot.swift
//  AIProject
//
//  Created by kangho lee on 8/31/25.
//

import SwiftUI

extension View {
    /// 캡처 대상 SwiftUI 뷰를 렌더링하여 UIImage로 반환합니다.
    func snapshotImageExact(
        scale: CGFloat = UIScreen.main.scale,
        colorScheme: ColorScheme = .light,
        background: Color = .white,
        isOpaque: Bool = true
    ) -> UIImage? {
        let content = self
            .fixedSize(horizontal: false, vertical: true)
            .background(background)
            .environment(\.colorScheme, colorScheme)

        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        renderer.isOpaque = isOpaque
        return renderer.uiImage
    }
}
