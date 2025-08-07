//
//  TodayCoinInsightView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

/// 오늘의 코인 시장 또는 커뮤니티 인사이트를 보여주는 뷰입니다.
///
/// `TodayCoinInsightViewModel`을 사용해 감정 분석 결과와 요약 정보를 표시합니다.
/// `isCommunity` 값에 따라 전체 시장 또는 커뮤니티 기반 인사이트를 구분하여 출력합니다.
///
/// - Parameters:
///   - isCommunity: 커뮤니티 기반 인사이트 여부를 나타내는 불리언 값입니다.
struct TodayCoinInsightView: View {
    @StateObject var viewModel: TodayCoinInsightViewModel
    
    let isCommunity: Bool
    
    init(isCommunity: Bool = false) {
        self.isCommunity = isCommunity
        _viewModel = StateObject(wrappedValue: TodayCoinInsightViewModel(isCommunity: isCommunity))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0) {
                Text(!isCommunity ? "전체적인 시장은 " : "현재 커뮤니티 분위기는 ")
                Text(viewModel.sentiment.description)
                    .foregroundStyle(viewModel.sentiment.color)
                Text("예요")
            }
            .foregroundStyle(.aiCoLabel)
            
            Text(viewModel.summary)
        }
        .font(.system(size: 13))
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TodayCoinInsightView()
}
