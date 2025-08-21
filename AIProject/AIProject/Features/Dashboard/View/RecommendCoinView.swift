//
//  RecommendCoinView.swift
//  AIProject
//
//  Created by 강대훈 on 8/1/25.
//

import SwiftUI

struct RecommendCoinView: View {
    @StateObject private var viewModel = RecommendCoinViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [.aiBackgroundGradientLight, .aiBackgroundGradientProminent],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            .frame(height: .headerHeight + .headerContentSpacing + (.cardHeight / 2))
            
            RecommendCoinScreen(viewModel: viewModel)
        }
    }
}

#Preview {
    RecommendCoinView()
}



