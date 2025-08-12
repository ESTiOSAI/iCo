//
//  ReportSectionView.swift
//  AIProject
//
//  Created by 장지현 on 8/11/25.
//

import SwiftUI

/// 보고서 화면에서 아이콘, 제목, 본문 내용을 함께 표시하는 공통 컴포넌트 뷰입니다.
///
/// - Parameters:
///   - imageName: SF Symbol 아이콘 이름
///   - title: 섹션 제목
///   - content: 표시할 본문 내용(`AttributedString`)
///              텍스트 스타일, 색상, 링크 등 리치 텍스트 속성을 적용하기 위해 사용합니다.
struct ReportSectionView: View {
    @Binding var status: ResponseStatus
    
    var imageName: String
    var title: String
    var content: AttributedString
    
    let cornerRadius: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .font(.system(size: 14, weight: .bold))
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.aiCoAccent)
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.aiCoLabel)
                
                Spacer()
            }
            switch status {
            case .loading:
                DefaultProgressView(status: .loading, message: "아이코가 리포트를 작성하고 있어요", backgroundColor: .aiCoBackground)
                    .frame(height: 300)
            case .success:
                Text(content)
                    .font(.system(size: 14))
                    .foregroundStyle(.aiCoLabel)
                    .lineSpacing(6)
            case .failure(let networkError):
                // FIXME: cancel, failure 분기
                DefaultProgressView(status: .failure, message: networkError.localizedDescription, backgroundColor: .aiCoBackground)
                    .frame(height: 300)
            case .cancel(let networkError):
                DefaultProgressView(status: .cancel, message: networkError.localizedDescription, backgroundColor: .aiCoBackground)
                    .frame(height: 300)
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 20)
        .background(.aiCoBackground)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.default, lineWidth: 0.5)
        )
    }
}

#Preview {
    ReportSectionView(status: .constant(.success), imageName: "text.page.badge.magnifyingglass",title: "한눈에 보는 이더리움", content: "- ﻿﻿심볼: ETH\n- ﻿﻿웹사이트: https://ethereum.org\n- ﻿﻿최초발행: 2015-07-30\n- ﻿﻿소개: 이더리움(Ethereum)은 블록체인 기술을 기반으로 한 탈중앙화 컴퓨팅 플랫폼으로, 스마트 계약 기능을 통해 분산 애플리케이션(DApps)을 구축할 수 있습니다. 2015년 7월 30일 비탈릭 부테린에 의해 출시되었으며, 이더리움의 네이티브 암호화폐는 이더(ETH)로, 플랫폼 내에서 거래 및 스마트 계약 실행에 사용됩니다.")
        .padding(16)
}
