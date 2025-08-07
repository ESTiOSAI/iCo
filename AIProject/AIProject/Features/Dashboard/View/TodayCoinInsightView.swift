//
//  TodayCoinInsightView.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import SwiftUI

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
