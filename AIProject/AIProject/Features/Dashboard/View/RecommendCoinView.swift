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
        ZStack {
            LinearGradient(
                colors: [.aiBackgroundGradientProminent, .aiBackgroundGradientLight],
                startPoint: .topLeading,
                endPoint: .bottom
            )
            RecommendCoinScreen(viewModel: viewModel)
        }
    }
}

#Preview {
    RecommendCoinView()
}



