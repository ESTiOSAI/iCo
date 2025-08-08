//
//  FearGreedViewModel.swift
//  AIProject
//
//  Created by 장지현 on 8/6/25.
//

import Foundation

/// 공포-탐욕 지수를 관리하는 뷰 모델입니다.
///
/// API에서 데이터를 받아 공포 탐욕 지수 수치와 설명을 업데이트합니다.
final class FearGreedViewModel: ObservableObject {
    /// 공포-탐욕 상태입니다.
    @Published var fearGreed: FearGreed = .neutral
    /// 공포-탐욕 지수 값입니다.
    @Published var indexValue: CGFloat = 0
    /// 한글로 표시된 공포-탐욕 분류입니다.
    @Published var classification: String = "중립"
    
    init() {
        Task {
            await self.fetchFearGreedAsync()
        }
    }
    
    /// 공포-탐욕 지수 데이터를 불러와 상태를 업데이트합니다.
    private func fetchFearGreedAsync() async {
        do {
            let data = try await FearGreedAPIService().fetchData()
            
            guard let fearGreedIndex = data.first else {
                print("Fear And Greed Index: No Data")
                await MainActor.run {
                    // FIXME: 데이터를 잘못되었을 경우 새로고침 버튼
                }
                return
            }
            
            guard let doubleIndex = Double(fearGreedIndex.value) else {
                print("Fear And Greed Index: Failed to convert String to CGFloat")
                await MainActor.run {
                    // FIXME: 데이터를 잘못되었을 경우 새로고침 버튼
                }
                return
            }
            
            await MainActor.run {
                self.indexValue = CGFloat(doubleIndex)
                fearGreed = FearGreed.from(fearGreedIndex.valueClassification)
                self.classification = fearGreed.description
            }
        }  catch {
            print("🚨 [FearAndGreed] \(error)")
            await MainActor.run {
                // FIXME: 데이터를 불러오지 못했을 경우 새로고침 버튼
            }
        }
    }
}
