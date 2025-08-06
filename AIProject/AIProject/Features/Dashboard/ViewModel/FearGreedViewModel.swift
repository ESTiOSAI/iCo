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
        do {
            let data = try await FearGreedAPIService().fetchData()
            
            guard let fearGreedIndex = data.first else {
                print("Fear And Greed Index: No Data")
                return
            }
            
            guard let doubleIndex = Double(fearGreedIndex.value) else {
                print("Fear And Greed Index: Failed to convert String to CGFloat")
                return
            }
            
            await MainActor.run {
                self.indexValue = CGFloat(doubleIndex)
                fearGreed = FearGreed.from(fearGreedIndex.valueClassification)
                self.classification = fearGreed.description
            }
        } catch {
            
        }
    }
}
