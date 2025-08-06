//
//  FearGreedViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

final class FearGreedViewModel: ObservableObject {
    @Published var fearGreed: FearGreed = .neutral
    @Published var indexValue: CGFloat = 0
    @Published var classification: String = "중립"
    
    init() {
        Task {
            await self.fetchFearGreedAsync()
        }
    }
    
    private func fetchFearGreedAsync() async {
    }
}
