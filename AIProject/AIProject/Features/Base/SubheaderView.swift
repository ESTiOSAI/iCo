//
//  SubheaderView.swift
//  AIProject
//
//  Created by Kitcat Seo on 7/30/25.
//

import SwiftUI

/// 서브헤더에 표시할 제목을 필수로 전달해주세요.
/// 제목 아래에 추가할 설명이 있다면 전달해주세요.
struct SubheaderView: View {
    let subheading: String
    var description: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(subheading)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.aiCoLabel)
            
            if let description {
                Text(description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.aiCoLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
}

#Preview {
    SubheaderView(subheading: "이런 코인은 어떠세요?", description: "회원님의 관심 코인을 기반으로 새로운 코인을 추천해드려요")
}
