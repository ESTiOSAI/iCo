//
//  CircleIconView.swift
//  AIProject
//
//  Created by Kitcat Seo on 8/8/25.
//

import SwiftUI

/// 원형 배경 위에 `SF Symbols` 아이콘을 표시하는 고정 크기의 아이콘 뷰
///
/// - Parameters:
///   - imageName: 표시할 `SF Symbols` 아이콘의 이름
struct CircleIconView: View {
    var imageName: String
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 16)
                .fontWeight(.regular)
                .foregroundStyle(.aiCoAccent)
        }
        .frame(width: 36, height: 36)
        .background(.aiCoBackgroundAccent)
        .clipShape(Circle())
        .overlay(Circle().stroke(.accentGradient, lineWidth: 0.5))
    }
}

#Preview {
    CircleIconView(imageName: "bookmark")
}
