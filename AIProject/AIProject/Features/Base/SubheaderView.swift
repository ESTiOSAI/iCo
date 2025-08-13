//
//  SubheaderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 7/30/25.
//

import SwiftUI

/// 제목과 선택적 설명, 그리고 아이콘을 함께 표시하는 서브헤더 뷰입니다.
///
/// - Parameters:
///   - imageName: 표시할 SF Symbol 아이콘 이름 (선택 사항)
///   - subheading: 서브헤더에 표시할 필수 제목
///   - description: 제목 아래에 표시할 설명 (선택 사항)
///   - imageColor: 아이콘 색상 (기본값: `.aiCoAccent`)
///   - fontColor: 제목 및 설명 텍스트 색상 (기본값: `.aiCoLabel`)
struct SubheaderView: View {
    var imageName: String?
    let subheading: String
    var description: String?
    var imageColor: Color = .aiCoAccent
    var fontColor: Color = .aiCoLabel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                if let imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 19))
                        .foregroundStyle(imageColor)
                }
                
                Text(subheading)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(fontColor)
            }
            if let description {
                Text(description)
                    .font(.system(size: 15))
                    .foregroundStyle(fontColor)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
    }
}

#Preview {
    SubheaderView(imageName: "sparkles", subheading: "이런 코인은 어떠세요?", description: "회원님의 관심 코인을 기반으로 새로운 코인을 추천해드려요", imageColor: .white, fontColor: .white)
        .padding(.vertical, 16)
        .background(.aiCoGradientAccentProminent)
    
    SubheaderView(subheading: "차트 색상 변경")
        .padding(.vertical, 16)
    
    SubheaderView(imageName: "sparkles", subheading: "북마크를 분석했어요")
        .padding(.vertical, 16)
}
