//
//  DashboardSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 대시보드에서 소제목과 설명, 콘텐츠를 함께 구성하는 섹션 뷰입니다.
///
/// `SubheaderView`를 통해 제목과 설명을 표시하고, 전달된 콘텐츠를 아래에 배치합니다.
///
/// - Parameters:
///   - subheading: 섹션의 소제목 텍스트
///   - description: 선택적으로 표시되는 설명 텍스트
///   - content: 섹션 하단에 배치될 커스텀 콘텐츠 뷰
struct DashboardSectionView<Content: View>: View {
    let subheading: String
    var description: String? = nil
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(spacing: 8) {
            SubheaderView(subheading: subheading, description: description)
            content()
        }
        .padding(.bottom, 40)
    }
}

#Preview {
    DashboardSectionView(subheading: "title", description: "description") {
        EmptyView()
    }
}
